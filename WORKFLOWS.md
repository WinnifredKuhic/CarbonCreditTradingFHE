# GitHub Actions Workflows Documentation

## Overview

This document describes all GitHub Actions workflows configured for the Carbon Credit Trading Platform, including automated testing, deployment, and PR management.

## Table of Contents

- [Workflow Files](#workflow-files)
- [Test Workflow](#test-workflow)
- [Deployment Workflow](#deployment-workflow)
- [Pull Request Workflow](#pull-request-workflow)
- [Workflow Triggers](#workflow-triggers)
- [Environment Variables](#environment-variables)
- [Secrets Configuration](#secrets-configuration)
- [Badge Integration](#badge-integration)

## Workflow Files

```
.github/
├── workflows/
│   ├── test.yml          # Main test suite
│   ├── deploy.yml        # Deployment workflow
│   └── pr.yml            # PR validation
├── PULL_REQUEST_TEMPLATE.md
└── ISSUE_TEMPLATE/
    ├── bug_report.md
    └── feature_request.md
```

## Test Workflow

**File**: `.github/workflows/test.yml`

### Purpose

Comprehensive testing across multiple Node.js versions with code quality checks, security scanning, and coverage reporting.

### Triggers

```yaml
on:
  push:
    branches: [main, develop]
  pull_request:
    branches: [main, develop]
```

### Jobs

#### 1. Test Suite (Matrix)

Runs tests on multiple Node.js versions:
- Node.js 18.x (LTS)
- Node.js 20.x (LTS)
- Node.js 22.x (Current)

**Steps**:
1. Checkout code
2. Setup Node.js environment
3. Install dependencies
4. Lint Solidity files
5. Compile contracts
6. Run unit tests
7. Generate coverage report
8. Upload to Codecov

#### 2. Code Quality (Lint)

**Steps**:
- Run Solhint linter
- Check contract compilation
- Verify code style

#### 3. Security Analysis

**Steps**:
- Run npm audit
- Check outdated dependencies
- Security vulnerability scan

#### 4. Build Verification

**Steps**:
- Clean previous builds
- Compile contracts
- Verify artifacts
- Check build output

#### 5. Gas Report

**Steps**:
- Generate gas usage report
- Upload as artifact
- Compare with baseline

### Artifacts

- Coverage reports → Codecov
- Gas reports → GitHub Artifacts
- Build artifacts → GitHub Artifacts

## Deployment Workflow

**File**: `.github/workflows/deploy.yml`

### Purpose

Manual deployment workflow for deploying contracts to different networks with optional Etherscan verification.

### Triggers

```yaml
on:
  workflow_dispatch:
    inputs:
      network:
        type: choice
        options: [sepolia, localhost]
      verify:
        type: boolean
        default: true
```

### Manual Trigger

1. Go to **Actions** tab
2. Select **Deploy to Sepolia**
3. Click **Run workflow**
4. Choose network and verification options
5. Click **Run workflow** button

### Steps

1. **Checkout** - Get latest code
2. **Setup** - Configure Node.js environment
3. **Environment** - Load secrets
4. **Compile** - Build contracts
5. **Deploy** - Deploy to selected network
6. **Verify** - Verify on Etherscan (optional)
7. **Artifacts** - Upload deployment info
8. **Summary** - Create deployment report

### Outputs

- Deployment artifacts
- Contract addresses
- Etherscan links
- Transaction hashes

## Pull Request Workflow

**File**: `.github/workflows/pr.yml`

### Purpose

Automated checks and validations for pull requests, including contract size checks and dependency reviews.

### Triggers

```yaml
on:
  pull_request:
    types: [opened, synchronize, reopened]
    branches: [main, develop]
```

### Jobs

#### 1. Validate PR

**Steps**:
- Check for breaking changes
- Lint Solidity files
- Compile contracts
- Run tests
- Generate coverage
- Upload to Codecov
- Comment PR with results

**PR Comment Example**:
```markdown
## PR Check Results ✅

**Tests**: Passed
**Compilation**: Success
**Linting**: Checked

## Coverage Summary
- Lines: 85%
- Statements: 84%
- Functions: 90%
- Branches: 78%

---
*Automated check from CI/CD pipeline*
```

#### 2. Contract Size Check

**Steps**:
- Compile contracts
- Calculate contract sizes
- Check against size limits (24KB)
- Create size report

**Output**:
```
| Contract | Size (KB) | Status |
|----------|-----------|--------|
| CarbonCreditTrading | 18 KB | ✅ |
```

#### 3. Dependency Review

**Steps**:
- Review new dependencies
- Check for vulnerabilities
- Fail on moderate+ severity

## Workflow Triggers

### Automatic Triggers

| Event | Workflow | Branches |
|-------|----------|----------|
| Push | test.yml | main, develop |
| Pull Request | test.yml, pr.yml | main, develop |
| Schedule | test.yml | main (nightly) |

### Manual Triggers

| Workflow | Trigger | Purpose |
|----------|---------|---------|
| deploy.yml | workflow_dispatch | Manual deployment |

## Environment Variables

### Required for Tests

```bash
# No environment variables required for basic tests
# Tests run with mock data
```

### Required for Deployment

```bash
SEPOLIA_RPC_URL=https://sepolia.infura.io/v3/YOUR_KEY
PRIVATE_KEY=0x...
ETHERSCAN_API_KEY=YOUR_KEY
```

## Secrets Configuration

### GitHub Repository Secrets

Go to **Settings** → **Secrets and variables** → **Actions**

#### Required Secrets

| Secret Name | Description | Required For |
|-------------|-------------|--------------|
| `CODECOV_TOKEN` | Codecov upload token | Coverage uploads |
| `SEPOLIA_RPC_URL` | Sepolia RPC endpoint | Deployment |
| `PRIVATE_KEY` | Deployer private key | Deployment |
| `ETHERSCAN_API_KEY` | Etherscan API key | Contract verification |

#### Setting Up Secrets

1. **Get Codecov Token**:
   - Visit [codecov.io](https://codecov.io/)
   - Add your repository
   - Copy token

2. **Get RPC URL**:
   - Sign up at [Infura](https://infura.io/) or [Alchemy](https://www.alchemy.com/)
   - Create project
   - Copy Sepolia endpoint

3. **Get Private Key**:
   - Export from MetaMask (test wallet only!)
   - **Never use mainnet wallet**

4. **Get Etherscan API Key**:
   - Sign up at [Etherscan](https://etherscan.io/)
   - Create API key
   - Copy key

#### Adding Secrets

```bash
# Via GitHub UI
Settings → Secrets → New repository secret

# Name: CODECOV_TOKEN
# Value: <paste token>

# Repeat for all secrets
```

## Badge Integration

### Status Badges

Add to your `README.md`:

```markdown
# Carbon Credit Trading Platform

![Tests](https://github.com/YOUR_USERNAME/YOUR_REPO/actions/workflows/test.yml/badge.svg)
![Deploy](https://github.com/YOUR_USERNAME/YOUR_REPO/actions/workflows/deploy.yml/badge.svg)
[![codecov](https://codecov.io/gh/YOUR_USERNAME/YOUR_REPO/branch/main/graph/badge.svg)](https://codecov.io/gh/YOUR_USERNAME/YOUR_REPO)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)
```

### Custom Badges

```markdown
![Node.js Version](https://img.shields.io/badge/node-%3E%3D18.0.0-brightgreen)
![Solidity](https://img.shields.io/badge/Solidity-0.8.24-blue)
![Hardhat](https://img.shields.io/badge/Built%20with-Hardhat-yellow)
```

## Workflow Execution Examples

### Test Workflow Success

```
✓ Test (Node 18.x)
  ✓ Checkout repository (1s)
  ✓ Setup Node.js 18.x (3s)
  ✓ Install dependencies (25s)
  ✓ Run Solidity linter (5s)
  ✓ Compile contracts (15s)
  ✓ Run unit tests (30s) - 60 tests passed
  ✓ Generate coverage (10s) - 85% coverage
  ✓ Upload to Codecov (5s)

✓ Test (Node 20.x) - Similar to above
✓ Test (Node 22.x) - Similar to above
✓ Lint - Passed
✓ Security - No vulnerabilities
✓ Build - Artifacts created
✓ Gas Report - Generated

Total Duration: 7 minutes
```

### Deployment Workflow

```
✓ Deploy to Sepolia
  ✓ Checkout repository (1s)
  ✓ Setup Node.js 20.x (3s)
  ✓ Install dependencies (25s)
  ✓ Setup environment (1s)
  ✓ Compile contracts (15s)
  ✓ Deploy to sepolia (45s)
  ✓ Verify on Etherscan (30s)
  ✓ Upload deployment artifacts (5s)
  ✓ Create deployment summary (1s)

Total Duration: 2 minutes

Deployment Summary:
- Network: sepolia
- Contract Address: 0x1234...
- Etherscan: https://sepolia.etherscan.io/address/0x1234...
- Verified: ✅
```

### PR Workflow

```
✓ Validate PR
  ✓ All checks passed
  ✓ Coverage: 85%
  ✓ Comment added to PR

✓ Contract Size Check
  ✓ CarbonCreditTrading: 18 KB ✅

✓ Dependency Review
  ✓ No new vulnerabilities
```

## Monitoring

### GitHub Actions Dashboard

1. Go to **Actions** tab
2. View all workflow runs
3. Check status and logs
4. Download artifacts

### Codecov Dashboard

1. Visit your Codecov project
2. View coverage over time
3. Check file-level coverage
4. Review PR coverage impact

## Troubleshooting

### Common Issues

#### 1. Workflow Fails to Start

**Cause**: GitHub Actions not enabled

**Solution**:
```bash
Settings → Actions → General
Enable "Allow all actions"
```

#### 2. Secret Not Found

**Cause**: Secret not configured

**Solution**:
```bash
Settings → Secrets → Actions
Add missing secret
```

#### 3. Test Failures

**Cause**: Environment differences

**Solution**:
```bash
# Check Node.js version
# Review test logs
# Verify dependencies
```

#### 4. Deployment Fails

**Cause**: Insufficient funds or wrong network

**Solution**:
```bash
# Check wallet balance
# Verify RPC URL
# Confirm network configuration
```

### Debug Mode

Enable verbose logging:

```yaml
- name: Run tests
  run: npm run test
  env:
    DEBUG: '*'
    VERBOSE: true
```

## Best Practices

### 1. Branch Strategy

```
main (protected)
  ← develop (protected)
    ← feature/* (PR required)
    ← bugfix/* (PR required)
```

### 2. PR Process

1. Create feature branch
2. Make changes
3. Run tests locally: `npm run ci`
4. Push and create PR
5. Wait for CI checks
6. Request review
7. Merge when approved and green

### 3. Deployment Process

1. Merge to develop
2. Test on localhost
3. Manually trigger deploy workflow
4. Select network
5. Verify deployment
6. Update documentation

### 4. Security

- Never commit secrets
- Use test wallets only
- Regular dependency updates
- Security audit reviews

## Maintenance

### Weekly Tasks

- [ ] Review failed workflows
- [ ] Check dependency updates
- [ ] Review security alerts
- [ ] Update documentation

### Monthly Tasks

- [ ] Audit workflow efficiency
- [ ] Update Node.js versions
- [ ] Review coverage trends
- [ ] Optimize CI times

## Additional Resources

- [GitHub Actions Docs](https://docs.github.com/en/actions)
- [Codecov Documentation](https://docs.codecov.com/)
- [Hardhat Documentation](https://hardhat.org/)
- [Etherscan API Docs](https://docs.etherscan.io/)

---

**Last Updated**: 2025-10-25
**Version**: 1.0.0
