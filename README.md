# SUI X Oracle
SUI X Oracle is safe, because it gets price data from multiple sources and uses a decentralized oracle to aggregate the data.

## Supported oracles
- Supra
- Switchboard
- Pyth

## How it works
1. Get price data from multiple sources
2. Use Pyth as the primary source
3. Check Pyth price data with Supra and Switchboard, if the price difference is within the threshold, use the Pyth price data
4. If the price difference is not within the threshold, reject the transaction. Because the price data is manipulated by the oracle.

## Installation

```bash
# Clone the repository
git clone https://github.com/scallop-io/sui-x-oracle.git
cd sui-x-oracle

# Install dependencies
pnpm install

# Configure environment variables
cp .env.example .env
# Edit the .env file to set your SECRET_KEY and SUI_NETWORK_TYPE
```

## Configuration

Set the following environment variables in the `.env` file:

```
# SUI private key (hexadecimal format, with or without 0x prefix)
SECRET_KEY=0x0000000000000000000000000000000000000000000000000000000000000000

# SUI network type: localnet, devnet, testnet, mainnet
SUI_NETWORK_TYPE=testnet
```

## Usage

### Build the project

```bash
pnpm build
```

### Publish Move package

```bash
pnpm publish-package
```

### Get Pyth price data

```bash
pnpm get-price
```

## Project Structure

- `ts-scripts/`: TypeScript utility scripts
  - `sui-kit.ts`: SUI SDK integration tool
  - `publish-package.ts`: Script for publishing Move packages
- `pyth_rule/`: Pyth price oracle integration
  - `scripts/`: TypeScript scripts
    - `get-price.ts`: Script for fetching price data
    - `get-vaas.ts`: Script for fetching VAA data
- `switchboard_rule/`: Switchboard oracle integration
- `x_oracle/`: Core Oracle aggregation logic
