
# Zero-Block Governance Freeze PoC

This repository contains a Foundry-based proof-of-concept demonstrating how a zero-block
governance freeze mitigates flash-loan and flash-mint voting attacks.

## Structure
- `src/MockVotesToken.sol`: Vote token with historical snapshots
- `src/GovNoFreeze.sol`: Baseline governance (vulnerable)
- `src/GovFreeze.sol`: Governance with zero-block freeze
- `src/FlashMint.sol`: Flash-mint primitive
- `src/Attacker.sol`: Attack coordinator
- `test/ZeroBlockFreeze.t.sol`: Foundry tests validating the attack and mitigation

## Running tests
```bash
forge test -vv

## Foundry

**Foundry is a blazing fast, portable and modular toolkit for Ethereum application development written in Rust.**

Foundry consists of:

- **Forge**: Ethereum testing framework (like Truffle, Hardhat and DappTools).
- **Cast**: Swiss army knife for interacting with EVM smart contracts, sending transactions and getting chain data.
- **Anvil**: Local Ethereum node, akin to Ganache, Hardhat Network.
- **Chisel**: Fast, utilitarian, and verbose solidity REPL.

## Documentation

https://book.getfoundry.sh/

## Usage

### Build

```shell
$ forge build
```

### Test

```shell
$ forge test
```

### Format

```shell
$ forge fmt
```

### Gas Snapshots

```shell
$ forge snapshot
```

### Anvil

```shell
$ anvil
```

### Deploy

```shell
$ forge script script/Counter.s.sol:CounterScript --rpc-url <your_rpc_url> --private-key <your_private_key>
```

### Cast

```shell
$ cast <subcommand>
```

### Help

```shell
$ forge --help
$ anvil --help
$ cast --help
```
