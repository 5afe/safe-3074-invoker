# Safe EIP-3074 Invoker

This repository includes a proof-of-concept EIP-3074 invoker allowing a Safe to
control an EOA.

**:warning: This is a proof-of-concept and should not be used with actual funds!
:warning:**

## Installation

We will need to set up the submodules for the repository.

```
make install
```

## Deployment

To deploy, you can use the following command:

```
make foundry cmd="forge script AuthCallScript --rpc-url otim --private-key YOUR_PRIVATE_KEY --broadcast -vvvv"
```

## Network

For development, we are using the [Otim](https://docs.otim.xyz/) test network
with RPC endpoint <http://devnet.otim.xyz>. There is a
[faucet](http://devnet-faucet.otim.xyz/) for mining test funds.
