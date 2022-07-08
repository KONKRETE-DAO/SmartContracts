//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.13;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

interface ITreasury {
    //0x47e7ef24
    function deposit(address, uint256) external;

    function MAX_TOKEN_SUPPLY() external view returns (uint256);

    function pToken() external view returns (address);

    function currencyUsed() external view returns (IERC20);
}
