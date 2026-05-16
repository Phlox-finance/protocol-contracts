# protocol-contracts

## Local Network

### Start a Local Fork

Fork LUKSO mainnet with Anvil (Foundry):

```bash
anvil --fork-url https://rpc.mainnet.lukso.network --chain-id 31337
```

This gives you a local EVM node at `http://127.0.0.1:8545` with all LUKSO mainnet state. Chain ID 31337 avoids conflicts with real LUKSO mainnet.

### Fund an Account

In a separate terminal, set any address balance using `cast`:

```bash
# Set address to 10,000 ETH (value in hex wei)
cast rpc anvil_setBalance 0xYOUR_ADDRESS 0x21E19E0C9BAB2400000
```

### Connect via MetaMask

Add a custom network in MetaMask:
- **RPC URL:** `http://localhost:8545`
- **Chain ID:** `31337`
- **Currency:** ETH

Then select the Foundry chain in the dashboard's chain selector.