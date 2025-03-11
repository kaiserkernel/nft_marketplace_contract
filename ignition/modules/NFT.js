// This setup uses Hardhat Ignition to manage smart contract deployments.
// Learn more about it at https://hardhat.org/ignition

import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";

export default buildModule("NFTModule", (m) => {
  // Deploy both the NFTFactory and NFTCollection contracts
  const nftFactory = m.contract("NFTFactory");

  return { nftFactory };
});
