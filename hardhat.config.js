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
    sepo: {
      url: "http://127.0.0.1:8545",
      accounts: [process.env.PRIVATE_KEY]
    }
  }
};
