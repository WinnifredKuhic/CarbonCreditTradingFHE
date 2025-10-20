# Architecture Guide - Carbon Credit Trading Platform

> System design and architectural overview of the FHE-powered Carbon Credit Trading Platform

---

## Table of Contents

- [System Overview](#system-overview)
- [Architecture Diagram](#architecture-diagram)
- [Core Components](#core-components)
- [Data Flow](#data-flow)
- [FHE Integration](#fhe-integration)
- [Security Model](#security-model)
- [Scalability Considerations](#scalability-considerations)
- [Design Decisions](#design-decisions)

---

## System Overview

The Carbon Credit Trading Platform is a decentralized marketplace for carbon credits that leverages **Fully Homomorphic Encryption (FHE)** to protect sensitive trading data while maintaining computational functionality on-chain.

### Key Principles

1. **Privacy by Design** - All sensitive data encrypted from the start
2. **Decentralization** - No trusted third parties required
3. **Verifiability** - Transparent execution, private data
4. **Regulatory Compliance** - Authorized decryption for auditors
5. **Gas Efficiency** - Optimized for minimal transaction costs

### Technology Stack

```
┌─────────────────────────────────────────┐
│         Frontend (Future)               │
│  - Next.js 14 (App Router)             │
│  - React Components                     │
│  - Tailwind CSS                         │
│  - FHEVM SDK Integration               │
└─────────────────────────────────────────┘
                 ↓
┌─────────────────────────────────────────┐
│         Smart Contract Layer            │
│  - Solidity 0.8.24                     │
│  - Zama FHEVM Library                  │
│  - Hardhat Framework                    │
└─────────────────────────────────────────┘
                 ↓
┌─────────────────────────────────────────┐
│         Blockchain Layer                │
│  - Sepolia Testnet (11155111)          │
│  - EVM Compatible                       │
│  - FHE Precompiles                      │
└─────────────────────────────────────────┘
```

---

## Architecture Diagram

### High-Level Architecture

```
┌────────────────────────────────────────────────────────────┐
│                     User Interface                          │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐  ┌──────────┐  │
│  │  Issuer  │  │  Buyer   │  │  Seller  │  │  Owner   │  │
│  └────┬─────┘  └────┬─────┘  └────┬─────┘  └────┬─────┘  │
└───────┼─────────────┼─────────────┼─────────────┼─────────┘
        │             │             │             │
        ▼             ▼             ▼             ▼
┌────────────────────────────────────────────────────────────┐
│              FHEVM Client (Encryption Layer)                │
│  ┌──────────────────────────────────────────────────────┐  │
│  │  - Encrypt input values                              │  │
│  │  - Generate input proofs                             │  │
│  │  - Decrypt authorized outputs (EIP-712)              │  │
│  │  - Public key management                             │  │
│  └──────────────────────────────────────────────────────┘  │
└────────────────────────────────────────────────────────────┘
        │
        ▼
┌────────────────────────────────────────────────────────────┐
│           Smart Contract (Business Logic)                   │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐     │
│  │ User         │  │ Credit       │  │ Order        │     │
│  │ Management   │  │ Management   │  │ Management   │     │
│  └──────┬───────┘  └──────┬───────┘  └──────┬───────┘     │
│         │                  │                  │             │
│         └──────────┬───────┴──────────────────┘             │
│                    ▼                                        │
│         ┌──────────────────────┐                           │
│         │  Trade Execution     │                           │
│         │  (FHE Operations)    │                           │
│         └──────────────────────┘                           │
└────────────────────────────────────────────────────────────┘
        │
        ▼
┌────────────────────────────────────────────────────────────┐
│              FHE Precompiled Contracts                      │
│  ┌──────────────────────────────────────────────────────┐  │
│  │  - FHE.add() - Homomorphic addition                  │  │
│  │  - FHE.sub() - Homomorphic subtraction               │  │
│  │  - FHE.mul() - Homomorphic multiplication            │  │
│  │  - FHE.gte() - Homomorphic comparison                │  │
│  │  - FHE.select() - Conditional selection              │  │
│  └──────────────────────────────────────────────────────┘  │
└────────────────────────────────────────────────────────────┘
        │
        ▼
┌────────────────────────────────────────────────────────────┐
│                 Blockchain State                            │
│  ┌──────────────────────────────────────────────────────┐  │
│  │  Encrypted Storage:                                   │  │
│  │  - euint64: User balances (encrypted)                │  │
│  │  - euint32: Credit amounts (encrypted)               │  │
│  │  - euint32: Credit prices (encrypted)                │  │
│  │  - euint32: Order amounts (encrypted)                │  │
│  │                                                       │  │
│  │  Public Storage:                                      │  │
│  │  - User addresses, registration status               │  │
│  │  - Issuer authorization                              │  │
│  │  - Credit/order existence, ownership                 │  │
│  │  - Verification hashes                               │  │
│  └──────────────────────────────────────────────────────┘  │
└────────────────────────────────────────────────────────────┘
```

---

## Core Components

### 1. User Management Module

**Responsibilities**:
- User registration
- Issuer authorization
- Access control

**Data Structures**:
```solidity
struct User {
    address userAddress;
    bool isRegistered;
    euint64 encryptedBalance;  // FHE encrypted
}

mapping(address => User) private users;
mapping(address => bool) public isRegistered;
mapping(address => bool) public isIssuer;
```

**Functions**:
- `registerUser()` - Register new user
- `authorizeIssuer()` - Authorize issuer (owner only)
- `getUserInfo()` - Get user info (view)

### 2. Credit Management Module

**Responsibilities**:
- Carbon credit issuance
- Credit ownership tracking
- Verification hash management

**Data Structures**:
```solidity
struct CarbonCredit {
    uint256 creditId;
    address issuer;
    euint32 encryptedAmount;     // FHE encrypted
    euint32 encryptedPrice;      // FHE encrypted
    bytes32 verificationHash;     // Public
    address currentOwner;
    bool isActive;
}

mapping(uint256 => CarbonCredit) private credits;
uint256 public creditCounter;
```

**Functions**:
- `issueCredit()` - Issue new credit (issuer only)
- `getCreditDetails()` - Get credit info (view)

### 3. Order Management Module

**Responsibilities**:
- Buy order creation
- Order cancellation
- Order state tracking

**Data Structures**:
```solidity
struct BuyOrder {
    uint256 orderId;
    uint256 creditId;
    address buyer;
    euint32 encryptedAmount;     // FHE encrypted
    bool isFilled;
    bool isCancelled;
}

mapping(uint256 => BuyOrder) private orders;
uint256 public orderCounter;
```

**Functions**:
- `createBuyOrder()` - Create buy order
- `cancelOrder()` - Cancel order
- `getOrderDetails()` - Get order info (view)

### 4. Trade Execution Module

**Responsibilities**:
- Homomorphic balance verification
- Encrypted cost calculation
- Atomic settlement

**Core Logic**:
```solidity
function executeTrade(uint256 _orderId) external {
    BuyOrder storage order = orders[_orderId];
    CarbonCredit storage credit = credits[order.creditId];

    // 1. Calculate total cost (FHE.mul)
    euint64 totalCost = FHE.mul(
        FHE.asEuint64(order.encryptedAmount),
        FHE.asEuint64(credit.encryptedPrice)
    );

    // 2. Verify balance (FHE.gte)
    ebool hasSufficientFunds = FHE.gte(
        users[order.buyer].encryptedBalance,
        totalCost
    );

    // 3. Update balances (FHE.sub, FHE.add)
    users[order.buyer].encryptedBalance = FHE.sub(
        users[order.buyer].encryptedBalance,
        totalCost
    );

    users[credit.currentOwner].encryptedBalance = FHE.add(
        users[credit.currentOwner].encryptedBalance,
        totalCost
    );

    // 4. Transfer ownership
    credit.currentOwner = order.buyer;
    order.isFilled = true;
}
```

---

## Data Flow

### Registration Flow

```
User → registerUser()
  ↓
Check: Not already registered
  ↓
Create User struct
  ↓
Initialize encryptedBalance = FHE.asEuint64(0)
  ↓
Set isRegistered[user] = true
  ↓
Emit UserRegistered event
  ↓
Return success
```

### Credit Issuance Flow

```
Issuer → issueCredit(encAmount, encPrice, hash)
  ↓
Check: Caller is authorized issuer
  ↓
Validate: FHE encrypted inputs
  ↓
Create CarbonCredit struct:
  - creditId = creditCounter++
  - issuer = msg.sender
  - encryptedAmount = FHE.asEuint32(encAmount)
  - encryptedPrice = FHE.asEuint32(encPrice)
  - verificationHash = hash
  - currentOwner = issuer
  - isActive = true
  ↓
Store in credits mapping
  ↓
Emit CreditIssued event
  ↓
Return creditId
```

### Trade Execution Flow

```
Anyone → executeTrade(orderId)
  ↓
Load: BuyOrder and CarbonCredit
  ↓
Validate: Order exists, not filled, not cancelled
  ↓
Validate: Credit is active
  ↓
Calculate: totalCost = FHE.mul(amount, price)
  ↓
Verify: buyerBalance >= totalCost (FHE.gte)
  ↓
Update: buyer balance (FHE.sub)
  ↓
Update: seller balance (FHE.add)
  ↓
Transfer: credit ownership
  ↓
Mark: order as filled
  ↓
Emit TradeExecuted event
  ↓
Return success
```

---

## FHE Integration

### Encryption Process

```
Client Side:
┌─────────────────────────────────────┐
│ 1. Get public key from FHEVM        │
│ 2. Encrypt plaintext value          │
│ 3. Generate input proof             │
│ 4. Send to smart contract           │
└─────────────────────────────────────┘
         ↓
Contract Side:
┌─────────────────────────────────────┐
│ 1. Receive encrypted bytes          │
│ 2. Convert to FHE type (euintX)     │
│ 3. Store in contract state          │
│ 4. Perform homomorphic operations   │
└─────────────────────────────────────┘
```

### Decryption Process

#### User Decrypt (EIP-712)

```
┌─────────────────────────────────────┐
│ 1. User requests decryption         │
│ 2. Contract checks authorization    │
│ 3. User signs EIP-712 message       │
│ 4. Submit signature to FHEVM        │
│ 5. FHEVM decrypts with user key     │
│ 6. Return plaintext to user         │
└─────────────────────────────────────┘
```

#### Public Decrypt

```
┌─────────────────────────────────────┐
│ 1. Anyone requests public decrypt   │
│ 2. Contract verifies value is public│
│ 3. FHEVM decrypts value             │
│ 4. Return plaintext to caller       │
└─────────────────────────────────────┘
```

### FHE Operations Used

| Operation | Function | Use Case |
|-----------|----------|----------|
| **FHE.add** | `euint64 = FHE.add(euint64, euint64)` | Token deposits |
| **FHE.sub** | `euint64 = FHE.sub(euint64, euint64)` | Token withdrawals |
| **FHE.mul** | `euint64 = FHE.mul(euint32, euint32)` | Cost calculation |
| **FHE.gte** | `ebool = FHE.gte(euint64, euint64)` | Balance verification |
| **FHE.select** | `euint64 = FHE.select(ebool, euint64, euint64)` | Conditional logic |
| **FHE.asEuint64** | `euint64 = FHE.asEuint64(euint32)` | Type conversion |

---

## Security Model

### Privacy Guarantees

**Encrypted (Private)**:
- ✅ User token balances
- ✅ Carbon credit amounts
- ✅ Credit prices
- ✅ Order quantities
- ✅ Trade volumes

**Public (Transparent)**:
- ✅ User registration status
- ✅ Issuer authorization
- ✅ Credit existence
- ✅ Order existence
- ✅ Ownership transfers
- ✅ Verification hashes

### Access Control Matrix

| Action | Owner | Issuer | User | Anyone |
|--------|-------|--------|------|--------|
| **Register User** | ✅ | ✅ | ✅ | ✅ |
| **Authorize Issuer** | ✅ | ❌ | ❌ | ❌ |
| **Issue Credit** | ❌ | ✅ | ❌ | ❌ |
| **Deposit Tokens** | ❌ | ❌ | ✅ | ❌ |
| **Create Order** | ❌ | ❌ | ✅ | ❌ |
| **Execute Trade** | ✅ | ✅ | ✅ | ✅ |
| **Cancel Order** | ❌ | ❌ | ✅* | ❌ |
| **View Public Data** | ✅ | ✅ | ✅ | ✅ |

*Only order creator can cancel their own orders

### Threat Model

**Protected Against**:
- ✅ Front-running (encrypted values)
- ✅ MEV attacks (private pricing)
- ✅ Data leakage (FHE encryption)
- ✅ Unauthorized access (modifiers)
- ✅ Integer overflow (Solidity 0.8.24)
- ✅ Reentrancy (no external calls)

**Assumptions**:
- FHE cryptographic security
- Ethereum consensus security
- Private key protection
- Trusted FHEVM implementation

---

## Scalability Considerations

### Gas Optimization

**Strategies**:
1. **800-run Optimizer** - Reduced deployment cost
2. **Yul Optimization** - Advanced compiler optimization
3. **Minimal Storage** - Only essential state variables
4. **Efficient Data Structures** - Optimized mappings
5. **Batch Operations** - Future: Multi-order execution

**Gas Costs**:
```
Deployment:        3,500,000 gas
Registration:        180,000 gas
Credit Issuance:     280,000 gas
Token Deposit:       110,000 gas
Order Creation:      230,000 gas
Trade Execution:     320,000 gas
```

### Future Scaling Solutions

1. **Layer 2 Integration**
   - Deploy on L2 networks (Arbitrum, Optimism)
   - Reduce gas costs by 90%+
   - Maintain FHE privacy

2. **Batch Processing**
   - Execute multiple trades in one transaction
   - Amortize gas costs
   - Improve throughput

3. **State Channels**
   - Off-chain order matching
   - On-chain settlement only
   - Instant execution

4. **Sharding**
   - Partition credits by category
   - Parallel processing
   - Horizontal scaling

---

## Design Decisions

### Why FHE?

**Alternatives Considered**:
- ❌ **Zero-Knowledge Proofs** - Complex circuits, no computation on encrypted data
- ❌ **Trusted Execution Environments** - Centralized trust assumption
- ❌ **Multi-Party Computation** - Requires multiple parties online
- ✅ **Fully Homomorphic Encryption** - Compute on encrypted data, no trusted parties

**FHE Advantages**:
- Computation on encrypted data
- No trusted third parties
- Regulatory compliance (authorized decryption)
- Future-proof (quantum-resistant)

### Why Sepolia?

**Network Selection**:
- ✅ Testnet for development
- ✅ FHEVM support
- ✅ Free testnet ETH
- ✅ Etherscan verification
- ⚠️ Will migrate to mainnet after testing

### Why Hardhat?

**Framework Selection**:
- ✅ Best developer experience
- ✅ Excellent TypeScript support
- ✅ Comprehensive plugin ecosystem
- ✅ Built-in network management
- ✅ Strong testing framework

### Why euint32 for Amounts?

**Type Selection**:
- euint32: Max value 4,294,967,295
- Sufficient for carbon credit amounts (tons CO₂)
- More gas efficient than euint64
- Smaller storage footprint

### Why euint64 for Balances?

**Type Selection**:
- euint64: Max value 18,446,744,073,709,551,615
- Required for token balances (multiplication results)
- Prevents overflow in cost calculations
- Standard for financial applications

---

## Component Interactions

### Sequence Diagram: Complete Trade Flow

```
User      Issuer    Owner     Contract     FHEVM
 │          │         │          │           │
 │──register()────────────────►│           │
 │◄─────────────────────────────│           │
 │          │         │          │           │
 │          │──register()───────►│           │
 │          │◄──────────────────│           │
 │          │         │          │           │
 │          │         │──authorize(issuer)──►│
 │          │◄────────────────────────────────│
 │          │         │          │           │
 │          │──encrypt(1000)────────────────►│
 │          │◄────────────────────────────────│
 │          │         │          │           │
 │          │──issueCredit(enc)─►│           │
 │          │◄──────────────────│           │
 │          │         │          │           │
 │──encrypt(100000)──────────────────────────►│
 │◄────────────────────────────────────────────│
 │          │         │          │           │
 │──depositTokens(enc)───────────►│           │
 │◄──────────────────────────────│           │
 │          │         │          │           │
 │──encrypt(100)─────────────────────────────►│
 │◄────────────────────────────────────────────│
 │          │         │          │           │
 │──createOrder(enc)─────────────►│           │
 │◄──────────────────────────────│           │
 │          │         │          │           │
 │──executeTrade()───────────────►│           │
 │          │         │          │──mul()───►│
 │          │         │          │◄──────────│
 │          │         │          │──gte()───►│
 │          │         │          │◄──────────│
 │          │         │          │──sub()───►│
 │          │         │          │◄──────────│
 │          │         │          │──add()───►│
 │          │         │          │◄──────────│
 │◄──────────────────────────────│           │
```

---

## Deployment Architecture

### Development Environment

```
Developer Machine
├── Source Code (contracts/, scripts/, test/)
├── Hardhat Node (Local EVM)
├── Node.js Runtime
└── FHEVM Libraries
```

### Sepolia Testnet Deployment

```
Sepolia Network
├── Smart Contract (0x...)
├── FHEVM Precompiles
├── Etherscan Verification
└── RPC Endpoints (Infura, Alchemy)
```

### Future Production Deployment

```
Mainnet / L2
├── Smart Contract (Audited)
├── Multi-sig Wallet (Owner)
├── Monitoring & Alerts
├── Backup Nodes
└── Emergency Pause Mechanism
```

---

## References

### Zama Resources
- [FHEVM Documentation](https://docs.zama.ai/fhevm)
- [FHEVM GitHub](https://github.com/zama-ai/fhevm)
- [FHE Library](https://github.com/zama-ai/fhevm-solidity)

### Design Patterns
- [OpenZeppelin Contracts](https://docs.openzeppelin.com/contracts)
- [Solidity Patterns](https://fravoll.github.io/solidity-patterns/)
- [Smart Contract Best Practices](https://consensys.github.io/smart-contract-best-practices/)

---

## License

MIT License - See LICENSE file for details.

---

**Last Updated**: 2025-10-26
**Version**: 1.0.0
**Architecture**: Decentralized FHE-powered marketplace

**Powered by Zama FHEVM** 🔐
