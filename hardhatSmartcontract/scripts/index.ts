import { ethers, upgrades } from "hardhat";
import { getRoot, getProofs } from "../helpers/merkletree";

import "@openzeppelin/hardhat-upgrades";

async function main() {
  const [owner, buyer] = await ethers.getSigners();
  const MAX = ethers.utils.parseEther("65000");
  const V1 = await ethers.getContractFactory("PropertyTokenV1");
  const V2 = await ethers.getContractFactory("PropertyTokenV2");
  const DOLL = await ethers.getContractFactory("MockToken");
  const doll = await DOLL.deploy("lol", "ll", 18);
  await doll.deployed();

  const pbox = await upgrades.deployProxy(
    V1,
    [
      String(owner.address),
      String(owner.address),
      doll.address, // "0x4cd2a9b9edc6a6f523a33aef4a72f7340e656eee",
      "5 allee des genets",
      "5ADG",
    ],
    {
      initializer: "initialize",
      kind: "uups",
    }
  );
  let tx = await pbox.deployed();
  console.log(pbox.address);
  // const contrat = new ethers.Contract(
  //   pbox.address,
  //   V1.interface,
  //   ethers.getDefaultProvider()
  // );
  const pbox2 = await upgrades.upgradeProxy(pbox.address, V2);

  // await pbox2.setCurrency(buyer.address);
  // const v = await pbox.variables();
  // console.log(
  //   "Currency : " + v.currencyUsed + "\n New address" + buyer.address
  // );

  // await contrat
  //   .connect(owner)
  //   .buy(owner.address, 900, getProofs(owner.address));
  // console.log("PropertyToken address :\n ", pbox.address);
  // console.log(
  //   "Owner : ",
  //   owner.address,
  //   " OwnerOfProxy = ",
  //   await pbox.owner()
  // );

  console.log();
}

main().catch((error) => {
  console.error(error);
});
