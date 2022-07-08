import { ethers } from "ethers";

import { MerkleTree } from "merkletreejs";

import { whitelist } from "./whitelist";
import keccak256 from "keccak256";

export function getProofs(address: String) {
  // console.log(0);
  let tree;
  let leaves = [String];
  try {
    leaves = whitelist.map(keccak256);
  } catch (err) {
    console.log(err);
  }
  try {
    tree = new MerkleTree(leaves, keccak256, { sortPairs: true });
    //  console.log(tree);
    return tree.getHexProof(ethers.utils.keccak256(address.toString()));
  } catch (err) {
    console.log(err);
  }
}

export function getRoot() {
  const leaves = whitelist.map(keccak256);
  const tree = new MerkleTree(leaves, keccak256, { sortPairs: true });

  return tree.getRoot();
}
