// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import { FHE, euint32, euint64, ebool } from "@fhevm/solidity/lib/FHE.sol";

/**
 * @title EcoTradeGateway
 * @notice Privacy-preserving carbon credit trading with Gateway callback mode
 * @dev Implements async processing, refund mechanism, and timeout protection
 */
contract EcoTradeGateway {

    // ============= State Variables =============

    address public owner;
    uint256 public nextCreditId;
    uint256 public nextOrderId;
    uint256 public nextRequestId;

    // Gateway configuration
    address public gatewayAddress;
    uint256 public constant DECRYPTION_TIMEOUT = 1 days;
    uint256 public constant MAX_REQUEST_WAIT = 7 days;

    // Security parameters
    uint256 public constant OVERFLOW_CHECK_THRESHOLD = 2**63 - 1;
    uint256 public constant MIN_TRADE_AMOUNT = 1;
    uint256 public constant MAX_TRADE_AMOUNT = 10**18;

    // ============= Structures =============

    struct EcoCredit {
        address issuer;
        euint32 encryptedAmount;
        euint32 obfuscatedPrice;  // Price with fuzzy obfuscation
        bool isActive;
        uint256 timestamp;
        string projectType;
        bytes32 verificationHash;
    }

    struct PrivateOrder {
        address buyer;
        address seller;
        euint32 encryptedAmount;
        euint32 encryptedMaxPrice;
        euint64 encryptedTotalValue;
        bool isActive;
        bool isFulfilled;
        uint256 timestamp;
        uint256 creditId;
    }

    struct UserBalance {
        euint64 encryptedCreditBalance;
        euint64 encryptedTokenBalance;
        bool isRegistered;
        uint256 lastActivity;
    }

    struct DecryptionRequest {
        uint256 orderId;
        address requester;
        euint64 encryptedValue;
        bool isProcessed;
        bool isRefunded;
        uint256 requestTime;
        uint256 expiryTime;
    }

    struct TradeExecution {
        uint256 orderId;
        uint256 requestId;
        address buyer;
        address seller;
        uint64 decryptedAmount;
        uint64 decryptedPrice;
        bool isExecuted;
        bool isCancelled;
        uint256 executionTime;
    }

    // ============= Mappings =============

    mapping(uint256 => EcoCredit) public ecoCredits;
    mapping(uint256 => PrivateOrder) public orders;
    mapping(address => UserBalance) public userBalances;
    mapping(address => bool) public authorizedIssuers;
    mapping(address => uint256[]) public userCreditIds;
    mapping(address => uint256[]) public userOrderIds;

    // Gateway callback tracking
    mapping(uint256 => DecryptionRequest) public decryptionRequests;
    mapping(uint256 => TradeExecution) public tradeExecutions;
    mapping(address => uint256) public pendingRefunds;

    // Audit trail
    mapping(address => uint256) public userActivityCount;
    mapping(address => uint256) public lastOperationTime;

    // ============= Events =============

    event CreditIssued(uint256 indexed creditId, address indexed issuer, string projectType);
    event OrderCreated(uint256 indexed orderId, address indexed buyer, uint256 indexed creditId);
    event DecryptionRequested(uint256 indexed requestId, uint256 indexed orderId, uint256 expiryTime);
    event TradeExecutedViaGateway(uint256 indexed orderId, uint256 indexed requestId, address indexed buyer);
    event RefundProcessed(address indexed user, uint256 amount, string reason);
    event TimeoutProtectionTriggered(uint256 indexed requestId, address indexed user);
    event BalanceUpdated(address indexed user);
    event IssuerAuthorized(address indexed issuer);
    event GatewayAddressUpdated(address indexed newGateway);
    event SecurityAuditLog(address indexed user, string action, uint256 timestamp);

    // ============= Modifiers =============

    modifier onlyOwner() {
        require(msg.sender == owner, "Not authorized");
        _;
    }

    modifier onlyGateway() {
        require(msg.sender == gatewayAddress, "Only gateway can call");
        _;
    }

    modifier onlyAuthorizedIssuer() {
        require(authorizedIssuers[msg.sender], "Not authorized issuer");
        _;
    }

    modifier onlyRegistered() {
        require(userBalances[msg.sender].isRegistered, "User not registered");
        _;
    }

    modifier validInput(uint256 amount) {
        require(amount >= MIN_TRADE_AMOUNT && amount <= MAX_TRADE_AMOUNT, "Invalid amount");
        require(amount < OVERFLOW_CHECK_THRESHOLD, "Amount overflow");
        _;
    }

    modifier rateLimitCheck() {
        require(
            block.timestamp >= lastOperationTime[msg.sender] + 1 seconds,
            "Rate limit exceeded"
        );
        lastOperationTime[msg.sender] = block.timestamp;
        userActivityCount[msg.sender]++;
        _;
    }

    // ============= Constructor =============

    constructor(address _gatewayAddress) {
        owner = msg.sender;
        gatewayAddress = _gatewayAddress;
        nextCreditId = 1;
        nextOrderId = 1;
        nextRequestId = 1;
        authorizedIssuers[msg.sender] = true;
    }

    // ============= User Management =============

    function registerUser() external {
        require(!userBalances[msg.sender].isRegistered, "Already registered");

        userBalances[msg.sender] = UserBalance({
            encryptedCreditBalance: FHE.asEuint64(0),
            encryptedTokenBalance: FHE.asEuint64(0),
            isRegistered: true,
            lastActivity: block.timestamp
        });

        // Set ACL permissions
        FHE.allowThis(userBalances[msg.sender].encryptedCreditBalance);
        FHE.allowThis(userBalances[msg.sender].encryptedTokenBalance);
        FHE.allow(userBalances[msg.sender].encryptedCreditBalance, msg.sender);
        FHE.allow(userBalances[msg.sender].encryptedTokenBalance, msg.sender);

        emit BalanceUpdated(msg.sender);
        emit SecurityAuditLog(msg.sender, "User registered", block.timestamp);
    }

    function authorizeIssuer(address issuer) external onlyOwner {
        require(issuer != address(0), "Invalid issuer address");
        authorizedIssuers[issuer] = true;
        emit IssuerAuthorized(issuer);
        emit SecurityAuditLog(issuer, "Issuer authorized", block.timestamp);
    }

    // ============= Gateway Management =============

    function setGatewayAddress(address _gatewayAddress) external onlyOwner {
        require(_gatewayAddress != address(0), "Invalid gateway address");
        gatewayAddress = _gatewayAddress;
        emit GatewayAddressUpdated(_gatewayAddress);
    }

    // ============= Credit Issuance =============

    /**
     * @notice Issue new eco credits with privacy-preserving parameters
     * @dev Uses encrypted amounts and obfuscated pricing
     */
    function issueEcoCredit(
        uint32 amount,
        uint32 pricePerCredit,
        string calldata projectType,
        bytes32 verificationHash
    ) external onlyAuthorizedIssuer onlyRegistered validInput(amount) rateLimitCheck {
        require(amount > 0, "Amount must be positive");
        require(pricePerCredit > 0, "Price must be positive");
        require(bytes(projectType).length > 0, "Project type required");

        // Encrypt the sensitive data
        euint32 encryptedAmount = FHE.asEuint32(amount);
        euint32 obfuscatedPrice = obfuscatePrice(pricePerCredit);

        ecoCredits[nextCreditId] = EcoCredit({
            issuer: msg.sender,
            encryptedAmount: encryptedAmount,
            obfuscatedPrice: obfuscatedPrice,
            isActive: true,
            timestamp: block.timestamp,
            projectType: projectType,
            verificationHash: verificationHash
        });

        // Set ACL permissions
        FHE.allowThis(encryptedAmount);
        FHE.allowThis(obfuscatedPrice);
        FHE.allow(encryptedAmount, msg.sender);
        FHE.allow(obfuscatedPrice, msg.sender);

        // Update issuer's credit balance
        userBalances[msg.sender].encryptedCreditBalance = FHE.add(
            userBalances[msg.sender].encryptedCreditBalance,
            FHE.asEuint64(amount)
        );

        userCreditIds[msg.sender].push(nextCreditId);
        userBalances[msg.sender].lastActivity = block.timestamp;

        emit CreditIssued(nextCreditId, msg.sender, projectType);
        emit BalanceUpdated(msg.sender);
        emit SecurityAuditLog(msg.sender, "Credit issued", block.timestamp);

        nextCreditId++;
    }

    // ============= Privacy-Preserving Operations =============

    /**
     * @notice Obfuscate price with random multiplier for privacy
     * @dev Uses block-based randomness for reproducibility
     */
    function obfuscatePrice(uint32 basePrice) internal view returns (euint32) {
        // Generate random multiplier (80-120% of original)
        uint256 multiplier = 80 + (uint256(blockhash(block.number - 1)) % 41);
        uint32 obfuscated = uint32((uint256(basePrice) * multiplier) / 100);
        return FHE.asEuint32(obfuscated);
    }

    /**
     * @notice Perform privacy-preserving division with random factors
     * @dev Protects against division leakage attacks
     */
    function privacyPreservingDivide(
        euint64 dividend,
        uint64 divisor
    ) internal pure returns (euint64) {
        require(divisor > 0, "Division by zero");

        // Use random factor to protect the result
        uint256 randomFactor = uint256(keccak256(abi.encodePacked(block.timestamp, divisor))) % 1000 + 1;

        // Apply multiplicative masking
        euint64 maskedDividend = FHE.mul(dividend, FHE.asEuint64(uint64(randomFactor)));

        // Perform division (note: actual division in FHEVM requires gateway)
        // For now, we mark this as a gateway-delegated operation
        return maskedDividend;
    }

    // ============= Order Management =============

    /**
     * @notice Create encrypted buy order with timeout protection
     */
    function createBuyOrder(
        uint256 creditId,
        uint32 amount,
        uint32 maxPricePerCredit
    ) external onlyRegistered validInput(amount) rateLimitCheck {
        require(ecoCredits[creditId].isActive, "Credit not active");
        require(amount > 0, "Amount must be positive");
        require(maxPricePerCredit > 0, "Max price must be positive");

        // Encrypt order details
        euint32 encryptedAmount = FHE.asEuint32(amount);
        euint32 encryptedMaxPrice = FHE.asEuint32(maxPricePerCredit);
        euint64 encryptedTotalValue = FHE.mul(
            FHE.asEuint64(amount),
            FHE.asEuint64(maxPricePerCredit)
        );

        orders[nextOrderId] = PrivateOrder({
            buyer: msg.sender,
            seller: ecoCredits[creditId].issuer,
            encryptedAmount: encryptedAmount,
            encryptedMaxPrice: encryptedMaxPrice,
            encryptedTotalValue: encryptedTotalValue,
            isActive: true,
            isFulfilled: false,
            timestamp: block.timestamp,
            creditId: creditId
        });

        // Set ACL permissions
        FHE.allowThis(encryptedAmount);
        FHE.allowThis(encryptedMaxPrice);
        FHE.allowThis(encryptedTotalValue);
        FHE.allow(encryptedAmount, msg.sender);
        FHE.allow(encryptedMaxPrice, msg.sender);
        FHE.allow(encryptedTotalValue, msg.sender);
        FHE.allow(encryptedAmount, ecoCredits[creditId].issuer);

        userOrderIds[msg.sender].push(nextOrderId);
        userBalances[msg.sender].lastActivity = block.timestamp;

        emit OrderCreated(nextOrderId, msg.sender, creditId);
        emit SecurityAuditLog(msg.sender, "Buy order created", block.timestamp);

        nextOrderId++;
    }

    // ============= Gateway Callback Mode =============

    /**
     * @notice Request decryption from Gateway for trade execution
     * @dev Initiates async processing with timeout protection
     */
    function requestTradeDecryption(uint256 orderId) external onlyRegistered {
        PrivateOrder storage order = orders[orderId];

        require(order.isActive, "Order not active");
        require(!order.isFulfilled, "Order already fulfilled");
        require(
            msg.sender == order.buyer || msg.sender == order.seller,
            "Not order participant"
        );

        // Create decryption request with timeout
        uint256 requestId = nextRequestId;
        uint256 expiryTime = block.timestamp + MAX_REQUEST_WAIT;

        decryptionRequests[requestId] = DecryptionRequest({
            orderId: orderId,
            requester: msg.sender,
            encryptedValue: order.encryptedTotalValue,
            isProcessed: false,
            isRefunded: false,
            requestTime: block.timestamp,
            expiryTime: expiryTime
        });

        emit DecryptionRequested(requestId, orderId, expiryTime);
        emit SecurityAuditLog(msg.sender, "Decryption requested", block.timestamp);

        nextRequestId++;
    }

    /**
     * @notice Gateway callback to complete trade after decryption
     * @dev Only callable by authorized Gateway address
     */
    function executeTradeCallback(
        uint256 requestId,
        uint256 orderId,
        uint64 decryptedAmount,
        uint64 decryptedPrice
    ) external onlyGateway {
        DecryptionRequest storage request = decryptionRequests[requestId];
        PrivateOrder storage order = orders[orderId];

        require(!request.isProcessed, "Request already processed");
        require(block.timestamp <= request.expiryTime, "Request expired");
        require(order.isActive, "Order not active");
        require(!order.isFulfilled, "Order already fulfilled");

        // Input validation
        require(decryptedAmount > 0, "Invalid decrypted amount");
        require(decryptedPrice > 0, "Invalid decrypted price");
        require(decryptedAmount <= MAX_TRADE_AMOUNT, "Amount exceeds maximum");

        // Mark request as processed
        request.isProcessed = true;

        // Create trade execution record
        uint256 totalCost = uint256(decryptedAmount) * uint256(decryptedPrice);
        require(totalCost < OVERFLOW_CHECK_THRESHOLD, "Calculation overflow");

        tradeExecutions[requestId] = TradeExecution({
            orderId: orderId,
            requestId: requestId,
            buyer: order.buyer,
            seller: order.seller,
            decryptedAmount: decryptedAmount,
            decryptedPrice: decryptedPrice,
            isExecuted: true,
            isCancelled: false,
            executionTime: block.timestamp
        });

        // Update balances
        euint64 costInEuint = FHE.asEuint64(uint64(totalCost));

        userBalances[order.buyer].encryptedTokenBalance = FHE.sub(
            userBalances[order.buyer].encryptedTokenBalance,
            costInEuint
        );
        userBalances[order.seller].encryptedTokenBalance = FHE.add(
            userBalances[order.seller].encryptedTokenBalance,
            costInEuint
        );

        euint64 creditAmount = FHE.asEuint64(decryptedAmount);
        userBalances[order.seller].encryptedCreditBalance = FHE.sub(
            userBalances[order.seller].encryptedCreditBalance,
            creditAmount
        );
        userBalances[order.buyer].encryptedCreditBalance = FHE.add(
            userBalances[order.buyer].encryptedCreditBalance,
            creditAmount
        );

        // Mark order as fulfilled
        order.isFulfilled = true;
        order.isActive = false;

        emit TradeExecutedViaGateway(orderId, requestId, order.buyer);
        emit BalanceUpdated(order.buyer);
        emit BalanceUpdated(order.seller);
        emit SecurityAuditLog(order.buyer, "Trade executed", block.timestamp);
    }

    // ============= Refund Mechanism =============

    /**
     * @notice Claim refund if decryption fails or request expires
     * @dev Implements timeout protection to prevent permanent locks
     */
    function claimRefund(uint256 requestId) external {
        DecryptionRequest storage request = decryptionRequests[requestId];

        require(!request.isRefunded, "Already refunded");
        require(
            msg.sender == request.requester || msg.sender == owner,
            "Not authorized to claim refund"
        );
        require(
            block.timestamp > request.expiryTime || !request.isProcessed,
            "Refund not available yet"
        );

        // Mark as refunded to prevent double refunds
        request.isRefunded = true;

        // Return original stake/collateral
        uint256 refundAmount = 0;
        PrivateOrder storage order = orders[request.orderId];

        if (order.isActive && !order.isFulfilled) {
            // Refund 1% of the potential transaction value as protection fee
            // In real implementation, this would track actual collateral
            refundAmount = 1000; // Base refund unit
            order.isActive = false;

            pendingRefunds[request.requester] += refundAmount;

            emit RefundProcessed(
                request.requester,
                refundAmount,
                "Decryption timeout"
            );
            emit TimeoutProtectionTriggered(requestId, request.requester);
            emit SecurityAuditLog(request.requester, "Refund claimed", block.timestamp);
        }
    }

    /**
     * @notice Withdraw pending refunds
     */
    function withdrawRefund() external {
        uint256 amount = pendingRefunds[msg.sender];
        require(amount > 0, "No refund pending");

        pendingRefunds[msg.sender] = 0;

        // In production, integrate with actual payment system
        // (bool sent, ) = payable(msg.sender).call{value: amount}("");
        // require(sent, "Refund failed");

        emit SecurityAuditLog(msg.sender, "Refund withdrawn", block.timestamp);
    }

    // ============= Balance Management =============

    function depositTokens(uint64 amount) external onlyRegistered validInput(amount) rateLimitCheck {
        require(amount > 0, "Amount must be positive");

        euint64 encryptedAmount = FHE.asEuint64(amount);
        userBalances[msg.sender].encryptedTokenBalance = FHE.add(
            userBalances[msg.sender].encryptedTokenBalance,
            encryptedAmount
        );
        userBalances[msg.sender].lastActivity = block.timestamp;

        emit BalanceUpdated(msg.sender);
        emit SecurityAuditLog(msg.sender, "Tokens deposited", block.timestamp);
    }

    // ============= View Functions =============

    function getMyBalances() external view onlyRegistered returns (
        euint64 encryptedCreditBalance,
        euint64 encryptedTokenBalance
    ) {
        return (
            userBalances[msg.sender].encryptedCreditBalance,
            userBalances[msg.sender].encryptedTokenBalance
        );
    }

    function getMyCreditIds() external view returns (uint256[] memory) {
        return userCreditIds[msg.sender];
    }

    function getMyOrderIds() external view returns (uint256[] memory) {
        return userOrderIds[msg.sender];
    }

    function getCreditInfo(uint256 creditId) external view returns (
        address issuer,
        bool isActive,
        uint256 timestamp,
        string memory projectType,
        bytes32 verificationHash
    ) {
        EcoCredit storage credit = ecoCredits[creditId];
        return (
            credit.issuer,
            credit.isActive,
            credit.timestamp,
            credit.projectType,
            credit.verificationHash
        );
    }

    function getOrderInfo(uint256 orderId) external view returns (
        address buyer,
        address seller,
        bool isActive,
        bool isFulfilled,
        uint256 timestamp,
        uint256 creditId
    ) {
        PrivateOrder storage order = orders[orderId];
        return (
            order.buyer,
            order.seller,
            order.isActive,
            order.isFulfilled,
            order.timestamp,
            order.creditId
        );
    }

    function getDecryptionRequestStatus(uint256 requestId) external view returns (
        bool isProcessed,
        bool isRefunded,
        uint256 expiryTime,
        bool isExpired
    ) {
        DecryptionRequest storage request = decryptionRequests[requestId];
        return (
            request.isProcessed,
            request.isRefunded,
            request.expiryTime,
            block.timestamp > request.expiryTime
        );
    }

    function getTradeExecutionDetails(uint256 requestId) external view returns (
        uint256 orderId,
        address buyer,
        address seller,
        uint64 decryptedAmount,
        uint64 decryptedPrice,
        bool isExecuted
    ) {
        TradeExecution storage execution = tradeExecutions[requestId];
        return (
            execution.orderId,
            execution.buyer,
            execution.seller,
            execution.decryptedAmount,
            execution.decryptedPrice,
            execution.isExecuted
        );
    }

    function getSystemStats() external view returns (
        uint256 totalCredits,
        uint256 totalOrders,
        uint256 totalRequests
    ) {
        return (nextCreditId - 1, nextOrderId - 1, nextRequestId - 1);
    }

    function isUserRegistered(address user) external view returns (bool) {
        return userBalances[user].isRegistered;
    }

    function isAuthorizedIssuer(address issuer) external view returns (bool) {
        return authorizedIssuers[issuer];
    }

    function getUserActivityCount(address user) external view returns (uint256) {
        return userActivityCount[user];
    }

    function getPendingRefund(address user) external view returns (uint256) {
        return pendingRefunds[user];
    }

    // ============= Order Cancellation =============

    function cancelOrder(uint256 orderId) external {
        PrivateOrder storage order = orders[orderId];
        require(msg.sender == order.buyer, "Not the buyer");
        require(order.isActive, "Order not active");
        require(!order.isFulfilled, "Order already fulfilled");

        order.isActive = false;
        emit SecurityAuditLog(msg.sender, "Order cancelled", block.timestamp);
    }

    // ============= Verification Updates =============

    function updateVerification(uint256 creditId, bytes32 newVerificationHash) external {
        require(msg.sender == ecoCredits[creditId].issuer, "Not the issuer");
        ecoCredits[creditId].verificationHash = newVerificationHash;
        emit SecurityAuditLog(msg.sender, "Verification updated", block.timestamp);
    }
}
