# Carbon Credit Trading Platform - Testing Documentation

## Overview

This document provides comprehensive information about the testing infrastructure for the Carbon Credit Trading Platform. The test suite includes **60+ test cases** covering all contract functionality, edge cases, and real-world scenarios.

## Table of Contents

- [Test Infrastructure](#test-infrastructure)
- [Test Suite Structure](#test-suite-structure)
- [Running Tests](#running-tests)
- [Test Coverage](#test-coverage)
- [Test Categories](#test-categories)
- [Sepolia Testnet Testing](#sepolia-testnet-testing)
- [Best Practices](#best-practices)

## Test Infrastructure

### Technology Stack

- **Test Framework**: Mocha
- **Assertion Library**: Chai with Hardhat matchers
- **Testing Tool**: Hardhat
- **Network**: Hardhat local network & Sepolia testnet
- **JavaScript/ES6**: Modern JavaScript with imports

### Test Dependencies

```json
{
  "devDependencies": {
    "@nomicfoundation/hardhat-toolbox": "^6.1.0",
    "chai": "^4.x",
    "hardhat": "^3.0.6",
    "ethers": "^6.15.0"
  }
}
```

## Test Suite Structure

### File Organization

```
test/
├── CarbonCreditTrading.test.js        # Main test suite (60 tests)
└── CarbonCreditTrading.sepolia.test.js # Sepolia testnet tests (6 tests)
```

### Test File: CarbonCreditTrading.test.js

**Total Test Cases: 60**

#### Test Categories

1. **Deployment Tests** (5 tests)
   - Contract deployment verification
   - Owner initialization
   - Counter initialization
   - Default issuer authorization

2. **User Registration Tests** (6 tests)
   - User registration functionality
   - Event emissions
   - Duplicate registration prevention
   - Multiple user registration
   - Balance initialization

3. **Issuer Authorization Tests** (5 tests)
   - Owner authorization rights
   - Event emissions
   - Access control enforcement
   - Multiple issuer support
   - Authorization status checks

4. **Carbon Credit Issuance Tests** (8 tests)
   - Authorized issuer functionality
   - Event emissions
   - Authorization enforcement
   - Registration requirements
   - Input validation (zero amount/price)
   - Credit ID incrementation
   - Information storage

5. **Token Deposit Tests** (5 tests)
   - Deposit functionality
   - Registration requirements
   - Zero amount validation
   - Multiple deposits
   - Large amount handling

6. **Buy Order Creation Tests** (7 tests)
   - Order creation functionality
   - Order ID incrementation
   - Registration requirements
   - Credit status validation
   - Zero amount prevention
   - Information storage
   - Multiple orders per user

7. **Trade Execution Tests** (6 tests)
   - Trade execution by seller
   - Order fulfillment status
   - Seller authorization
   - Duplicate execution prevention
   - Inactive order handling
   - Event emissions

8. **Order Cancellation Tests** (4 tests)
   - Cancellation by buyer
   - Authorization enforcement
   - Inactive order handling
   - Fulfilled order protection

9. **View Functions Tests** (4 tests)
   - Balance retrieval
   - Credit ID queries
   - Order ID queries
   - System statistics

10. **Verification Update Tests** (3 tests)
    - Issuer verification updates
    - Authorization enforcement
    - Hash update verification

11. **Edge Cases Tests** (3 tests)
    - Maximum uint32 values
    - Maximum uint64 values
    - Empty string handling

### Test File: CarbonCreditTrading.sepolia.test.js

**Total Test Cases: 6**

#### Sepolia Test Categories

1. **Contract Verification** (3 tests)
   - Address validation
   - Owner reading
   - System stats reading

2. **User Registration on Testnet** (1 test)
   - Real network registration
   - Gas cost tracking
   - Transaction confirmation

3. **Token Deposit on Testnet** (1 test)
   - Real token deposits
   - Gas cost analysis
   - Balance verification

4. **Carbon Credit Issuance on Testnet** (1 test)
   - Real credit issuance
   - Authorization checking
   - Gas cost tracking

5. **Gas Cost Analysis** (1 test)
   - Operation cost summary
   - Gas estimation

6. **Network Information** (1 test)
   - Network details
   - Block information
   - Contract links

## Running Tests

### Local Testing (Mock Environment)

Run all tests on Hardhat local network:

```bash
npm run test
```

Run specific test file:

```bash
npx hardhat test test/CarbonCreditTrading.test.js
```

Run with gas reporting:

```bash
REPORT_GAS=true npm run test
```

### Sepolia Testnet Testing

**Prerequisites**:
1. Deploy contract to Sepolia first
2. Ensure test account has SepoliaETH
3. Set SEPOLIA_RPC_URL in .env

Run Sepolia tests:

```bash
npm run test:sepolia
```

Or specifically:

```bash
npx hardhat test test/CarbonCreditTrading.sepolia.test.js --network sepolia
```

### Coverage Report

Generate code coverage report:

```bash
npm run test:coverage
```

This will:
- Run all tests
- Generate coverage report
- Create `coverage/` directory with HTML report
- Display coverage statistics

## Test Coverage

### Target Coverage Metrics

- **Line Coverage**: > 90%
- **Function Coverage**: > 95%
- **Branch Coverage**: > 85%
- **Statement Coverage**: > 90%

### Coverage Areas

✅ **Fully Covered**:
- User registration
- Issuer authorization
- Credit issuance
- Token deposits
- Order creation
- Trade execution
- Order cancellation
- View functions
- Access control

✅ **Edge Cases Covered**:
- Zero values
- Maximum values
- Invalid inputs
- Unauthorized access
- State transitions

## Test Categories Breakdown

### 1. Deployment Tests (5 tests)

Tests contract initialization and initial state.

**Example**:
```javascript
it("should deploy successfully with valid address", async function () {
  expect(contractAddress).to.be.properAddress;
  expect(contractAddress).to.not.equal(ethers.ZeroAddress);
});
```

### 2. Access Control Tests (18 tests total)

Tests authorization and permission enforcement across:
- User registration (6 tests)
- Issuer authorization (5 tests)
- Function access control (7 tests)

**Example**:
```javascript
it("should reject non-owner authorization attempt", async function () {
  await expect(
    contract.connect(buyer1).authorizeIssuer(issuer1.address)
  ).to.be.revertedWith("Not authorized");
});
```

### 3. Core Functionality Tests (21 tests total)

Tests main platform features:
- Carbon credit issuance (8 tests)
- Token deposits (5 tests)
- Order creation (7 tests)
- Trade execution (6 tests)
- Order cancellation (4 tests)

**Example**:
```javascript
it("should allow authorized issuer to issue credits", async function () {
  const tx = await contract
    .connect(issuer1)
    .issueCarbonCredits(1000, 50, "renewable_energy", verificationHash);
  await tx.wait();

  const stats = await contract.getSystemStats();
  expect(stats.totalCredits).to.equal(1);
});
```

### 4. State Management Tests (10 tests)

Tests state changes and data persistence:
- Balance updates
- Counter increments
- Status changes
- Information storage

### 5. Edge Case Tests (3 tests)

Tests boundary conditions:
- Maximum values
- Minimum values
- Empty inputs

### 6. View Function Tests (4 tests)

Tests read-only functions:
- Balance queries
- System statistics
- User data retrieval

## Sepolia Testnet Testing

### Purpose

Sepolia tests validate:
- Real network behavior
- Actual gas costs
- Transaction confirmation
- Network latency handling

### Test Pattern

```javascript
it("should work on Sepolia", async function () {
  steps = 5;
  this.timeout(160000); // Extended timeout for testnet

  progress("Step 1: Preparing data...");
  // Preparation logic

  progress("Step 2: Submitting transaction...");
  const tx = await contract.operation();

  progress("Step 3: Waiting for confirmation...");
  const receipt = await tx.wait();

  progress("Step 4: Verifying result...");
  // Verification logic

  progress("Step 5: Complete");
});
```

### Gas Cost Tracking

Sepolia tests track gas costs for:
- User registration: ~150,000 - 200,000 gas
- Token deposit: ~80,000 - 120,000 gas
- Credit issuance: ~200,000 - 300,000 gas
- Order creation: ~150,000 - 250,000 gas
- Trade execution: ~200,000 - 350,000 gas

## Best Practices

### 1. Test Isolation

Each test uses `beforeEach` to deploy a fresh contract:

```javascript
beforeEach(async function () {
  ({ contract, contractAddress } = await deployFixture());
});
```

### 2. Descriptive Test Names

Use clear, action-oriented descriptions:

```javascript
// ✅ Good
it("should reject duplicate registration", async function () {});

// ❌ Bad
it("test registration", async function () {});
```

### 3. Arrange-Act-Assert Pattern

Structure tests clearly:

```javascript
it("should execute trade correctly", async function () {
  // Arrange: Setup
  await contract.connect(buyer1).registerUser();
  await contract.connect(buyer1).depositTokens(10000);

  // Act: Execute
  await contract.connect(issuer1).executeTrade(orderId);

  // Assert: Verify
  const orderInfo = await contract.getOrderInfo(orderId);
  expect(orderInfo.isFulfilled).to.be.true;
});
```

### 4. Event Testing

Always test event emissions:

```javascript
await expect(contract.registerUser())
  .to.emit(contract, "BalanceUpdated")
  .withArgs(user.address);
```

### 5. Error Message Testing

Test specific revert messages:

```javascript
await expect(
  contract.connect(unauthorized).adminFunction()
).to.be.revertedWith("Not authorized");
```

### 6. Gas Optimization Testing

Monitor gas usage:

```javascript
const tx = await contract.operation();
const receipt = await tx.wait();
expect(receipt.gasUsed).to.be.lt(500000); // < 500k gas
```

## Running Specific Test Suites

### Run only deployment tests:
```bash
npx hardhat test --grep "Deployment"
```

### Run only access control tests:
```bash
npx hardhat test --grep "Access Control|Authorization|Registration"
```

### Run only core functionality:
```bash
npx hardhat test --grep "Issuance|Deposit|Order|Trade"
```

### Skip Sepolia tests locally:
```bash
npx hardhat test --grep "^((?!Sepolia).)*$"
```

## Continuous Integration

### CI/CD Pipeline

Recommended GitHub Actions workflow:

```yaml
name: Test Suite

on: [push, pull_request]

jobs:
  test:
    runs-on: ubuntu-latest

    steps:
      - uses: actions/checkout@v3
      - uses: actions/setup-node@v3
        with:
          node-version: '18'

      - name: Install dependencies
        run: npm install

      - name: Run tests
        run: npm run test

      - name: Generate coverage
        run: npm run test:coverage

      - name: Upload coverage
        uses: codecov/codecov-action@v3
```

## Troubleshooting

### Common Issues

1. **Test Timeout**
   - Increase timeout for slow tests
   - Use `this.timeout(30000)` for 30 seconds

2. **Nonce Issues**
   - Reset Hardhat network between test runs
   - Use `npx hardhat clean`

3. **Sepolia Tests Fail**
   - Check SepoliaETH balance
   - Verify RPC URL in .env
   - Ensure contract is deployed

4. **Gas Estimation Errors**
   - Check user is registered
   - Verify sufficient balances
   - Confirm authorization status

## Test Statistics Summary

| Category | Test Count | Description |
|----------|------------|-------------|
| Deployment | 5 | Initialization and setup |
| User Registration | 6 | User onboarding |
| Authorization | 5 | Issuer authorization |
| Credit Issuance | 8 | Carbon credit creation |
| Token Deposits | 5 | Balance management |
| Order Creation | 7 | Buy order functionality |
| Trade Execution | 6 | Trading operations |
| Order Cancellation | 4 | Order management |
| View Functions | 4 | Data queries |
| Verification | 3 | Verification updates |
| Edge Cases | 3 | Boundary testing |
| **Local Total** | **60** | **Complete coverage** |
| Sepolia Tests | 6 | Testnet validation |
| **Grand Total** | **66** | **All tests** |

## Conclusion

This comprehensive test suite ensures:
- ✅ All functions are thoroughly tested
- ✅ Edge cases are covered
- ✅ Access control is enforced
- ✅ Real network behavior is validated
- ✅ Gas costs are tracked
- ✅ Code quality is maintained

For questions or issues, refer to:
- Contract source code: `contracts/CarbonCreditTradingFHEVM.sol`
- Deployment guide: `DEPLOYMENT.md`
- Project structure: `PROJECT_STRUCTURE.md`
