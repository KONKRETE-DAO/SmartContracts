//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.12;
import "@openzeppelin/contracts/mocks/ERC20DecimalsMock.sol";

contract MockToken is ERC20DecimalsMock {
  constructor(
    string memory name,
    string memory symbol,
    uint8 decimal
  ) ERC20DecimalsMock(name, symbol, decimal) {}
}
