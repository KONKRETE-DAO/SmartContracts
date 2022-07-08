import { ethers } from "hardhat";

import "@openzeppelin/hardhat-upgrades";

async function main() {
  const [owner, buyer] = await ethers.getSigners();
  const MAX = ethers.utils.parseEther("65000");
  V1 = await ethers.getContractFactory("PropertyTokenV1");
  pbox = await upgrades.deployProxy(V1, [42], {
    constructorArgs: [MAX, owner.address, "5 rue au blés", "5rB"],
    initializer: ["0x4cD2a9b9edC6A6F523a33aEF4a72f7340E656eEE", owner.address],
  });
}

main().catch((error) => {
  console.error(error);
});
