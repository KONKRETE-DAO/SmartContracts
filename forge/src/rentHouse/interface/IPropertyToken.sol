//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.10;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

interface IRentPropertyToken is IERC20 {
  function MAX_SUPPLY() external view returns (uint256);

  //0xcce7ec13
  function buy(address _to, uint256 amount) external;

  //0x3ccfd60b
  function withdraw() external;
}
