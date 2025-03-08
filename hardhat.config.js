import "@nomicfoundation/hardhat-toolbox";
import dotenv from "dotenv";

// Load environment variables from the .env file
dotenv.config();

/** @type import('hardhat/config').HardhatUserConfig */
export default {
  solidity: {
    version: "0.8.20",
    settings: {
      optimizer: {
        enabled: true,
        runs: 200
      }
    }
  },
  networks: {
    hardhat: {},  // Local Hardhat network
    testnet: {
      url: "https://data-seed-prebsc-1-s1.binance.org:8545", // BSC Testnet RPC
      accounts: [process.env.PRIVATE_KEY]
    }
  }
};
