# EcoTradeGateway Architecture

## Overview

EcoTradeGateway is a privacy-preserving carbon credit trading platform built on Zamas Fully Homomorphic Encryption (FHE) technology. It implements a Gateway callback mode for asynchronous decryption processing with robust timeout protection and refund mechanisms.

## Architecture Diagram

```
+-----------------------------------------------------------------------------+
|                           EcoTradeGateway System                            |
+-----------------------------------------------------------------------------+
|                                                                             |
|  +-------------+    +-------------+    +-------------+    +-------------+   |
|  |    User     |    |   Issuer    |    |   Gateway   |    |    Owner    |   |
|  |  Interface  |    |   Portal    |    |   Oracle    |    |   Console   |   |
|  +------+------+    +------+------+    +------+------+    +------+------+   |
|         |                  |                  |                  |          |
|         v                  v                  v                  v          |
|  +---------------------------------------------------------------------+    |
|  |                        Smart Contract Layer                         |    |
|  |                                                                     |    |
|  |  +-----------------+  +-----------------+  +-----------------+      |    |
|  |  |  User Manager   |  |  Credit Manager |  |  Order Manager  |      |    |
|  |  |  - Register     |  |  - Issue        |  |  - Create       |      |    |
|  |  |  - Authorize    |  |  - Obfuscate    |  |  - Cancel       |      |    |
|  |  |  - Balance      |  |  - Verify       |  |  - Execute      |      |    |
|  |  +-----------------+  +-----------------+  +-----------------+      |    |
|  |                                                                     |    |
|  |  +-----------------+  +-----------------+  +-----------------+      |    |
|  |  | Gateway Callback|  | Refund Manager  |  | Security Module |      |    |
|  |  |  - Request      |  |  - Claim        |  |  - Validation   |      |    |
|  |  |  - Execute      |  |  - Withdraw     |  |  - Rate Limit   |      |    |
|  |  |  - Timeout      |  |  - Protect      |  |  - Audit Log    |      |    |
|  |  +-----------------+  +-----------------+  +-----------------+      |    |
|  +---------------------------------------------------------------------+    |
|                                     |                                       |
|                                     v                                       |
|  +---------------------------------------------------------------------+    |
|  |                         FHE Encryption Layer                        |    |
|  |                                                                     |    |
|  |  +---------------+  +---------------+  +-------------------------+  |    |
|  |  |   euint32     |  |   euint64     |  |   Homomorphic Operations|  |    |
|  |  |   - Amount    |  |   - Balance   |  |   - FHE.add             |  |    |
|  |  |   - Price     |  |   - TotalVal  |  |   - FHE.sub             |  |    |
|  |  +---------------+  +---------------+  |   - FHE.mul             |  |    |
|  |                                        +-------------------------+  |    |
|  +---------------------------------------------------------------------+    |
|                                                                             |
+-----------------------------------------------------------------------------+
```

## Core Components

### 1. Gateway Callback Mode

The system uses an asynchronous Gateway callback pattern for secure decryption:

```
+----------+     +--------------+     +--------------+     +--------------+
|  User    |     |   Contract   |     |   Gateway    |     |   Oracle     |
+----+-----+     +------+-------+     +------+-------+     +------+-------+
     |                  |                    |                    |
     |  Submit Request  |                    |                    |
     +----------------->|                    |                    |
     |                  |                    |                    |
     |                  |  Record Request    |                    |
     |                  |  + Set Timeout     |                    |
     |                  +------------------->|                    |
     |                  |                    |                    |
     |                  |                    |  Decrypt Values    |
     |                  |                    +------------------->|
     |                  |                    |                    |
     |                  |                    |  Return Plaintext  |
     |                  |                    |<-------------------+
     |                  |                    |                    |
     |                  |  Callback Execute  |                    |
     |                  |<-------------------+                    |
     |                  |                    |                    |
     |  Tx Complete     |                    |                    |
     |<-----------------+                    |                    |
     |                  |                    |                    |
```

### 2. Refund Mechanism

Handles decryption failures with automatic refund processing:

**Refund Flow:**
1. User creates decryption request with collateral
2. Request has expiry time (MAX_REQUEST_WAIT = 7 days)
3. If Gateway fails or times out, user can claim refund
4. Refund is added to pendingRefunds mapping
5. User withdraws refund separately

### 3. Timeout Protection

Prevents permanent fund locking:

| Parameter | Value | Purpose |
|-----------|-------|---------|
| DECRYPTION_TIMEOUT | 1 day | Gateway processing deadline |
| MAX_REQUEST_WAIT | 7 days | Maximum wait before refund eligible |

## Security Features

### 1. Input Validation

All inputs are validated against defined thresholds:

```solidity
uint256 public constant MIN_TRADE_AMOUNT = 1;
uint256 public constant MAX_TRADE_AMOUNT = 10**18;
uint256 public constant OVERFLOW_CHECK_THRESHOLD = 2**63 - 1;
```

### 2. Access Control

Role-based permission system:

| Role | Permissions |
|------|-------------|
| Owner | Authorize issuers, Set gateway, Emergency functions |
| Issuer | Issue credits, Update verification |
| User | Create orders, Trade, View balances |
| Gateway | Execute callbacks only |

### 3. Rate Limiting

Prevents DoS attacks with per-address rate limiting.

### 4. Overflow Protection

All arithmetic operations are checked for overflow.

### 5. Audit Trail

Every operation is logged for transparency via SecurityAuditLog events.

## Privacy Techniques

### 1. Price Obfuscation

Prices are obfuscated with random multipliers (80-120% of original).

### 2. Privacy-Preserving Division

Uses random factors to protect division results.

## Gas Optimization

### HCU (Homomorphic Computation Unit) Efficiency

1. **Batch Operations**: Group related FHE operations to reduce overhead
2. **Lazy Evaluation**: Defer decryption until absolutely necessary
3. **Minimal Encryption**: Only encrypt sensitive values, keep metadata public
4. **ACL Caching**: Set permissions once during object creation

### Gas Cost Estimates

| Operation | Estimated Gas |
|-----------|--------------|
| Register User | ~180,000 |
| Issue Credit | ~280,000 |
| Create Order | ~230,000 |
| Request Decryption | ~150,000 |
| Execute Trade (Gateway) | ~320,000 |
| Claim Refund | ~80,000 |

## Deployment Checklist

1. Deploy contract with gateway address
2. Verify gateway address is correct
3. Authorize initial issuers
4. Test with small amounts first
5. Monitor audit logs
6. Set up gateway oracle integration
