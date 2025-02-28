require("@nomicfoundation/hardhat-toolbox");

/** @type import('hardhat/config').HardhatUserConfig */
module.exports = {
  solidity: "0.8.28",
  networks: {
    sepo: {
      url: ``,
      accounts: [`0x${process.env.PRIVATE_KEY}`]
    }
  }
};
