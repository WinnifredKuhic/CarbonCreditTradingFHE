# Carbon Credit Trading Platform - Deployment Guide

## Overview

This is a privacy-preserving carbon credit trading platform built with Hardhat and FHEVM (Fully Homomorphic Encryption Virtual Machine). The platform enables private trading of carbon credits with encrypted amounts and prices.

## Table of Contents

- [Prerequisites](#prerequisites)
- [Installation](#installation)
- [Configuration](#configuration)
- [Compilation](#compilation)
- [Testing](#testing)
- [Deployment](#deployment)
- [Verification](#verification)
- [Interaction](#interaction)
- [Simulation](#simulation)
- [Network Information](#network-information)

## Prerequisites

- Node.js >= 18.0.0
- npm or yarn
- MetaMask or similar wallet
- Sepolia testnet ETH (get from [Sepolia Faucet](https://sepoliafaucet.com/))
- Etherscan API key (get from [Etherscan](https://etherscan.io/apis))
- Infura or Alchemy API key (get from [Infura](https://infura.io/) or [Alchemy](https://www.alchemy.com/))

## Installation

1. Clone the repository and install dependencies:

```bash
npm install
```

2. Install dotenv if not already installed:

```bash
npm install dotenv
```

## Configuration

1. Create a `.env` file in the root directory:

```bash
cp .env.example .env
```

2. Fill in your environment variables:

```env
PRIVATE_KEY=your_wallet_private_key_here
SEPOLIA_RPC_URL=https://sepolia.infura.io/v3/YOUR_INFURA_KEY
ETHERSCAN_API_KEY=your_etherscan_api_key_here
```

**Important**: Never commit your `.env` file to version control!

## Compilation

Compile the smart contracts:

```bash
npm run compile
```

This will:
- Compile all Solidity contracts in the `contracts/` directory
- Generate TypeScript bindings in `typechain-types/`
- Create artifacts in `artifacts/`

## Testing

Run the test suite:

```bash
npm run test
```

Run tests with coverage:

```bash
npm run test:coverage
```

## Deployment

### Deploy to Local Network

1. Start a local Hardhat node:

```bash
npm run node
```

2. In a new terminal, deploy the contract:

```bash
npm run deploy:localhost
```

### Deploy to Sepolia Testnet

1. Ensure your wallet has Sepolia ETH
2. Deploy the contract:

```bash
npm run deploy:sepolia
```

The deployment script will:
- Deploy the CarbonCreditTrading contract
- Save deployment information to `deployments/sepolia/CarbonCreditTrading.json`
- Display the contract address and Etherscan link
- Show next steps for verification and interaction

**Expected Output:**

```
🚀 Starting Carbon Credit Trading Platform Deployment...

📡 Network: sepolia (Chain ID: 11155111)
👤 Deployer Address: 0x742d35Cc6634C0532925a3b844Bc9e7595f0bEb
💰 Deployer Balance: 0.5 ETH

📄 Deploying CarbonCreditTrading contract...
✅ CarbonCreditTrading deployed to: 0x1234567890123456789012345678901234567890
⏱️  Deployment time: 15.32s

👑 Contract Owner: 0x742d35Cc6634C0532925a3b844Bc9e7595f0bEb
📊 Initial Stats - Credits: 0, Orders: 0

📝 Deployment info saved to: deployments/sepolia/CarbonCreditTrading.json

🔍 Etherscan: https://sepolia.etherscan.io/address/0x1234567890123456789012345678901234567890

✨ Deployment Complete!
```

## Verification

Verify the contract on Etherscan to make the source code publicly available:

```bash
npm run verify:sepolia <CONTRACT_ADDRESS>
```

Or, if you have a deployment file:

```bash
npm run verify:sepolia
```

**Expected Output:**

```
🔍 Starting Contract Verification...

📄 Loading deployment info from: deployments/sepolia/CarbonCreditTrading.json
📍 Contract Address: 0x1234567890123456789012345678901234567890
📡 Network: sepolia

⏳ Verifying contract on Etherscan...
This may take a few moments...

✅ Contract verified successfully!
🔗 View on Etherscan: https://sepolia.etherscan.io/address/0x1234567890123456789012345678901234567890#code
```

## Interaction

Use the interactive CLI to interact with the deployed contract:

```bash
npm run interact:sepolia
```

### Available Commands

The interactive CLI provides the following options:

1. **Register User** - Register yourself in the system
2. **Check User Registration** - Check if an address is registered
3. **Authorize Issuer** - Authorize an address to issue carbon credits (owner only)
4. **Issue Carbon Credits** - Issue new carbon credits (authorized issuers only)
5. **Deposit Tokens** - Deposit tokens for trading
6. **Create Buy Order** - Create a buy order for carbon credits
7. **Execute Trade** - Execute a pending trade (sellers only)
8. **View My Balances** - View your encrypted balances
9. **View My Credits** - View your carbon credit IDs
10. **View My Orders** - View your order IDs
11. **View Credit Info** - View information about a specific credit
12. **View Order Info** - View information about a specific order
13. **Cancel Order** - Cancel an active order
14. **View System Stats** - View total credits and orders
15. **Check Contract Owner** - View the contract owner

### Example Workflow

```
1. Register User
2. Deposit Tokens (e.g., 100000)
3. Issue Carbon Credits (if you're an authorized issuer)
4. Create Buy Order
5. Execute Trade (as seller)
6. View My Balances
```

## Simulation

Run a full simulation to test the entire workflow:

```bash
npm run simulate:sepolia
```

The simulation will:
1. Register 6 users (deployer, 2 issuers, 3 buyers)
2. Authorize 2 issuers
3. Deposit tokens for all buyers
4. Issue 3 different carbon credits
5. Create 4 buy orders
6. Execute 3 trades
7. Cancel 1 order
8. Display final statistics and balances

**Expected Output:**

```
🎬 Starting Carbon Credit Trading Simulation...

👥 Simulation Participants:
   Deployer: 0x742d35Cc...
   Issuer 1: 0x1234567...
   Issuer 2: 0xabcdef0...
   ...

═══════════════════════════════════════
STEP 1: User Registration
═══════════════════════════════════════
📝 Registering user 1: 0x742d35Cc...
   ✅ Registered
...

✅ Simulation Complete!
```

## Network Information

### Sepolia Testnet

- **Network Name**: Sepolia
- **Chain ID**: 11155111
- **Currency Symbol**: SepoliaETH
- **RPC URL**: https://sepolia.infura.io/v3/YOUR_INFURA_KEY
- **Block Explorer**: https://sepolia.etherscan.io

### Getting Sepolia ETH

1. Visit [Sepolia Faucet](https://sepoliafaucet.com/)
2. Enter your wallet address
3. Request test ETH

## Deployment Information

After deployment, you can find deployment information in:

```
deployments/
└── sepolia/
    └── CarbonCreditTrading.json
```

### Deployment File Structure

```json
{
  "network": "sepolia",
  "chainId": 11155111,
  "contractName": "CarbonCreditTrading",
  "contractAddress": "0x1234567890123456789012345678901234567890",
  "deployer": "0x742d35Cc6634C0532925a3b844Bc9e7595f0bEb",
  "owner": "0x742d35Cc6634C0532925a3b844Bc9e7595f0bEb",
  "deploymentTime": "2025-10-25T10:30:00.000Z",
  "blockNumber": 4567890,
  "transactionHash": "0xabcdef...",
  "compiler": {
    "version": "0.8.24",
    "optimizer": true,
    "runs": 200
  }
}
```

## Etherscan Links

After deployment and verification, your contract will be available at:

**Contract Address:**
```
https://sepolia.etherscan.io/address/<YOUR_CONTRACT_ADDRESS>
```

**Verified Source Code:**
```
https://sepolia.etherscan.io/address/<YOUR_CONTRACT_ADDRESS>#code
```

## Troubleshooting

### Common Issues

1. **Insufficient funds**
   - Error: "sender doesn't have enough funds"
   - Solution: Get more Sepolia ETH from a faucet

2. **Gas estimation failed**
   - Error: "cannot estimate gas"
   - Solution: Check if you're registered and have sufficient permissions

3. **Verification failed**
   - Error: "Etherscan API error"
   - Solution: Wait 1-2 minutes after deployment, ensure ETHERSCAN_API_KEY is set

4. **Network connection issues**
   - Error: "could not detect network"
   - Solution: Check your RPC URL and internet connection

## Scripts Overview

### deploy.js
- Deploys the CarbonCreditTrading contract
- Saves deployment information
- Displays deployment summary

### verify.js
- Verifies the contract on Etherscan
- Makes source code publicly available
- Enables contract interaction on Etherscan

### interact.js
- Provides interactive CLI for contract interaction
- Supports all contract functions
- User-friendly menu interface

### simulate.js
- Runs a complete simulation
- Tests all contract functionality
- Demonstrates typical usage patterns

## Additional Resources

- [Hardhat Documentation](https://hardhat.org/docs)
- [FHEVM Documentation](https://docs.zama.ai/fhevm)
- [Ethers.js Documentation](https://docs.ethers.org/)
- [Sepolia Testnet Information](https://ethereum.org/en/developers/docs/networks/#sepolia)

## Support

For issues or questions:
- Check the troubleshooting section
- Review the contract source code
- Consult Hardhat and FHEVM documentation

## License

MIT License - See LICENSE file for details
