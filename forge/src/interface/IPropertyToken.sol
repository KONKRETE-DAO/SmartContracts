//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.10;

import "@openzeppelin/contracts/token/ERC20/extensions/draft-IERC20Permit.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
enum Step {
  Deployed,
  Sale,
  Soldout
}
struct Variables {
  Step step;
  uint32 cexRatioX10000;
  bytes32 merkleRoot;
  uint128 MaxToBuy;
  address bank;
  IERC20 currencyUsed;
}

interface IPropertyToken is IERC20, IERC20Permit {
  function MAX_SUPPLY() external view returns (uint256);

  function TOKEN_PRICE() external view returns (uint256);

  function variables() external view returns (Variables calldata);

  function tokensBought(address token) external view returns (uint256);

  //3ccfd60b
  function withdraw() external;

  //f75d6f80
  function setCexRatio(uint32) external;

  //f8dcbddb
  function setStep(uint256) external;

  //ea7a42e4
  function setAllowListMerkleRoot(bytes32) external;

  //cfac414b
  function transferFromWithPermission(
    address from,
    address to,
    uint256 deadline,
    uint256 amount,
    uint8 v,
    bytes32 r,
    bytes32 s
  ) external;

  //4c13a639
  function buy(
    address,
    uint256,
    bytes32[] calldata
  ) external;
}
