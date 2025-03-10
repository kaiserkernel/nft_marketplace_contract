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
    hardhat: {
      chainId: 31337
    },

    // Binance Smart Chain Testnet (for WebSocket)
    bscTestnet: {
      url: process.env.BSC_TESTNET_URL,  // Add WebSocket URL here for Testnet
      accounts: [process.env.PRIVATE_KEY], // Use your private key for signing the transaction
    },

    // Binance Smart Chain Mainnet (for production)
    bscMainnet: {
      url: process.env.BSC_MAINNET_URL, // Add WebSocket URL here for Mainnet
      accounts: [process.env.PRIVATE_KEY],
    },
  }
};
