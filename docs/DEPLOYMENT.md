# Deployment Guide - Carbon Credit Trading Platform

> Complete deployment instructions for the Carbon Credit Trading Platform with FHE

---

## Table of Contents

- [Prerequisites](#prerequisites)
- [Environment Setup](#environment-setup)
- [Local Deployment](#local-deployment)
- [Sepolia Testnet Deployment](#sepolia-testnet-deployment)
- [Contract Verification](#contract-verification)
- [Post-Deployment Steps](#post-deployment-steps)
- [Troubleshooting](#troubleshooting)

---

## Prerequisites

### Required Software

- **Node.js** >= 18.0.0
- **npm** >= 9.0.0
- **Git** for version control
- **MetaMask** browser extension (for testing)

### Required Accounts

1. **Infura Account** - For Sepolia RPC access
   - Sign up at https://infura.io
   - Create a new project
   - Get your project ID

2. **Etherscan Account** - For contract verification
   - Sign up at https://etherscan.io
   - Generate API key at https://etherscan.io/myapikey

3. **Wallet Setup**
   - Private key with Sepolia ETH
   - Get testnet ETH from https://sepoliafaucet.com

---

## Environment Setup

### 1. Clone Repository

```bash
git clone https://github.com/WinnifredKuhic/CarbonCreditTradingFHE.git
cd CarbonCreditTradingFHE
```

### 2. Install Dependencies

```bash
npm install
```

### 3. Configure Environment

Create `.env` file from template:

```bash
cp .env.example .env
```

Edit `.env` with your configuration:

```env
# ===================================
# NETWORK CONFIGURATION
# ===================================
SEPOLIA_RPC_URL=https://sepolia.infura.io/v3/YOUR_INFURA_PROJECT_ID
PRIVATE_KEY=0xYOUR_PRIVATE_KEY_HERE

# ===================================
# API KEYS
# ===================================
ETHERSCAN_API_KEY=YOUR_ETHERSCAN_API_KEY
INFURA_API_KEY=YOUR_INFURA_PROJECT_ID

# ===================================
# CONTRACT CONFIGURATION
# ===================================
OWNER_ADDRESS=0xYOUR_OWNER_ADDRESS
PAUSER_ADDRESS=0xYOUR_PAUSER_ADDRESS

# ===================================
# GAS CONFIGURATION
# ===================================
GAS_PRICE=20
MAX_FEE_PER_GAS=50
MAX_PRIORITY_FEE_PER_GAS=2

# ===================================
# OPTIMIZER SETTINGS
# ===================================
OPTIMIZER_RUNS=800
ENABLE_YUL_OPTIMIZER=true

# ===================================
# REPORTING
# ===================================
REPORT_GAS=true
```

### 4. Verify Configuration

```bash
# Check Node.js version
node --version  # Should be >= 18.0.0

# Check npm version
npm --version   # Should be >= 9.0.0

# Verify environment variables
node -e "require('dotenv').config(); console.log('RPC:', process.env.SEPOLIA_RPC_URL ? '✓' : '✗')"
```

---

## Local Deployment

### 1. Start Local Hardhat Node

```bash
# Terminal 1: Start local node
npx hardhat node
```

This will:
- Start a local Ethereum node on port 8545
- Create 20 test accounts with 10,000 ETH each
- Display account addresses and private keys

### 2. Deploy to Local Network

```bash
# Terminal 2: Deploy contract
npm run deploy:localhost
```

Expected output:
```
Deploying CarbonCreditTradingFHEVM...
Contract deployed to: 0x5FbDB2315678afecb367f032d93F642f64180aa3
Deployment saved to: deployments/localhost/CarbonCreditTradingFHEVM.json
```

### 3. Interact with Local Contract

```bash
npm run interact:localhost
```

This opens an interactive CLI with 15 commands:
1. Register User
2. Authorize Issuer
3. Issue Carbon Credit
4. Deposit Tokens
5. Create Buy Order
6. Execute Trade
7. View User Info
8. View Credit Details
9. View Order Details
10. View Balance
11. Cancel Order
12. Get Credit Count
13. Get Order Count
14. Get User Credit Ownership
15. Exit

### 4. Run Full Simulation

```bash
npm run simulate:localhost
```

This runs a complete workflow demonstrating:
- User registration
- Issuer authorization
- Credit issuance
- Token deposits
- Order creation
- Trade execution
- Balance verification

---

## Sepolia Testnet Deployment

### 1. Get Sepolia ETH

Visit Sepolia faucets to get testnet ETH:
- https://sepoliafaucet.com
- https://sepolia-faucet.pk910.de
- https://faucet.quicknode.com/ethereum/sepolia

Recommended: Get at least 0.5 Sepolia ETH for deployment and testing.

### 2. Verify Network Connection

```bash
# Check RPC connection
node -e "const ethers = require('ethers'); const provider = new ethers.JsonRpcProvider(process.env.SEPOLIA_RPC_URL); provider.getBlockNumber().then(b => console.log('Latest block:', b))"
```

### 3. Check Wallet Balance

```bash
node -e "require('dotenv').config(); const ethers = require('ethers'); const provider = new ethers.JsonRpcProvider(process.env.SEPOLIA_RPC_URL); const wallet = new ethers.Wallet(process.env.PRIVATE_KEY, provider); wallet.getBalance().then(b => console.log('Balance:', ethers.formatEther(b), 'ETH'))"
```

### 4. Deploy to Sepolia

```bash
npm run deploy:sepolia
```

Expected output:
```
Deploying to Sepolia testnet...
Deployer address: 0xYourAddress
Deployer balance: 0.5 ETH

Deploying CarbonCreditTradingFHEVM...
Deployment transaction: 0xTRANSACTION_HASH
Waiting for confirmations...

Contract deployed to: 0xCONTRACT_ADDRESS
Transaction hash: 0xTRANSACTION_HASH
Block number: 12345678
Gas used: 3,500,000
Deployment cost: 0.07 ETH

Deployment saved to: deployments/sepolia/CarbonCreditTradingFHEVM.json
Etherscan: https://sepolia.etherscan.io/address/0xCONTRACT_ADDRESS
```

### 5. Verify Deployment Information

```bash
# Check deployment file
cat deployments/sepolia/CarbonCreditTradingFHEVM.json
```

Expected contents:
```json
{
  "address": "0xCONTRACT_ADDRESS",
  "transactionHash": "0xTRANSACTION_HASH",
  "blockNumber": 12345678,
  "deployer": "0xDEPLOYER_ADDRESS",
  "timestamp": "2025-10-26T12:00:00.000Z",
  "network": "sepolia",
  "chainId": 11155111,
  "gasUsed": "3500000",
  "effectiveGasPrice": "20000000000"
}
```

---

## Contract Verification

### 1. Automatic Verification (Recommended)

```bash
npm run verify:sepolia
```

The script will:
1. Read deployment information from `deployments/sepolia/`
2. Submit contract source code to Etherscan
3. Wait for verification to complete
4. Display verification URL

Expected output:
```
Verifying contract on Etherscan...
Contract address: 0xCONTRACT_ADDRESS

Submitting verification request...
Verification submitted successfully
Verification ID: abc123def456

Waiting for verification...
✓ Contract verified successfully

Verification URL: https://sepolia.etherscan.io/address/0xCONTRACT_ADDRESS#code
```

### 2. Manual Verification

If automatic verification fails, verify manually on Etherscan:

1. Visit https://sepolia.etherscan.io/verifyContract
2. Enter contract address
3. Select:
   - Compiler Type: Solidity (Single file)
   - Compiler Version: v0.8.24+commit.e11b9ed9
   - License: MIT
4. Paste contract source code from `contracts/CarbonCreditTradingFHEVM.sol`
5. Optimization: Yes, with 800 runs
6. Constructor Arguments: (none)
7. Submit verification

### 3. Verify on Block Explorer

Visit the Etherscan URL to confirm:
- ✓ Contract source code is visible
- ✓ "Read Contract" tab shows all view functions
- ✓ "Write Contract" tab shows all write functions
- ✓ Green checkmark appears next to contract

---

## Post-Deployment Steps

### 1. Update Configuration

Save contract address to `.env`:

```env
CONTRACT_ADDRESS=0xYOUR_DEPLOYED_CONTRACT_ADDRESS
```

### 2. Authorize Initial Issuer

```bash
npm run interact:sepolia

# Select option 2: Authorize Issuer
# Enter issuer address
```

### 3. Test Basic Functionality

```bash
# Run interactive CLI
npm run interact:sepolia

# Test workflow:
# 1. Register User
# 2. Authorize Issuer (owner only)
# 3. Issue Carbon Credit
# 4. Deposit Tokens
# 5. Create Buy Order
# 6. Execute Trade
```

### 4. Run Integration Tests

```bash
npm run test:sepolia
```

This runs 6 integration tests:
- Deployment validation
- User registration
- Issuer authorization
- Credit issuance
- Token operations
- Basic trade execution

### 5. Monitor Gas Usage

```bash
REPORT_GAS=true npm run test:sepolia
```

Expected gas costs:
```
·-----------------------------------------|--------------------------|-------------|
|  Solc version: 0.8.24                   ·  Optimizer enabled: true ·  Runs: 800  │
··········································|··························|·············
|  Methods                                                                         │
················|·························|··············|·············|·············
|  Contract     ·  Method                 ·  Min         ·  Max        ·  Avg      │
················|·························|··············|·············|·············
|  CarbonCredit ·  registerUser           ·      180000  ·     185000  ·    182500 │
················|·························|··············|·············|·············
|  CarbonCredit ·  authorizeIssuer        ·       85000  ·      90000  ·     87500 │
················|·························|··············|·············|·············
|  CarbonCredit ·  issueCredit            ·      280000  ·     285000  ·    282500 │
················|·························|··············|·············|·············
|  CarbonCredit ·  depositTokens          ·      110000  ·     115000  ·    112500 │
················|·························|··············|·············|·············
|  CarbonCredit ·  createBuyOrder         ·      230000  ·     235000  ·    232500 │
················|·························|··············|·············|·············
|  CarbonCredit ·  executeTrade           ·      320000  ·     325000  ·    322500 │
················|·························|··············|·············|·············
```

### 6. Document Deployment

Create deployment record:

```markdown
# Deployment Record - Sepolia

**Date**: 2025-10-26
**Network**: Sepolia (Chain ID: 11155111)
**Contract Address**: 0xYOUR_CONTRACT_ADDRESS
**Deployer**: 0xYOUR_DEPLOYER_ADDRESS
**Transaction Hash**: 0xDEPLOYMENT_TX_HASH
**Block Number**: 12345678
**Etherscan**: https://sepolia.etherscan.io/address/0xYOUR_CONTRACT_ADDRESS
**Gas Used**: 3,500,000
**Deployment Cost**: 0.07 ETH
```

---

## Troubleshooting

### Common Issues

#### Issue 1: Insufficient Funds

**Error**:
```
Error: insufficient funds for intrinsic transaction cost
```

**Solution**:
```bash
# Check balance
node -e "require('dotenv').config(); const ethers = require('ethers'); const provider = new ethers.JsonRpcProvider(process.env.SEPOLIA_RPC_URL); const wallet = new ethers.Wallet(process.env.PRIVATE_KEY, provider); wallet.getBalance().then(b => console.log('Balance:', ethers.formatEther(b), 'ETH'))"

# Get more Sepolia ETH from faucets
```

#### Issue 2: Invalid RPC URL

**Error**:
```
Error: could not detect network
```

**Solution**:
```bash
# Test RPC connection
curl -X POST https://sepolia.infura.io/v3/YOUR_PROJECT_ID \
  -H "Content-Type: application/json" \
  -d '{"jsonrpc":"2.0","method":"eth_blockNumber","params":[],"id":1}'

# Update .env with correct RPC URL
```

#### Issue 3: Verification Failed

**Error**:
```
Error: Verification failed
```

**Solution**:
1. Wait 1-2 minutes after deployment
2. Ensure contract is fully confirmed (6 confirmations recommended)
3. Try manual verification on Etherscan
4. Check Etherscan API key is valid

#### Issue 4: Gas Price Too Low

**Error**:
```
Error: transaction underpriced
```

**Solution**:
```bash
# Update .env with higher gas price
GAS_PRICE=30
MAX_FEE_PER_GAS=60
MAX_PRIORITY_FEE_PER_GAS=3

# Or let hardhat auto-calculate
# Remove gas settings from hardhat.config.js
```

#### Issue 5: Nonce Too Low

**Error**:
```
Error: nonce has already been used
```

**Solution**:
```bash
# Reset account nonce
# In hardhat.config.js, add:
accounts: {
  count: 10,
  accountsBalance: "10000000000000000000000",
  mnemonic: "test test test...",
  initialIndex: 0
}

# Or wait for pending transactions to confirm
```

### Debug Mode

Enable debug output:

```bash
# Verbose deployment
DEBUG=* npm run deploy:sepolia

# Hardhat debug
npx hardhat run scripts/deploy.mjs --network sepolia --verbose

# Show transaction details
HARDHAT_VERBOSE=true npm run deploy:sepolia
```

### Network Status Check

```bash
# Check Sepolia network status
curl https://sepolia.etherscan.io/api?module=proxy&action=eth_blockNumber

# Check gas prices
curl https://sepolia.etherscan.io/api?module=gastracker&action=gasoracle
```

### Get Support

If issues persist:

1. **Check Logs**: Review deployment logs in `deployments/sepolia/`
2. **Etherscan**: Check transaction status on https://sepolia.etherscan.io
3. **GitHub Issues**: Report at https://github.com/WinnifredKuhic/CarbonCreditTradingFHEVM/issues
4. **Community**: Ask in Zama Discord or Hardhat community

---

## Security Checklist

Before deploying to production:

- [ ] Private keys stored securely (use hardware wallet or KMS)
- [ ] Environment variables not committed to git
- [ ] Multi-signature wallet for owner role
- [ ] Contract audited by professionals
- [ ] Rate limits configured appropriately
- [ ] Pause mechanism tested
- [ ] Access control properly configured
- [ ] Gas limits set conservatively
- [ ] Backup deployment scripts
- [ ] Monitoring and alerting set up

---

## Deployment Costs

### Estimated Gas Costs (at 20 gwei)

| Operation | Gas Used | Cost (ETH) | Cost (USD @ $2000/ETH) |
|-----------|----------|------------|------------------------|
| **Contract Deployment** | 3,500,000 | 0.07 | $140 |
| User Registration | 180,000 | 0.0036 | $7.20 |
| Authorize Issuer | 85,000 | 0.0017 | $3.40 |
| Issue Credit | 280,000 | 0.0056 | $11.20 |
| Deposit Tokens | 110,000 | 0.0022 | $4.40 |
| Create Order | 230,000 | 0.0046 | $9.20 |
| Execute Trade | 320,000 | 0.0064 | $12.80 |

**Total for full workflow**: ~0.10 ETH ($200)

---

## Deployment Checklist

### Pre-Deployment

- [ ] Install Node.js >= 18.0.0
- [ ] Install all dependencies (`npm install`)
- [ ] Configure `.env` file
- [ ] Get Sepolia ETH (minimum 0.5 ETH)
- [ ] Get Infura API key
- [ ] Get Etherscan API key
- [ ] Test local deployment
- [ ] Run full test suite
- [ ] Review gas costs

### Deployment

- [ ] Deploy to Sepolia (`npm run deploy:sepolia`)
- [ ] Verify deployment information
- [ ] Verify contract on Etherscan
- [ ] Save contract address
- [ ] Document deployment details

### Post-Deployment

- [ ] Authorize initial issuer
- [ ] Run integration tests
- [ ] Test all functions via CLI
- [ ] Monitor gas usage
- [ ] Create deployment record
- [ ] Update documentation
- [ ] Notify team members

---

## Additional Resources

### Zama Resources
- [FHEVM Documentation](https://docs.zama.ai/fhevm)
- [FHEVM GitHub](https://github.com/zama-ai/fhevm)
- [Zama Discord](https://discord.fhe.org)

### Hardhat Resources
- [Hardhat Documentation](https://hardhat.org/docs)
- [Hardhat Network](https://hardhat.org/hardhat-network)
- [Hardhat Deploy Plugin](https://github.com/wighawag/hardhat-deploy)

### Sepolia Resources
- [Sepolia Testnet Info](https://sepolia.dev)
- [Sepolia Faucets](https://sepoliafaucet.com)
- [Sepolia Explorer](https://sepolia.etherscan.io)

---

## License

MIT License - See LICENSE file for details.

---

**Last Updated**: 2025-10-26
**Version**: 1.0.0
**Network**: Sepolia (11155111)
**Framework**: Hardhat 3.0.6
**Solidity**: 0.8.24

**Built for the Zama FHE Challenge**

**Powered by Zama FHEVM** 🔐
