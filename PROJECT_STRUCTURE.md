# Carbon Credit Trading Platform - Project Structure

## Overview

This document provides a complete overview of the Hardhat-based development framework for the Carbon Credit Trading Platform.

## Directory Structure

```
carbon-credit-trading-platform/
├── contracts/
│   └── CarbonCreditTradingFHEVM.sol    # Main smart contract
├── scripts/
│   ├── deploy.js                        # Deployment script
│   ├── verify.js                        # Etherscan verification script
│   ├── interact.js                      # Interactive CLI for contract interaction
│   └── simulate.js                      # Full simulation script
├── deployments/
│   └── sepolia/
│       └── CarbonCreditTrading.json    # Deployment information (generated)
├── test/
│   └── (test files)                     # Contract tests
├── cache/                               # Hardhat cache (generated)
├── artifacts/                           # Compiled contracts (generated)
├── typechain-types/                     # TypeScript bindings (generated)
├── .env                                 # Environment variables (DO NOT COMMIT)
├── .env.example                         # Environment template
├── .gitignore                           # Git ignore file
├── hardhat.config.js                    # Hardhat configuration
├── package.json                         # NPM dependencies and scripts
├── README.md                            # Project overview
├── DEPLOYMENT.md                        # Detailed deployment guide
└── PROJECT_STRUCTURE.md                 # This file
```

## Configuration Files

### hardhat.config.js
Complete Hardhat configuration with:
- Solidity compiler settings (v0.8.24)
- Network configurations (localhost, hardhat, sepolia)
- Etherscan API integration
- Optimizer settings (200 runs)
- Path configurations

### package.json
NPM configuration with scripts:
- `compile` - Compile smart contracts
- `clean` - Clean build artifacts
- `node` - Start local Hardhat network
- `test` - Run test suite
- `test:coverage` - Generate coverage report
- `deploy:localhost` - Deploy to local network
- `deploy:sepolia` - Deploy to Sepolia testnet
- `verify:sepolia` - Verify contract on Etherscan
- `interact:localhost` - Interactive CLI (localhost)
- `interact:sepolia` - Interactive CLI (Sepolia)
- `simulate:localhost` - Run simulation (localhost)
- `simulate:sepolia` - Run simulation (Sepolia)

### .env.example
Environment variable template:
- `PRIVATE_KEY` - Wallet private key
- `SEPOLIA_RPC_URL` - Sepolia RPC endpoint
- `ETHERSCAN_API_KEY` - Etherscan API key
- `HARDHAT_NETWORK` - Default network

## Scripts

### deploy.js
**Purpose**: Deploy CarbonCreditTrading contract to any network

**Features**:
- Network detection
- Balance verification
- Deployment timing
- Automatic deployment info saving
- Etherscan link generation
- Next steps guidance

**Usage**:
```bash
npm run deploy:sepolia
```

**Output**:
- Contract address
- Deployment transaction hash
- Gas used
- Deployment file: `deployments/{network}/CarbonCreditTrading.json`

### verify.js
**Purpose**: Verify contract source code on Etherscan

**Features**:
- Automatic deployment file loading
- Command-line address input
- Error handling with helpful messages
- Duplicate verification detection

**Usage**:
```bash
npm run verify:sepolia <CONTRACT_ADDRESS>
# or
npm run verify:sepolia  # Uses deployment file
```

**Output**:
- Verification status
- Etherscan contract link

### interact.js
**Purpose**: Interactive command-line interface for contract interaction

**Features**:
- 15 interactive commands
- User-friendly menu system
- Real-time transaction feedback
- Automatic deployment file loading
- Balance checking
- Event monitoring

**Available Commands**:
1. Register User
2. Check User Registration
3. Authorize Issuer
4. Issue Carbon Credits
5. Deposit Tokens
6. Create Buy Order
7. Execute Trade
8. View My Balances
9. View My Credits
10. View My Orders
11. View Credit Info
12. View Order Info
13. Cancel Order
14. View System Stats
15. Check Contract Owner

**Usage**:
```bash
npm run interact:sepolia
```

### simulate.js
**Purpose**: Run complete end-to-end simulation

**Features**:
- Automated user registration (6 users)
- Issuer authorization (2 issuers)
- Token deposits for buyers
- Carbon credit issuance (3 credits)
- Buy order creation (4 orders)
- Trade execution (3 trades)
- Order cancellation demo
- Final statistics display

