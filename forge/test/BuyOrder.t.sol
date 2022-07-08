// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "./Contract.t.sol";

contract BuyOrderTest is ContractTest {
  function testOTCbuyOrder(
    uint256 firstPrice,
    uint256 price,
    uint16 fee
  ) public {
    pToken.setStep(1);
    pToken.setCexRatio(10000);
    console.log(block.chainid);
    vm.assume(fee < 1000);
    vm.assume(firstPrice / 10 < (pToken.MAX_SUPPLY() / 1000) * 30);
    vm.assume(firstPrice > 1000);
    vm.assume(price > 1000);
    vm.assume(price < max / 1000);
    /// Begin
    OTC orderPlatform = new OTC(address(dollar), feePot, fee);
    orderPlatform.addToken(pToken);
    assert(orderPlatform.isToken(pToken));
    ///SELLLER
    vm.startPrank(addr1);
    dollar.approve(address(orderPlatform), max);
    dollar.mint(addr1, price);
    require(dollar.balanceOf(addr1) == price, "Buy ft error");
    uint256 tokenAmount = firstPrice / pToken.TOKEN_PRICE();
    orderPlatform.initBuyOrder(
      address(pToken),
      address(dollar),
      tokenAmount,
      price
    );
    require(dollar.balanceOf(addr1) == 0, "Buy Order ft error");
    require(
      dollar.balanceOf(address(orderPlatform)) == price,
      "Sell Order ft error"
    );
    vm.stopPrank();
    //BUYER
    vm.startPrank(addr2);
    dollar.mint(addr2, firstPrice);
    dollar.approve(address(pToken), firstPrice);
    pToken.buy(addr2, firstPrice);
    require(pToken.balanceOf(addr2) == tokenAmount, "Buy ft error");
    (uint8 v, bytes32 r, bytes32 s) = ContractTest.getVRS(
      address(pToken),
      addr2,
      address(orderPlatform),
      tokenAmount,
      max,
      2
    );
    // pToken.approve(address(orderPlatform), firstPrice);
    (
      ,
      ,
      uint64 indexr,
      ,
      ,
      address buyerr,
      uint256 feer,
      uint256 pricer,
      uint256 tokenAmountr,

    ) = orderPlatform.buyOrderByToken(address(pToken), 0);
    require(tokenAmountr == tokenAmount, "Amount err");
    require(indexr == 0, "Index err");
    console.log(addr1);
    console.log(buyerr);
    require(buyerr == addr1, "Buyer problem");
    require(pricer == price, "Buyer problem");
    if (fee > 0) require(feer == (price * fee) / 1000, "fee problems");
    orderPlatform.sell(address(pToken), uint64(0), max, v, r, s);
    vm.stopPrank();
    //CONTRACT
    //   orderPlatform.withdrawFee(address(dollar));
    //   require((price / 1000) * fee == dollar.balanceOf(feePot), "FeeProblem");
  }
}
