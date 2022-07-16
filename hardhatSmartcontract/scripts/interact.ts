// We require the Hardhat Runtime Environment explicitly here. This is optional
// but useful for running the script in a standalone fashion through `node <script>`.
//
// When running the script with `npx hardhat run <script>` you'll find the Hardhat
// Runtime Environment's members available in the global scope.
import { ethers } from "hardhat";
import { ContractFunctionVisibility } from "hardhat/internal/hardhat-network/stack-traces/model";
import { connect } from "http2";
import { getRoot, getProofs } from "../helpers/merkletree";

async function main() {
  const [owner, buyer] = await ethers.getSigners();
  const PTOKEN = await ethers.getContractFactory("PropertyTokenV1");
  const ptoken = new ethers.Contract(
    "0x215de2b3B83f12D71C61861E318AcEC94b47e52D",
    PTOKEN.interface,
    ethers.getDefaultProvider()
  );
  await ptoken.connect(owner).setAllowListMerkleRoot(getRoot());
  // await ptoken.connect(owner).setStep(1);
  // await ptoken.connect(owner).setCexRatio(9915);
  // console.log(String(ethers.utils.formatEther("1008572869389813414019")));

  //   console.log(await ptoken.connect(owner).variables());
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
//1008572869389813414019
//100857286938981341401
