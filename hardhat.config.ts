import { HardhatUserConfig } from "hardhat/config";
import "@nomicfoundation/hardhat-toolbox";
import * as dotenv from "dotenv";
dotenv.config();

const config: HardhatUserConfig = {
  solidity: {
    compilers: [
      {
        version: "0.8.24",
        settings: {
          optimizer: {
            enabled: true,
            runs: 1,
          },
        },
      },
      {
        version: "0.7.6",
        settings: {
          optimizer: {
            enabled: true,
            runs: 1,
          },
        },
      },
    ],
  },
  networks: {
    ganache: {
      url: "http://localhost:8545",
      gasPrice: 20000000000,
      accounts: [process.env.GANACHE_PRIVATE_KEY || ""],
    },
    // for Sepolia testnet
    zircuitTestnet: {
      url: `https://zircuit1.p2pify.com/`,
      accounts: [process.env.ZIRCUIT_TESTNET_PRIVATE_KEY || ""],
      gasPrice: 3000000000,
    },
    zircuit: {
      url: "https://zircuit1-mainnet.p2pify.com/",
      accounts: process.env.ZIRCUIT_PRIVATE_KEY
        ? [process.env.ZIRCUIT_PRIVATE_KEY]
        : [],
      chainId: 48900,
    },
  },
  etherscan: {
    apiKey: {
      zircuitTestnet: process.env.SCAN_API_KEY || "",
      zircuit: process.env.SCAN_API_KEY || "",
    },
    customChains: [
      {
        network: "zircuitTestnet",
        chainId: 48899,
        urls: {
          apiURL:
            "https://explorer.testnet.zircuit.com/api/contractVerifyHardhat",
          browserURL: "https://explorer.testnet.zircuit.com/",
        },
      },
      {
        network: "zircuit",
        chainId: 48900,
        urls: {
          apiURL: "https://explorer.zircuit.com/api/contractVerifyHardhat",
          browserURL: "https://explorermainnet.zircuit.com/",
        },
      },
    ],
  },
  sourcify: {
    enabled: false,
  },
};

export default config;
