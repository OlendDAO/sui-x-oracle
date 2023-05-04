# SUI X Oracle
SUI X Oracle is safe, because it gets price data from multiple sources and uses a decentralized oracle to aggregate the data.

### Supported oracles
- Supra
- Switchboard
- Pyth

### How it works
1. Get price data from multiple sources
2. Use Pyth as the primary source
3. Check Pyth price data with Supra and Switchboard, if the price difference is within the threshold, use the Pyth price data
4. If the price difference is not within the threshold, reject the transaction. Because the price data is manipulated by the oracle.
