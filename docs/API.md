# API Reference - Carbon Credit Trading Platform

> Complete API documentation for the CarbonCreditTradingFHEVM smart contract

---

## Table of Contents

- [Contract Overview](#contract-overview)
- [State Variables](#state-variables)
- [Data Structures](#data-structures)
- [Events](#events)
- [Modifiers](#modifiers)
- [Functions](#functions)
  - [User Management](#user-management)
  - [Issuer Management](#issuer-management)
  - [Credit Management](#credit-management)
  - [Token Operations](#token-operations)
  - [Order Management](#order-management)
  - [Trade Execution](#trade-execution)
  - [View Functions](#view-functions)
- [Error Messages](#error-messages)

---

## Contract Overview

**Contract Name**: `CarbonCreditTradingFHEVM`

**Compiler Version**: Solidity 0.8.24

**License**: MIT

**Description**: Privacy-preserving carbon credit trading platform using Zama's Fully Homomorphic Encryption (FHE) technology.

**Deployed Network**: Sepolia Testnet (Chain ID: 11155111)

**Optimization**: 800 runs with Yul optimizer enabled

---

## State Variables

### Public State Variables

```solidity
// Owner address
address public owner;

// Credit counter
uint256 public creditCounter;

// Order counter
uint256 public orderCounter;

// User registration mapping
mapping(address => bool) public isRegistered;

// Issuer authorization mapping
mapping(address => bool) public isIssuer;
```

### Private State Variables

```solidity
// User information (encrypted balances)
mapping(address => User) private users;

// Carbon credit details (encrypted amounts and prices)
mapping(uint256 => CarbonCredit) private credits;

// Buy order details (encrypted amounts)
mapping(uint256 => BuyOrder) private orders;
```

---

## Data Structures

### User

```solidity
struct User {
    address userAddress;
    bool isRegistered;
    euint64 encryptedBalance;  // Encrypted token balance
}
```

**Fields**:
- `userAddress` (address) - User's Ethereum address
- `isRegistered` (bool) - Registration status
- `encryptedBalance` (euint64) - Encrypted token balance (FHE type)

### CarbonCredit

```solidity
struct CarbonCredit {
    uint256 creditId;
    address issuer;
    euint32 encryptedAmount;     // Encrypted credit amount in tons CO₂
    euint32 encryptedPrice;      // Encrypted price per credit
    bytes32 verificationHash;     // Public verification hash
    address currentOwner;
    bool isActive;
}
```

**Fields**:
- `creditId` (uint256) - Unique credit identifier
- `issuer` (address) - Address that issued the credit
- `encryptedAmount` (euint32) - Encrypted carbon credit amount
- `encryptedPrice` (euint32) - Encrypted price per credit
- `verificationHash` (bytes32) - Hash for credit verification
- `currentOwner` (address) - Current owner of the credit
- `isActive` (bool) - Credit active status

### BuyOrder

```solidity
struct BuyOrder {
    uint256 orderId;
    uint256 creditId;
    address buyer;
    euint32 encryptedAmount;     // Encrypted order amount
    bool isFilled;
    bool isCancelled;
}
```

**Fields**:
- `orderId` (uint256) - Unique order identifier
- `creditId` (uint256) - Target credit ID
- `buyer` (address) - Buyer's address
- `encryptedAmount` (euint32) - Encrypted order amount
- `isFilled` (bool) - Order filled status
- `isCancelled` (bool) - Order cancelled status

---

## Events

### UserRegistered

```solidity
event UserRegistered(address indexed user);
```

Emitted when a new user registers.

**Parameters**:
- `user` (address, indexed) - Address of registered user

### IssuerAuthorized

```solidity
event IssuerAuthorized(address indexed issuer);
```

Emitted when an issuer is authorized.

**Parameters**:
- `issuer` (address, indexed) - Address of authorized issuer

### CreditIssued

```solidity
event CreditIssued(
    uint256 indexed creditId,
    address indexed issuer,
    bytes32 verificationHash
);
```

Emitted when a carbon credit is issued.

**Parameters**:
- `creditId` (uint256, indexed) - Issued credit ID
- `issuer` (address, indexed) - Issuer address
- `verificationHash` (bytes32) - Verification hash

### TokensDeposited

```solidity
event TokensDeposited(address indexed user);
```

Emitted when tokens are deposited.

**Parameters**:
- `user` (address, indexed) - User who deposited tokens

### BuyOrderCreated

```solidity
event BuyOrderCreated(
    uint256 indexed orderId,
    uint256 indexed creditId,
    address indexed buyer
);
```

Emitted when a buy order is created.

**Parameters**:
- `orderId` (uint256, indexed) - Created order ID
- `creditId` (uint256, indexed) - Target credit ID
- `buyer` (address, indexed) - Buyer address

### TradeExecuted

```solidity
event TradeExecuted(
    uint256 indexed orderId,
    uint256 indexed creditId,
    address indexed buyer,
    address seller
);
```

Emitted when a trade is executed.

**Parameters**:
- `orderId` (uint256, indexed) - Executed order ID
- `creditId` (uint256, indexed) - Traded credit ID
- `buyer` (address, indexed) - Buyer address
- `seller` (address) - Seller address

### OrderCancelled

```solidity
event OrderCancelled(uint256 indexed orderId, address indexed buyer);
```

Emitted when an order is cancelled.

**Parameters**:
- `orderId` (uint256, indexed) - Cancelled order ID
- `buyer` (address, indexed) - Buyer address

---

## Modifiers

### onlyOwner

```solidity
modifier onlyOwner() {
    require(msg.sender == owner, "Only owner can perform this action");
    _;
}
```

Restricts function access to contract owner only.

### onlyRegistered

```solidity
modifier onlyRegistered() {
    require(isRegistered[msg.sender], "User not registered");
    _;
}
```

Requires caller to be a registered user.

### onlyIssuer

```solidity
modifier onlyIssuer() {
    require(isIssuer[msg.sender], "Not an authorized issuer");
    _;
}
```

Requires caller to be an authorized issuer.

---

## Functions

### User Management

#### registerUser

```solidity
function registerUser() external
```

Register a new user on the platform.

**Visibility**: External

**Modifiers**: None

**Requirements**:
- User must not already be registered

**Effects**:
- Adds user to registration mapping
- Initializes encrypted balance to zero
- Emits `UserRegistered` event

**Usage Example**:
```javascript
await contract.connect(user).registerUser();
```

**Gas Cost**: ~180,000

---

#### getUserInfo

```solidity
function getUserInfo(address _user)
    external
    view
    returns (
        address userAddress,
        bool registered
    )
```

Get user information (without encrypted balance).

**Visibility**: External, View

**Parameters**:
- `_user` (address) - User address to query

**Returns**:
- `userAddress` (address) - User's address
- `registered` (bool) - Registration status

**Usage Example**:
```javascript
const [address, isReg] = await contract.getUserInfo(userAddress);
```

**Gas Cost**: ~5,000 (view function)

---

### Issuer Management

#### authorizeIssuer

```solidity
function authorizeIssuer(address _issuer) external onlyOwner
```

Authorize a user as a carbon credit issuer.

**Visibility**: External

**Modifiers**: `onlyOwner`

**Parameters**:
- `_issuer` (address) - Address to authorize as issuer

**Requirements**:
- Caller must be owner
- Target user must be registered
- User must not already be an issuer

**Effects**:
- Adds address to issuer mapping
- Emits `IssuerAuthorized` event

**Usage Example**:
```javascript
await contract.connect(owner).authorizeIssuer(issuerAddress);
```

**Gas Cost**: ~85,000

---

### Credit Management

#### issueCredit

```solidity
function issueCredit(
    bytes calldata encryptedAmount,
    bytes calldata encryptedPrice,
    bytes32 verificationHash
) external onlyIssuer
```

Issue a new carbon credit with encrypted parameters.

**Visibility**: External

**Modifiers**: `onlyIssuer`

**Parameters**:
- `encryptedAmount` (bytes) - Encrypted credit amount (euint32)
- `encryptedPrice` (bytes) - Encrypted price per credit (euint32)
- `verificationHash` (bytes32) - Verification hash

**Requirements**:
- Caller must be authorized issuer
- Encrypted values must be valid FHE ciphertexts

**Effects**:
- Increments credit counter
- Stores encrypted credit details
- Sets issuer as initial owner
- Emits `CreditIssued` event

**Usage Example**:
```javascript
const encAmount = await fhevm.encrypt(1000, 'euint32');
const encPrice = await fhevm.encrypt(50, 'euint32');
const hash = ethers.keccak256(ethers.toUtf8Bytes("CERT123"));

await contract.connect(issuer).issueCredit(
    encAmount,
    encPrice,
    hash
);
```

**Gas Cost**: ~280,000

---

#### getCreditDetails

```solidity
function getCreditDetails(uint256 _creditId)
    external
    view
    returns (
        uint256 creditId,
        address issuer,
        bytes32 verificationHash,
        address currentOwner,
        bool isActive
    )
```

Get credit details (without encrypted values).

**Visibility**: External, View

**Parameters**:
- `_creditId` (uint256) - Credit ID to query

**Returns**:
- `creditId` (uint256) - Credit identifier
- `issuer` (address) - Issuer address
- `verificationHash` (bytes32) - Verification hash
- `currentOwner` (address) - Current owner
- `isActive` (bool) - Active status

**Usage Example**:
```javascript
const credit = await contract.getCreditDetails(0);
console.log('Owner:', credit.currentOwner);
```

**Gas Cost**: ~8,000 (view function)

---

### Token Operations

#### depositTokens

```solidity
function depositTokens(bytes calldata encryptedAmount)
    external
    onlyRegistered
```

Deposit tokens with encrypted amount.

**Visibility**: External

**Modifiers**: `onlyRegistered`

**Parameters**:
- `encryptedAmount` (bytes) - Encrypted token amount (euint64)

**Requirements**:
- Caller must be registered user
- Encrypted value must be valid FHE ciphertext

**Effects**:
- Adds encrypted amount to user's balance (homomorphic addition)
- Emits `TokensDeposited` event

**Usage Example**:
```javascript
const encAmount = await fhevm.encrypt(1000000, 'euint64');
await contract.connect(user).depositTokens(encAmount);
```

**Gas Cost**: ~110,000

---

### Order Management

#### createBuyOrder

```solidity
function createBuyOrder(
    uint256 _creditId,
    bytes calldata encryptedAmount
) external onlyRegistered
```

Create a buy order for carbon credits.

**Visibility**: External

**Modifiers**: `onlyRegistered`

**Parameters**:
- `_creditId` (uint256) - Target credit ID
- `encryptedAmount` (bytes) - Encrypted order amount (euint32)

**Requirements**:
- Caller must be registered user
- Credit must exist and be active
- Encrypted value must be valid

**Effects**:
- Increments order counter
- Stores encrypted order details
- Emits `BuyOrderCreated` event

**Usage Example**:
```javascript
const encAmount = await fhevm.encrypt(100, 'euint32');
await contract.connect(buyer).createBuyOrder(creditId, encAmount);
```

**Gas Cost**: ~230,000

---

#### cancelOrder

```solidity
function cancelOrder(uint256 _orderId) external
```

Cancel an existing buy order.

**Visibility**: External

**Parameters**:
- `_orderId` (uint256) - Order ID to cancel

**Requirements**:
- Caller must be the order creator
- Order must exist and not be filled or cancelled

**Effects**:
- Marks order as cancelled
- Emits `OrderCancelled` event

**Usage Example**:
```javascript
await contract.connect(buyer).cancelOrder(orderId);
```

**Gas Cost**: ~50,000

---

#### getOrderDetails

```solidity
function getOrderDetails(uint256 _orderId)
    external
    view
    returns (
        uint256 orderId,
        uint256 creditId,
        address buyer,
        bool isFilled,
        bool isCancelled
    )
```

Get order details (without encrypted amount).

**Visibility**: External, View

**Parameters**:
- `_orderId` (uint256) - Order ID to query

**Returns**:
- `orderId` (uint256) - Order identifier
- `creditId` (uint256) - Target credit ID
- `buyer` (address) - Buyer address
- `isFilled` (bool) - Filled status
- `isCancelled` (bool) - Cancelled status

**Usage Example**:
```javascript
const order = await contract.getOrderDetails(orderId);
console.log('Buyer:', order.buyer);
```

**Gas Cost**: ~7,000 (view function)

---

### Trade Execution

#### executeTrade

```solidity
function executeTrade(uint256 _orderId) external
```

Execute a trade using homomorphic operations on encrypted data.

**Visibility**: External

**Parameters**:
- `_orderId` (uint256) - Order ID to execute

**Requirements**:
- Order must exist and not be filled or cancelled
- Credit must be active
- Buyer must have sufficient encrypted balance (checked homomorphically)

**Effects**:
- Calculates total cost: `encryptedAmount * encryptedPrice` (FHE.mul)
- Verifies balance: `buyerBalance >= totalCost` (FHE.gte)
- Updates buyer balance: `balance - totalCost` (FHE.sub)
- Updates seller balance: `balance + totalCost` (FHE.add)
- Transfers credit ownership
- Marks order as filled
- Emits `TradeExecuted` event

**Homomorphic Operations**:
```solidity
// All operations on encrypted data:
euint64 totalCost = FHE.mul(
    FHE.asEuint64(order.encryptedAmount),
    FHE.asEuint64(credit.encryptedPrice)
);

ebool hasSufficientFunds = FHE.gte(
    buyer.encryptedBalance,
    totalCost
);

euint64 newBuyerBalance = FHE.sub(
    buyer.encryptedBalance,
    totalCost
);

euint64 newSellerBalance = FHE.add(
    seller.encryptedBalance,
    totalCost
);
```

**Usage Example**:
```javascript
await contract.executeTrade(orderId);
```

**Gas Cost**: ~320,000

---

### View Functions

#### creditCounter

```solidity
function creditCounter() external view returns (uint256)
```

Get total number of credits issued.

**Returns**: Total credit count

**Gas Cost**: ~2,000

---

#### orderCounter

```solidity
function orderCounter() external view returns (uint256)
```

Get total number of orders created.

**Returns**: Total order count

**Gas Cost**: ~2,000

---

#### isRegistered

```solidity
function isRegistered(address _user) external view returns (bool)
```

Check if a user is registered.

**Parameters**:
- `_user` (address) - Address to check

**Returns**: Registration status

**Gas Cost**: ~3,000

---

#### isIssuer

```solidity
function isIssuer(address _user) external view returns (bool)
```

Check if a user is an authorized issuer.

**Parameters**:
- `_user` (address) - Address to check

**Returns**: Issuer status

**Gas Cost**: ~3,000

---

#### owner

```solidity
function owner() external view returns (address)
```

Get contract owner address.

**Returns**: Owner address

**Gas Cost**: ~2,000

---

## Error Messages

### Access Control Errors

- `"Only owner can perform this action"` - Non-owner attempting owner-only function
- `"User not registered"` - Unregistered user attempting registered-only function
- `"Not an authorized issuer"` - Non-issuer attempting issuer-only function

### Registration Errors

- `"Already registered"` - User attempting to register twice
- `"Already an issuer"` - User already authorized as issuer

### Credit Errors

- `"Credit does not exist"` - Invalid credit ID
- `"Credit not active"` - Attempting to trade inactive credit

### Order Errors

- `"Order does not exist"` - Invalid order ID
- `"Order already filled"` - Attempting to execute filled order
- `"Order cancelled"` - Attempting to execute cancelled order
- `"Only order creator can cancel"` - Non-creator attempting to cancel

### Trade Errors

- `"Insufficient balance"` - Buyer doesn't have enough tokens
- `"Cannot buy own credit"` - Buyer attempting to buy their own credit

---

## Usage Patterns

### Complete Workflow

```javascript
// 1. Register users
await contract.connect(buyer).registerUser();
await contract.connect(issuer).registerUser();

// 2. Authorize issuer (owner only)
await contract.connect(owner).authorizeIssuer(issuer.address);

// 3. Issue carbon credit
const encAmount = await fhevm.encrypt(1000, 'euint32');
const encPrice = await fhevm.encrypt(50, 'euint32');
const hash = ethers.keccak256(ethers.toUtf8Bytes("CERT123"));
await contract.connect(issuer).issueCredit(encAmount, encPrice, hash);

// 4. Deposit tokens
const encTokens = await fhevm.encrypt(100000, 'euint64');
await contract.connect(buyer).depositTokens(encTokens);

// 5. Create buy order
const encOrderAmount = await fhevm.encrypt(100, 'euint32');
await contract.connect(buyer).createBuyOrder(0, encOrderAmount);

// 6. Execute trade
await contract.executeTrade(0);

// 7. Verify trade
const credit = await contract.getCreditDetails(0);
console.log('New owner:', credit.currentOwner); // buyer.address
```

---

## Security Considerations

1. **Access Control**: Always use appropriate modifiers
2. **Input Validation**: All inputs are validated before processing
3. **Encrypted Data**: Sensitive values never exposed in plaintext
4. **Reentrancy**: No external calls that could enable reentrancy
5. **Integer Overflow**: Solidity 0.8.24 has built-in overflow protection

---

## License

MIT License - See LICENSE file for details.

---

**Last Updated**: 2025-10-26
**Solidity Version**: 0.8.24
**Network**: Sepolia (11155111)

**Powered by Zama FHEVM** 🔐
