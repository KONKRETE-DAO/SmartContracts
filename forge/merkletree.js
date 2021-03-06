const { ethers } = require("ethers");

const { MerkleTree } = require("merkletreejs");
const keccak256 = require("keccak256");

function getProofs(address) {
  // console.log(0);
  let tree, leaves;
  try {
    leaves = whitelist.map((x) => keccak256(x));
  } catch (err) {
    console.log(err);
  }
  try {
    tree = new MerkleTree(leaves, keccak256, { sortPairs: true });
    //  console.log(tree);
  } catch (err) {
    console.log(err);
  }
  return tree.getHexProof(ethers.utils.keccak256(address.toString(16)));
}

function getRoot() {
  const leaves = whitelist.map((x) => keccak256(x));
  const tree = new MerkleTree(leaves, keccak256, { sortPairs: true });

  return tree.getRoot();
}

const whitelist = [
  "0x1e0C4f4b8679C35a7c12B859C852F89E298396bd",
  "0xDd011Bc8D5F5B9c716e711b515a044346E4104C6",
  "0x89d34B4E0835398A52286600B211bF79691f2F08",
  "0x8843ab51e125ff7C3a86AfE2e3770e8763D87A30",
  "0xa674F2C33f504345F50cA6C850F9fd8338612166",
  "0xf1fc0b43f8fd0e8b8fce983732d48925148438c1",
  "0x5a61FF4f0A6B6cf99c756C45DaA2a15Cfdc16AD6",
  "0xbD28bc431332000C78Aa6389625aa116D71c0c42",
  "0xC5DC4FA9dE7aafeA8F45D2fBB69DEFf44bB20c8a",
  "0x91f3ACF393dE794E7291FBF36DFc408Da617cfF0",
  "0x009d13E9bEC94Bf16791098CE4E5C168D27A9f07",
  "0xd8FAEC528b9fbf4fE3226d6BeB8B14A4F9BAD655",
  "0x8E4a55D8e52F0DaE3247Ad4DB9bE8533658949f6",
  "0xf450Da3331977b120b6FAD4375E52813C0D5cD13",
];
const address = "0x1e0c4f4b8679c35a7c12b859c852f89e298396bd";
console.log(String(getProofs(address)));
console.log(ethers.utils.parseBytes32String(getRoot()));
