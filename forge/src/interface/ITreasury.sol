//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.10;

struct ContractInfo {
  address stakingContract;
  uint256 maxSupply;
}

interface ITreasury {
  //0xf0dc2c20
  function addStakingContract(address) external;

  //0x47e7ef24
  function deposit(address, uint256) external;
}
