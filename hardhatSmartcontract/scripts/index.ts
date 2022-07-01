import { ethers, upgrades } from "hardhat";

import "@openzeppelin/hardhat-upgrades";

async function main() {
  const [owner, buyer] = await ethers.getSigners();
  const MAX = ethers.utils.parseEther("65000");
  const V1 = await ethers.getContractFactory("PropertyTokenV1");
  const pbox = await upgrades.deployProxy(
    V1,
    [
      String(owner.address),
      String(owner.address),
      "0x4cd2a9b9edc6a6f523a33aef4a72f7340e656eee",
      "5 allee des genets",
      "5ADG",
    ],
    {
      initializer: "initialize",
    }
  );
}

main().catch((error) => {
  console.error(error);
});
