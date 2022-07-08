//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.13;
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

interface IFakeDoll is IERC20 {
    //0xa0712d68
    function mint(uint256 nb) external;
}
