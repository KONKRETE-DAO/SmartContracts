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
  const PTOKEN = await ethers.getContractFactory("PropertyToken");
  const ptoken = new ethers.Contract(
    "0xF7250796f71982a799fd38CA05BEfA86dEc8F0bE",
    PTOKEN.interface,
    ethers.getDefaultProvider()
  );
  const CURRENCY = await ethers.getContractFactory("MockToken");
  const currency = new ethers.Contract(
    "0x4cd2a9b9edc6a6f523a33aef4a72f7340e656eee",
    CURRENCY.interface,
    ethers.getDefaultProvider()
  );

  const [owner, buyer] = await ethers.getSigners();
  console.log(owner.address);
  console.log(buyer.address);
  console.log(getRoot());

  //   let tx = await ptoken.connect(owner).setAllowListMerkleRoot(getRoot());
  //   tx.wait();
  //   await currency
  //     .connect(owner)
  //     .approve(
  //       "0xF7250796f71982a799fd38CA05BEfA86dEc8F0bE",
  //       ethers.BigNumber.from(
  //         "0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff"
  //       )
  //     );
  let tx = await ptoken
    .connect(owner)
    .buy(
      owner.address,
      ethers.utils.parseEther("1000"),
      getProofs(owner.address)
    );
  //   console.log(await ptoken.connect(owner).variables());
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