**Simulation Steps**:
1. Register all participants
2. Authorize issuers
3. Deposit tokens for buyers
4. Issue carbon credits
5. Create buy orders
6. Execute trades
7. Cancel an order
8. Display final statistics

**Usage**:
```bash
npm run simulate:sepolia
```

## Contract Architecture

### CarbonCreditTrading.sol

**Key Components**:
- Owner-based access control
- Issuer authorization system
- User registration requirement
- Encrypted balances and amounts
- Private order matching

**Data Structures**:
```solidity
struct CarbonCredit {
    address issuer;
    euint32 encryptedAmount;
    euint32 encryptedPrice;
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
}
```

**Main Functions**:
- `registerUser()` - Register in the system
- `authorizeIssuer(address)` - Authorize credit issuer
- `issueCarbonCredits(...)` - Issue new credits
- `depositTokens(uint64)` - Deposit trading tokens
- `createBuyOrder(...)` - Create buy order
- `executeTrade(uint256)` - Execute trade
- `getMyBalances()` - View encrypted balances
- `getCreditInfo(uint256)` - View credit details
- `getOrderInfo(uint256)` - View order details
- `cancelOrder(uint256)` - Cancel order

## Deployment Information

After deployment, a JSON file is created at:
```
deployments/{network}/CarbonCreditTrading.json
```

**File Contents**:
```json
{
  "network": "sepolia",
  "chainId": 11155111,
  "contractName": "CarbonCreditTrading",
  "contractAddress": "0x...",
  "deployer": "0x...",
  "owner": "0x...",
  "deploymentTime": "2025-10-25T...",
  "blockNumber": 123456,
  "transactionHash": "0x...",
  "compiler": {
    "version": "0.8.24",
    "optimizer": true,
    "runs": 200
  }
}
```

## Network Configuration

### Sepolia Testnet
- **Chain ID**: 11155111
- **RPC URL**: https://sepolia.infura.io/v3/YOUR_KEY
- **Block Explorer**: https://sepolia.etherscan.io
- **Faucet**: https://sepoliafaucet.com/

### Local Network
- **Chain ID**: 31337
- **RPC URL**: http://127.0.0.1:8545
- **Network**: Hardhat local node

## Development Workflow

### Initial Setup
```bash
# 1. Install dependencies
npm install

# 2. Configure environment
cp .env.example .env
# Edit .env with your credentials

# 3. Compile contracts
npm run compile
```

### Local Testing
```bash
# 1. Start local node (terminal 1)
npm run node

# 2. Deploy to local (terminal 2)
npm run deploy:localhost

# 3. Run simulation
npm run simulate:localhost

# 4. Interactive testing
npm run interact:localhost
```

### Testnet Deployment
```bash
# 1. Deploy to Sepolia
npm run deploy:sepolia

# 2. Verify on Etherscan
npm run verify:sepolia

# 3. Interact with contract
npm run interact:sepolia

# 4. Run simulation
npm run simulate:sepolia
```

## Testing

### Unit Tests
```bash
npm run test
```

### Coverage Report
```bash
npm run test:coverage
```

## Security Considerations

1. **Private Keys**: Never commit `.env` file
2. **Test Networks**: Use test wallets only
3. **API Keys**: Keep Etherscan/Infura keys secure
4. **Contract Verification**: Always verify on Etherscan
5. **Gas Optimization**: Contract optimized for 200 runs

## Dependencies

### Core Dependencies
- `ethers@^6.15.0` - Ethereum library
- `@fhevm/solidity@^0.8.0` - FHEVM library

### Development Dependencies
- `hardhat@^3.0.6` - Development framework
- `@nomicfoundation/hardhat-toolbox@^6.1.0` - Hardhat plugins
- `dotenv@^16.4.5` - Environment variables

## Documentation

- **README.md** - Project overview and quick start
- **DEPLOYMENT.md** - Detailed deployment guide
- **PROJECT_STRUCTURE.md** - This file

## Support Resources

- [Hardhat Documentation](https://hardhat.org/docs)
- [FHEVM Documentation](https://docs.zama.ai/fhevm)
- [Ethers.js Documentation](https://docs.ethers.org/)
- [Sepolia Testnet](https://ethereum.org/en/developers/docs/networks/#sepolia)

## Version Information

- **Project Version**: 1.0.0
- **Solidity Version**: 0.8.24
- **Node.js Required**: >= 18.0.0
- **Hardhat Version**: 3.0.6

## License

MIT License

---

**Last Updated**: 2025-10-25
