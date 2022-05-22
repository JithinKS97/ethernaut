require('@nomiclabs/hardhat-truffle5');
require('@openzeppelin/hardhat-upgrades');
require("hardhat-gas-reporter");

/**
 * @type import('hardhat/config').HardhatUserConfig
 */
module.exports = {
  solidity: {
    compilers: [
      {
        version: '0.5.3',
        settings: {
          optimizer: {
            enabled: true,
            runs: 1000,
          },
        },
      },
      {
        version: '0.6.12',
        settings: {
          optimizer: {
            enabled: true,
            runs: 1000,
          },
        },
      },
      {
        version: '0.8.12',
        settings: {
          optimizer: {
            enabled: true,
            runs: 1000,
          },
        },
      },
    ],
  },
  paths: {
    artifacts: './build',
  },
  networks: {
    hardhat: {
      chainId: 1337,
      forking: {
        // Forking the Rinkeby network to use the Uniswap factory & router.
        url: "https://eth-rinkeby.alchemyapi.io/v2/<YOUR_ALCHEMY_API_KEY>",
        blockNumber: 10692451
      }
    },
  },
};
