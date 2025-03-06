// This setup uses Hardhat Ignition to manage smart contract deployments.
// Learn more about it at https://hardhat.org/ignition

import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";

export default buildModule("NFTModule", (m) => {
  const nft = m.contract("NFTFactory");

  return { nft };
});
