# CI/CD Pipeline Documentation

## Overview

This document describes the Continuous Integration and Continuous Deployment (CI/CD) pipeline for the Carbon Credit Trading Platform. The pipeline is implemented using GitHub Actions and provides automated testing, code quality checks, security analysis, and deployment verification.

## Table of Contents

- [Pipeline Overview](#pipeline-overview)
- [Workflow Structure](#workflow-structure)
- [Jobs Description](#jobs-description)
- [Configuration Files](#configuration-files)
- [Setup Instructions](#setup-instructions)
- [Badge Integration](#badge-integration)
- [Troubleshooting](#troubleshooting)

## Pipeline Overview

### Trigger Events

The CI/CD pipeline automatically runs on:
- **Push events** to `main` or `develop` branches
- **Pull requests** targeting `main` or `develop` branches

### Node.js Versions

Tests run on multiple Node.js versions to ensure compatibility:
- Node.js 18.x (LTS)
- Node.js 20.x (LTS)
- Node.js 22.x (Current)

### Pipeline Duration

Typical pipeline execution time: **5-10 minutes**

## Workflow Structure

```
.github/workflows/
└── test.yml          # Main CI/CD workflow
```

### Pipeline Jobs

1. **Test** - Run unit tests across multiple Node versions
2. **Lint** - Code quality checks with Solhint
3. **Security** - Security vulnerability scanning
4. **Build** - Build verification and artifact generation
5. **Gas Report** - Gas usage analysis

## Jobs Description

### 1. Test Job

**Purpose**: Execute comprehensive test suite across multiple Node.js versions

**Steps**:
1. Checkout repository
2. Setup Node.js environment
3. Install dependencies with `npm ci`
4. Run Solidity linter (`npm run lint:sol`)
5. Compile contracts (`npm run compile`)
6. Run unit tests (`npm run test`)
7. Generate coverage report (`npm run test:coverage`)
8. Upload coverage to Codecov

**Matrix Strategy**:
```yaml
strategy:
  matrix:
    node-version: [18.x, 20.x, 22.x]
```

**Artifacts**:
- Coverage reports uploaded to Codecov
- Test results displayed in workflow logs

### 2. Lint Job

**Purpose**: Enforce code quality standards for Solidity contracts

**Steps**:
1. Checkout repository
2. Setup Node.js 20.x
3. Install dependencies
4. Run Solhint linter
5. Verify contract compilation

**Linting Rules**:
- Compiler version checks
- Code style enforcement
- Security best practices
- Naming conventions

**Configuration**: `.solhint.json`

### 3. Security Job

**Purpose**: Identify security vulnerabilities in dependencies

**Steps**:
1. Checkout repository
2. Setup Node.js 20.x
3. Install dependencies
4. Run `npm audit` with moderate severity threshold
5. Check for outdated dependencies

**Security Checks**:
- Dependency vulnerability scanning
- Outdated package detection
- Security advisory monitoring

### 4. Build Job

**Purpose**: Verify successful contract compilation and artifact generation

**Steps**:
1. Checkout repository
2. Setup Node.js 20.x
3. Install dependencies
4. Clean previous builds
5. Compile contracts
6. Verify artifacts directory

**Verification**:
- Ensures `artifacts/` directory is created
- Validates contract compilation output
- Checks for build errors

### 5. Gas Report Job

**Purpose**: Track and report gas consumption for contract operations

**Steps**:
1. Checkout repository
2. Setup Node.js 20.x
3. Install dependencies
4. Generate gas report with `REPORT_GAS=true`
5. Upload gas report as artifact

**Output**:
- Gas usage per function
- Deployment costs
- Historical comparison
- Report available as downloadable artifact

## Configuration Files

### 1. GitHub Actions Workflow

**File**: `.github/workflows/test.yml`

Main CI/CD configuration defining:
- Trigger events
- Job definitions
- Step sequences
- Environment variables

### 2. Solhint Configuration

**File**: `.solhint.json`

Solidity linting rules:
```json
{
  "extends": "solhint:recommended",
  "rules": {
    "compiler-version": ["error", "^0.8.0"],
    "func-visibility": ["warn", { "ignoreConstructors": true }],
    "max-line-length": ["warn", 120],
    ...
  }
}
```

**File**: `.solhintignore`

Directories excluded from linting:
- `node_modules/`
- `artifacts/`
- `cache/`
- `coverage/`

### 3. Codecov Configuration

**File**: `codecov.yml`

Coverage reporting settings:
```yaml
coverage:
  precision: 2
  range: "70...100"

  status:
    project:
      target: 80%
    patch:
      target: 70%
```

**Coverage Targets**:
- Project coverage: 80%
- Patch coverage: 70%
- Precision: 2 decimal places

## Setup Instructions

### 1. GitHub Repository Setup

#### Enable GitHub Actions

1. Go to repository **Settings**
2. Navigate to **Actions** → **General**
3. Ensure **Allow all actions** is selected
4. Save changes

### 2. Codecov Integration

#### Get Codecov Token

1. Visit [codecov.io](https://codecov.io/)
2. Sign up/Login with GitHub
3. Add your repository
4. Copy the **CODECOV_TOKEN**

#### Add Token to Repository

1. Go to repository **Settings**
2. Navigate to **Secrets and variables** → **Actions**
3. Click **New repository secret**
4. Name: `CODECOV_TOKEN`
5. Value: Paste your token
6. Click **Add secret**

### 3. Branch Protection Rules

#### Protect Main Branch

1. Go to repository **Settings**
2. Navigate to **Branches**
3. Click **Add rule**
4. Branch name pattern: `main`
5. Enable:
   - ☑ Require status checks to pass
   - ☑ Require branches to be up to date
   - Select required checks:
     - Test (Node 18.x)
     - Test (Node 20.x)
     - Test (Node 22.x)
     - Lint
     - Build
6. Save changes

### 4. Local Development

#### Install Dependencies

```bash
npm install
```

#### Run CI Pipeline Locally

```bash
# Run all CI checks
npm run ci

# Individual checks
npm run lint:sol      # Solidity linting
npm run compile       # Compile contracts
npm run test          # Run tests
npm run test:coverage # Generate coverage
npm run test:gas      # Gas report
```

## Badge Integration

### Add Status Badges to README

#### Test Status Badge

```markdown
![Test Suite](https://github.com/YOUR_USERNAME/YOUR_REPO/actions/workflows/test.yml/badge.svg)
```

#### Coverage Badge

```markdown
[![codecov](https://codecov.io/gh/YOUR_USERNAME/YOUR_REPO/branch/main/graph/badge.svg)](https://codecov.io/gh/YOUR_USERNAME/YOUR_REPO)
```

#### License Badge

```markdown
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
```

### Example README Header

```markdown
# Carbon Credit Trading Platform

![Test Suite](https://github.com/YOUR_USERNAME/YOUR_REPO/actions/workflows/test.yml/badge.svg)
[![codecov](https://codecov.io/gh/YOUR_USERNAME/YOUR_REPO/branch/main/graph/badge.svg)](https://codecov.io/gh/YOUR_USERNAME/YOUR_REPO)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
```

## NPM Scripts

### Core Scripts

| Script | Description |
|--------|-------------|
| `npm run compile` | Compile Solidity contracts |
| `npm run clean` | Clean build artifacts |
| `npm run test` | Run test suite |
| `npm run test:coverage` | Generate coverage report |
| `npm run test:gas` | Generate gas usage report |

### Linting Scripts

| Script | Description |
|--------|-------------|
| `npm run lint:sol` | Lint Solidity files |
| `npm run lint:sol:fix` | Auto-fix linting issues |

### CI Script

| Script | Description |
|--------|-------------|
| `npm run ci` | Run complete CI pipeline locally |

### Deployment Scripts

| Script | Description |
|--------|-------------|
| `npm run deploy:localhost` | Deploy to local network |
| `npm run deploy:sepolia` | Deploy to Sepolia testnet |
| `npm run verify:sepolia` | Verify on Etherscan |

## Workflow Outputs

### Test Job Output

```
✓ Test Job
  ✓ Checkout repository
  ✓ Setup Node.js 20.x
  ✓ Install dependencies
  ✓ Run Solidity linter
  ✓ Compile contracts
  ✓ Run unit tests (60 tests passed)
  ✓ Generate coverage report (85% coverage)
  ✓ Upload to Codecov
```

### Lint Job Output

```
✓ Lint Job
  ✓ Checkout repository
  ✓ Setup Node.js
  ✓ Install dependencies
  ✓ Run Solhint (0 errors, 2 warnings)
  ✓ Check contract size
```

### Security Job Output

```
✓ Security Job
  ✓ Checkout repository
  ✓ Setup Node.js
  ✓ Install dependencies
  ✓ Run npm audit (0 vulnerabilities)
  ✓ Check outdated dependencies
```

## Troubleshooting

### Common Issues

#### 1. Test Failures

**Issue**: Tests fail in CI but pass locally

**Solutions**:
- Check Node.js version compatibility
- Verify environment variables
- Review test logs in Actions tab
- Ensure clean state between tests

#### 2. Coverage Upload Fails

**Issue**: Codecov upload fails

**Solutions**:
- Verify `CODECOV_TOKEN` is set correctly
- Check codecov.yml configuration
- Ensure coverage files are generated
- Review Codecov dashboard for errors

#### 3. Lint Errors

**Issue**: Solhint reports errors

**Solutions**:
```bash
# View linting errors
npm run lint:sol

# Auto-fix issues
npm run lint:sol:fix

# Review .solhint.json rules
```

#### 4. Build Failures

**Issue**: Contract compilation fails

**Solutions**:
- Check Solidity compiler version
- Verify contract syntax
- Review hardhat.config.js
- Clear cache: `npm run clean`

#### 5. Dependency Issues

**Issue**: npm install fails

**Solutions**:
```bash
# Clear cache
npm cache clean --force

# Remove lock file
rm package-lock.json

# Reinstall
npm install
```

### Debug Mode

Enable detailed logging:

```yaml
# Add to workflow step
- name: Run tests with debug
  run: npm run test
  env:
    DEBUG: '*'
```

### Workflow Re-runs

Re-run failed jobs:
1. Go to **Actions** tab
2. Select failed workflow
3. Click **Re-run jobs**
4. Choose **Re-run failed jobs** or **Re-run all jobs**

## Best Practices

### 1. Commit Messages

Follow conventional commits:
```
feat: add new feature
fix: resolve bug
test: update tests
docs: update documentation
chore: maintenance tasks
```

### 2. Pull Request Checks

Before merging:
- ✅ All CI jobs pass
- ✅ Code reviewed
- ✅ Coverage maintained/improved
- ✅ No security vulnerabilities
- ✅ Documentation updated

### 3. Dependency Updates

Regular maintenance:
```bash
# Check for updates
npm outdated

# Update dependencies
npm update

# Audit security
npm audit fix
```

### 4. Cache Management

Improve CI performance:
- Use `npm ci` instead of `npm install`
- Leverage GitHub Actions cache
- Clean artifacts between runs

## Security Considerations

### Secret Management

**Never commit**:
- Private keys
- API keys
- Passwords
- Environment variables

**Use GitHub Secrets for**:
- `CODECOV_TOKEN`
- `SEPOLIA_RPC_URL`
- `ETHERSCAN_API_KEY`
- `PRIVATE_KEY`

### Audit Frequency

- **Daily**: Automated npm audit in CI
- **Weekly**: Manual dependency review
- **Monthly**: Security best practices review

## Monitoring

### GitHub Actions Dashboard

Monitor workflow runs:
1. Go to **Actions** tab
2. View workflow history
3. Check success/failure rates
4. Download artifacts

### Codecov Dashboard

Monitor coverage trends:
1. Visit Codecov dashboard
2. View coverage over time
3. Review file-level coverage
4. Identify untested code

## Continuous Improvement

### Metrics to Track

- Test pass rate
- Code coverage percentage
- Build time
- Gas costs
- Dependency health

### Optimization Strategies

1. **Parallel Jobs**: Run independent jobs concurrently
2. **Caching**: Cache dependencies and build artifacts
3. **Selective Testing**: Run only affected tests
4. **Matrix Testing**: Test across environments efficiently

## Additional Resources

- [GitHub Actions Documentation](https://docs.github.com/en/actions)
- [Codecov Documentation](https://docs.codecov.com/)
- [Solhint Documentation](https://github.com/protofire/solhint)
- [Hardhat Documentation](https://hardhat.org/docs)

## Support

For CI/CD issues:
1. Check workflow logs in Actions tab
2. Review this documentation
3. Check GitHub Actions status page
4. Review Hardhat and testing documentation

---

**Last Updated**: 2025-10-25
**Pipeline Version**: 1.0.0
