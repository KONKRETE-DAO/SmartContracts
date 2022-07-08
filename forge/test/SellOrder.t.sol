// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "./Contract.t.sol";

contract SellOrderTest is ContractTest {
  function testOTCsellOrder(
    uint256 firstPrice,
    uint256 price,
    uint16 fee
  ) public {
    pToken.setStep(1);
    pToken.setCexRatio(10000);
    vm.assume(fee < 1000);
    vm.assume(firstPrice / 10 < (pToken.MAX_SUPPLY() / 100) * 30);
    vm.assume(firstPrice > 1000);
    vm.assume(price > 1000);
    vm.assume(price < max / 1000);
    OTC orderPlatform1 = new OTC(address(dollar), feePot, fee);
    orderPlatform1.addToken(pToken);
    assert(orderPlatform1.isToken(pToken));
    ///SELLLER
    uint256 tokenAmount = firstPrice / pToken.TOKEN_PRICE();
    vm.startPrank(addr1);
    dollar.approve(address(pToken), max);
    dollar.mint(addr1, firstPrice);
    pToken.buy(addr1, firstPrice);
    require(pToken.balanceOf(addr1) == tokenAmount, "Buy ft error");
    (uint8 v, bytes32 r, bytes32 s) = ContractTest.getVRS(
      address(pToken),
      addr1,
      address(orderPlatform1),
      tokenAmount,
      max,
      1
    );
    orderPlatform1.initSellOrder(
      address(pToken),
      address(dollar),
      tokenAmount,
      price,
      max,
      v,
      r,
      s
    );
    require(pToken.balanceOf(addr1) == 0, "Sell Order ft error");
    require(
      pToken.balanceOf(address(orderPlatform1)) == tokenAmount,
      "Sell Order ft error"
    );
    vm.stopPrank();
    //BUYER
    vm.startPrank(addr2);
    dollar.mint(addr2, price);
    dollar.approve(address(orderPlatform1), max);
    orderPlatform1.buy(address(pToken), 0);
    vm.stopPrank();
    //CONTRACT
    orderPlatform1.withdrawFee(address(dollar));
    console.log(uint64(block.chainid));
    require(((price * fee) / 1000) == dollar.balanceOf(feePot), "FeeProblem");
  }
}
