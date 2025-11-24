# EcoTradeGateway API Reference

## Contract Initialization

Constructor initializes contract with Gateway oracle address.

## User Management APIs

### registerUser()

Registers a new user in the system with encrypted balance accounts.

**Requirements:** User not already registered

**Events:** BalanceUpdated, SecurityAuditLog

**Gas Cost:** ~180,000

### authorizeIssuer(address issuer)

Authorizes an address to issue new eco credits.

**Requirements:** Only contract owner can call

**Events:** IssuerAuthorized, SecurityAuditLog

### setGatewayAddress(address _gatewayAddress)

Updates the Gateway oracle address.

**Requirements:** Only contract owner

## Credit Management APIs

### issueEcoCredit(uint32 amount, uint32 pricePerCredit, string projectType, bytes32 verificationHash)

Issues new eco credits with encrypted amounts and obfuscated prices.

**Requirements:**
- Caller must be authorized issuer
- Caller must be registered
- Amount valid (MIN_TRADE_AMOUNT to MAX_TRADE_AMOUNT)

**Security:** Rate limit 1 op/second, overflow protection

**Gas Cost:** ~280,000

### getCreditInfo(uint256 creditId)

Retrieves public information about a credit (encrypted values excluded).

### updateVerification(uint256 creditId, bytes32 newVerificationHash)

Updates verification hash for a credit (issuer only).

## Order Management APIs

### createBuyOrder(uint256 creditId, uint32 amount, uint32 maxPricePerCredit)

Creates encrypted buy order for carbon credits.

**Requirements:**
- Caller registered
- Credit active
- Valid amount and max price

**Security:** Rate limit, overflow protection

**Gas Cost:** ~230,000

### cancelOrder(uint256 orderId)

Cancels active order (buyer only).

### getOrderInfo(uint256 orderId)

Retrieves public order information (encrypted values excluded).

## Gateway Callback APIs

### requestTradeDecryption(uint256 orderId)

Requests decryption from Gateway oracle to execute trade.

**Requirements:**
- Caller registered
- Caller is buyer or seller
- Order active and not fulfilled

**Processing:** Creates request with 7-day timeout

**Gas Cost:** ~150,000

### executeTradeCallback(uint256 requestId, uint256 orderId, uint64 decryptedAmount, uint64 decryptedPrice)

Gateway callback to complete trade with decrypted values.

**Requirements:**
- Only Gateway address can call
- Request not processed/expired
- Order active and not fulfilled
- Values validated

**Processing:**
- Updates buyer/seller token balances
- Transfers credits between users
- Marks order as fulfilled

**Gas Cost:** ~320,000

### getDecryptionRequestStatus(uint256 requestId)

Checks status of decryption request (processed, refunded, expired).

### getTradeExecutionDetails(uint256 requestId)

Retrieves completed trade details (amount, price, addresses).

## Refund APIs

### claimRefund(uint256 requestId)

Claims refund if request expires or fails.

**Requirements:**
- Caller is requester or owner
- Request expired or not processed

**Processing:** Marks refunded, cancels order, adds to pendingRefunds

**Gas Cost:** ~80,000

### withdrawRefund()

Withdraws all pending refunds for caller.

## Balance Management APIs

### depositTokens(uint64 amount)

Deposits tokens into encrypted balance account.

**Requirements:**
- Caller registered
- Valid amount

**Gas Cost:** ~110,000

### getMyBalances()

Retrieves encrypted balances (only owner can decrypt).

## Query APIs

### getMyOrderIds()

Returns all order IDs created by caller.

### getMyCreditIds()

Returns all credit IDs issued by caller.

### getSystemStats()

Returns total credits, orders, and requests in system.

### isUserRegistered(address user)

Checks if address is registered.

### isAuthorizedIssuer(address issuer)

Checks if address can issue credits.

### getUserActivityCount(address user)

Returns number of operations by user.

### getPendingRefund(address user)

Returns pending refund amount.

## Constants

- DECRYPTION_TIMEOUT = 1 day
- MAX_REQUEST_WAIT = 7 days
- OVERFLOW_CHECK_THRESHOLD = 2^63 - 1
- MIN_TRADE_AMOUNT = 1
- MAX_TRADE_AMOUNT = 10^18

## Security Features

1. **Rate Limiting:** 1 operation per second per address
2. **Overflow Protection:** All amounts checked vs 2^63
3. **Timeout Protection:** Requests expire after 7 days
4. **Access Control:** Role-based modifiers
5. **Audit Trail:** SecurityAuditLog for all operations
6. **Gateway Authority:** Only authorized Gateway executes trades
