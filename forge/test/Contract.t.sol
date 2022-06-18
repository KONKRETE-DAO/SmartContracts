// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../src/debtHouse/FakeDoll.sol";
import "../src/debtHouse/DebtPropertyToken.sol";
import "../src/debtHouse/OTC.sol";

contract ContractTest is Test {
  FakeDoll dollar = new FakeDoll();
  uint256 max =
    0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff;
  uint256 housePrice = 221550 * (10**(dollar.decimals()));
  uint256 dFtMaxSupply = housePrice / 10; /* in dollar for now*/
  DebtPropertyToken dFtToken = new DebtPropertyToken(dollar, dFtMaxSupply);
  address addr1 = address(1);
  address addr2 = address(2);
  address feePot = address(3);
  OTC orderPlatform = new OTC(dollar, feePot, 250);
  uint256 amountToBuy = 1000 * (10**dFtToken.decimals());

  function setUp() public {}

  function testDebtHouse() public {
    orderPlatform.addToken(dFtToken);
    assert(orderPlatform.isToken(dFtToken));
    vm.startPrank(addr1);
    dollar.mint(10001 * (10**dollar.decimals()));
    dollar.approve(address(dFtToken), max);
    dFtToken.approve(address(orderPlatform), max);
    dFtToken.buy(addr1, amountToBuy);
    require(dFtToken.balanceOf(addr1) == amountToBuy, "Buy ft error");
    orderPlatform.sellOrder(
      IERC20(dFtToken),
      amountToBuy,
      123456 * (10**dollar.decimals())
    );
    require(dFtToken.balanceOf(addr1) == 0, "Sell Order ft error");
    require(
      dFtToken.balanceOf(address(orderPlatform)) == amountToBuy,
      "Sell Order ft error"
    );
    vm.stopPrank();

    vm.startPrank(addr2);
    dollar.mint(123456 * (10**dollar.decimals()));
    dollar.approve(address(dFtToken), max);
    dollar.approve(address(orderPlatform), max);
    dFtToken.approve(address(orderPlatform), max);
    orderPlatform.buy(dFtToken, 0);
    require(dFtToken.balanceOf(addr2) == amountToBuy, "Bad buying Sellorder");
    require(dollar.balanceOf(addr2) == 0, "Bad buying Sellorder");
    vm.stopPrank();

    vm.startPrank(addr1);
    dollar.approve(address(orderPlatform), max);
    require(dFtToken.balanceOf(addr1) == 0, "Bad BuyOrder");
    orderPlatform.buyOrder(dFtToken, amountToBuy, dollar.balanceOf(addr1));
    require(dFtToken.balanceOf(addr1) == 0, "Bad BuyOrder");
    vm.stopPrank();

    vm.startPrank(addr2);
    orderPlatform.sell(dFtToken, 0);
    vm.stopPrank();
    orderPlatform.withdrawFee();
    assert(dollar.balanceOf(feePot) != 0);
    console.log(dollar.balanceOf(feePot));
  }

  function testRentHouse() public {}
}
