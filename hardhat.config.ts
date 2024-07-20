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
      url: `https://48899.rpc.thirdweb.com`,
      accounts: [process.env.ZIRCUIT_TESTNET_PRIVATE_KEY || ""],
      // gasPrice: 3000000000,
    },
  },
  etherscan: {
    apiKey: {
      zircuitTestnet: process.env.SCAN_API_KEY || "",
    },
    customChains: [
      {
        network: "zircuitTestnet",
        chainId: 48899,
        urls: {
          apiURL: "https://explorer.zircuit.com/api/contractVerifyHardhat",
          browserURL: "https://explorer.zircuit.com",
        },
      },
    ],
  },
  sourcify: {
    enabled: false,
  },
};

export default config;
