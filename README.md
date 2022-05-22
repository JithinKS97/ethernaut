# Ethernaut
 
[![Twitter Follow](https://img.shields.io/twitter/follow/OpenZeppelin?style=plastic&logo=twitter)](https://twitter.com/OpenZeppelin)
[![OpenZeppelin Forum](https://img.shields.io/badge/Ethernaut%20Forum%20-discuss-blue?style=plastic&logo=discourse)](https://forum.openzeppelin.com/tag/ethernaut)

Ethernaut is a Web3/Solidity based wargame inspired by [overthewire](https://overthewire.org), to be played in the Ethereum Virtual Machine. Each level is a smart contract that needs to be 'hacked'.

The game acts both as a tool for those interested in learning ethereum, and as a way to catalogue historical hacks as levels. There can be an infinite number of levels and the game does not require to be played in any particular order.

## Deployed Versions

You can find the current, official version at: [ethernaut.openzeppelin.com](https://ethernaut.openzeppelin.com)

## Install and Build

There are three components to Ethernaut that are needed to run/deploy in order to work with it locally:

- Test Network - A testnet that is running locally, like ganache, hardhat network, geth, etc
- Contract Deployment - In order to work with the contracts, they must be deployed to the locally running testnet
- The Client/Frontend - This is a React app that runs locally and can be accessed on localhost:3000

In order to install, build, and run Ethernaut locally, follow these instructions:

1. Clone the repo and install dependencies:

    ```bash
    git clone git@github.com:OpenZeppelin/ethernaut.git
    yarn install
    ```

1. Install
```
git clone git@github.com:OpenZeppelin/ethernaut.git
yarn install
```
2. Configure Rinkeby endpoint
Create a new Alchemy project on the Rinkeby testnet network, and copy the RPC URL to the forking section at contracts/hardhat.config.js
3. Start deterministic rpc
```
yarn network
```
4. You might want to import one of the private keys from ganache-cli to your Metamask wallet.
5. Compile contracts
```
yarn compile:contracts
```
6. Set client/src/constants.js ACTIVE_NETWORK to NETWORKS.LOCAL
7. Deploy contracts
```
yarn deploy:contracts
```
8. Start Ethernaut locally
```
yarn start:ethernaut
```

    ```bash
    yarn start:ethernaut
    ```

### Running locally (goerli network)

The same as using the local network but steps 2, 3 and 6 are not necessary.

In this case, replace point 5 with:
5. Set client/src/constants.js ACTIVE_NETWORK to NETWORKS.GOERLI

### Running tests

```bash
yarn test:contracts
```

### Building

```bash
yarn build:ethernaut
```

### Deploying

To deploy the contracts on goerli, first set the ACTIVE_NETWORK variable in constants.js and then edit gamedata.json. This file keeps a history of all level instances in each level data's deployed_goerli array. To deploy a new instance, add an "x" entry to the array, like so:

```json
"deployed_goerli": [
  "x",
  "0x4b1d5eb6cd2849c7890bcacd63a6855d1c0e79d5",
  "0xdf51a9e8ce57e7787e4a27dd19880fd7106b9a5c"
],
```

Then run `yarn deploy:contracts`. This action will effectively deploy a new version of the level data item whose deployed_goerli array was updated, and will point the ethernaut dapp to use this new deployed contract instance for the level.

## Contributing

Contributions and corrections are always welcome!

Please follow the [Contributor's Guide](./CONTRIBUTING.md) if you would like to help out.
