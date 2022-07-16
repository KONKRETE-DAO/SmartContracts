import { ethers, upgrades, defender } from "hardhat";
import { getRoot, getProofs } from "../helpers/merkletree";

import "@openzeppelin/hardhat-upgrades";

async function main() {
  const gnosisSafe = "0x34e062DD7C9B0AC68301cF88C55a706F4066F820";

  const [owner, buyer] = await ethers.getSigners();
  const MAX = ethers.utils.parseEther("65000");
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
      owner.address,
      "0x4f05a4f7050B6F53664637733789909ba69b15bc",
      "5 allee des genets",
      "5ADG",
    ],
    {
      initializer: "initialize",
      kind: "uups",
    }
  );
  let tx = await pbox.deployed();
  console.log("https://goerli.etherscan.io/address/" + pbox.address);
  console.log(pbox.address);

  ////// CHANGING OWNERSHIP
  // const contrat = new ethers.Contract(
  //   "0x44c58eDe561f90FBcF5746154b883811d2493B89",
  //   V1.interface,
  //   ethers.getDefaultProvider()
  // );
  // console.log("Transferring ownership to : " + gnosisSafe);
  // await contrat.connect(owner).transferOwnership(gnosisSafe);
  // console.log("OwnerSHip transferred !!!!!");

  ///////////////////// UPGRADING CONTRACT WITH DEFENDER!!!!!!!
  // const proposal = await defender.proposeUpgrade(
  //   "0x44c58eDe561f90FBcF5746154b883811d2493B89",
  //   V2,
  //   { multisig: gnosisSafe }
  // );
  // console.log(proposal.url);

  console.log();
}

main().catch((error) => {
  console.error(error);
});
