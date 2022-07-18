import { ethers, upgrades, defender } from "hardhat";
import { getRoot, getProofs } from "../helpers/merkletree";

import "@openzeppelin/hardhat-upgrades";
import { MockProvider } from "ethereum-waffle";

async function main() {
  const gnosisSafe = "0x66dE44367E80181e01E3e454c8B032a55a32B6f4";
  const USDC = "0x2791Bca1f2de4661ED88A30C99A7a9449Aa84174";

  const [owner, buyer] = await ethers.getSigners();
  const V1 = await ethers.getContractFactory("PropertyTokenV1");
  const V2 = await ethers.getContractFactory("PropertyTokenV2");
  const DOLL = await ethers.getContractFactory("MockToken");

  // const doll = await DOLL.deploy("lol", "ll", 18);
  // await doll.deployed();

  // ///// MAIN DEPLOYEMENT

  const pbox = await upgrades.deployProxy(
    V1,
    [
      String(owner.address),
      gnosisSafe,
      USDC, // Polygo
      "203 rue de Saint-Malo, Rennes",
      "203rdSM-R",
    ],
    {
      initializer: "initialize",
      kind: "uups",
    }
  );
  let tx = await pbox.deployed();
  console.log("https://polygonscan.com/address/" + pbox.address);
  console.log(pbox.address);
  tx = await pbox.connect(owner).setCexRatio(9909);

  ///////////////////// UPGRADING CONTRACT WITH DEFENDER!!!!!!!
  // const proposal = await defender.proposeUpgrade(
  //   "Contract address",
  //   V2,
  //   { multisig: gnosisSafe }
  // );
  // console.log(proposal.url);

  console.log("Deployé !!!!");
}

main().catch((error) => {
  console.error(error);
});
