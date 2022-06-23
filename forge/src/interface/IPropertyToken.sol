//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.10;

import "@openzeppelin/contracts/token/ERC20/extensions/draft-IERC20Permit.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

interface IPropertyToken is IERC20, IERC20Permit {
  function MAX_SUPPLY() external view returns (uint256);

  //0xcce7ec13
  function buy(address _to, uint256 amount) external;

  //0x3ccfd60b
  function withdraw() external;

  //0x4320efc0
  function transferToWithPermission(
    address from,
    address receiver,
    uint256 amount,
    uint256 deadline,
    uint8 v,
    bytes32 r,
    bytes32 s
  ) external;
}