// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../src/PropertyToken.sol";

import "../src/OTC.sol";
import "../src/interface/IOTC.sol";
import "../src/mocktoken.sol";

contract ContractTest is Test {
  uint256 makeDecimals = 10**18;
  uint256 max =
    0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff;

  uint256 housePrice = 221550 * makeDecimals;
  uint256 dFtMAX_SUPPLY = housePrice / 10; /* in dollar for now*/
  address addr1 = vm.addr(1);
  address addr2 = vm.addr(2);
  address feePot = vm.addr(3);
  address multisig = vm.addr(4);
  address bank = vm.addr(5);
  MockToken dollar = new MockToken("lol", "ll", 18);
  PropertyToken pToken =
    new PropertyToken(
      bank,
      multisig,
      address(dollar),
      "1 rue Affre, 75018 Paris",
      "1A75018"
    );

  function setUp() public {
    vm.warp(1656322810);
  }

  function testBuy(uint256 firstPrice) public {
    pToken.setStep(1);
    pToken.setCexRatio(10000);
    vm.assume(firstPrice < pToken.MAX_SUPPLY());
    vm.startPrank(addr1);
    dollar.mint(addr1, firstPrice);
    dollar.approve(address(pToken), firstPrice);
    pToken.buy(addr1, firstPrice / 10);
    vm.stopPrank();
  }

  function testStake() public {}

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
    (uint8 v, bytes32 r, bytes32 s) = getVRS(
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
    (uint8 v, bytes32 r, bytes32 s) = getVRS(
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

  function testRentHouse() public {}
}
