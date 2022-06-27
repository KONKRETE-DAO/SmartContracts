// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../src/PropertyToken.sol";
import "../src/MockStable.sol";
import "../src/OTC.sol";
import "../src/interface/IOTC.sol";

contract ContractTest is Test {
  uint256 makeDecimals = 10**18;
  uint256 max =
    0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff;
  bytes32 _PERMIT_TYPEHASH =
    keccak256(
      "Permit(address owner,address spender,uint256 value,uint256 nonce,uint256 deadline)"
    );
  uint256 housePrice = 221550 * makeDecimals;
  uint256 dFtMaxSupply = housePrice / 10; /* in dollar for now*/
  address addr1 = vm.addr(1);
  address addr2 = vm.addr(2);
  address feePot = vm.addr(3);
  address multisig = vm.addr(4);
  FakeDoll dollar = new FakeDoll();
  PropertyToken pToken =
    new PropertyToken(
      dollar,
      dFtMaxSupply,
      multisig,
      "1 rue Affre, 75018 Paris",
      "1A75018"
    );

  function setUp() public {
    vm.warp(1656322810);
  }

  function testBuy(uint256 amount) public {
    vm.assume(amount < pToken.MAX_SUPPLY());
    vm.startPrank(addr1);
    dollar.mint(amount);
    dollar.approve(address(pToken), amount);
    pToken.buy(addr1, amount / 10);
    vm.stopPrank();
  }

  function testStake() public {}

  function testOTCsellOrder(
    uint256 amount,
    uint256 price,
    uint16 fee
  ) public {
    vm.assume(fee < 1000);
    vm.assume(amount / 10 < (pToken.MAX_SUPPLY() / 1000) * 30);
    vm.assume(amount > 0);
    vm.assume(price > 1000);
    vm.assume(price < max / 1000);
    OTC orderPlatform1 = new OTC(address(dollar), feePot, fee);
    uint256 rentAmount = amount / 10;
    orderPlatform1.addToken(pToken);
    assert(orderPlatform1.isToken(pToken));
    ///SELLLER
    vm.startPrank(addr1);
    dollar.approve(address(pToken), max);
    dollar.mint(amount);
    pToken.buy(addr1, rentAmount);
    require(pToken.balanceOf(addr1) == rentAmount, "Buy ft error");
    (uint8 v, bytes32 r, bytes32 s) = getVRS(
      address(pToken),
      addr1,
      address(orderPlatform1),
      rentAmount,
      max
    );

    orderPlatform1.initSellOrder(
      address(pToken),
      address(dollar),
      rentAmount,
      price,
      max,
      v,
      r,
      s
    );
    require(pToken.balanceOf(addr1) == 0, "Sell Order ft error");
    require(
      pToken.balanceOf(address(orderPlatform1)) == rentAmount,
      "Sell Order ft error"
    );
    vm.stopPrank();
    //BUYER
    vm.startPrank(addr2);
    dollar.mint(price);
    dollar.approve(address(orderPlatform1), max);
    orderPlatform1.buy(address(pToken), 0);
    vm.stopPrank();
    //CONTRACT
    orderPlatform1.withdrawFee(address(dollar));

    require((price / 1000) * fee == dollar.balanceOf(feePot), "FeeProblem");
  }

  function testOTCbuyOrder(
    uint256 amount,
    uint256 price,
    uint16 fee
  ) public {
    console.log(uint64(block.timestamp));
    vm.assume(fee < 1000);
    vm.assume(amount / 10 < (pToken.MAX_SUPPLY() / 1000) * 30);
    vm.assume(amount > 1000);
    vm.assume(price > 1000);
    vm.assume(price < max / 1000);
    OTC orderPlatform = new OTC(address(dollar), feePot, fee);
    uint256 rentAmount = amount / 10;
    orderPlatform.addToken(pToken);
    assert(orderPlatform.isToken(pToken));
    ///SELLLER
    vm.startPrank(addr1);
    dollar.approve(address(orderPlatform), max);
    dollar.mint(price);
    require(dollar.balanceOf(addr1) == price, "Buy ft error");

    orderPlatform.initBuyOrder(
      address(pToken),
      address(dollar),
      rentAmount,
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
    dollar.mint(amount);
    dollar.approve(address(pToken), amount);
    pToken.buy(addr2, rentAmount);
    require(pToken.balanceOf(addr2) == rentAmount, "Buy ft error");
    (uint8 v, bytes32 r, bytes32 s) = getVRS(
      address(pToken),
      addr2,
      address(orderPlatform),
      rentAmount,
      max
    );
    pToken.approve(address(orderPlatform), rentAmount);
    (
      ,
      ,
      uint64 indexr,
      ,
      ,
      address buyerr,
      uint256 feer,
      uint256 pricer,
      uint256 amountr,

    ) = orderPlatform.buyOrderByToken(address(pToken), 0);
    require(amountr == rentAmount, "Amount err");
    require(buyerr == addr1, "Buyer problem");
    require(pricer == price, "Buyer problem");
    if (fee > 0) require(feer == (price * fee) / amount);
    // orderPlatform.sell(address(pToken), uint64(0), max, v, r, s);

    vm.stopPrank();
    //CONTRACT
    //   orderPlatform.withdrawFee(address(dollar));

    //   require((price / 1000) * fee == dollar.balanceOf(feePot), "FeeProblem");
  }

  function testRentHouse() public {}

  function getVRS(
    address token,
    address owner,
    address spender,
    uint256 amount,
    uint256 dl
  )
    internal
    returns (
      uint8,
      bytes32,
      bytes32
    )
  {
    bytes32 structHash = keccak256(
      abi.encode(
        _PERMIT_TYPEHASH,
        owner,
        spender,
        amount,
        IERC20Permit(token).nonces(owner),
        dl
      )
    );
    bytes32 newDomainSeparator = keccak256(
      abi.encode(
        keccak256(
          "EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)"
        ),
        keccak256(bytes(ERC20(token).name())), // ERC-20 Name
        keccak256(bytes("1")), // Version
        block.chainid,
        address(IERC20(token))
      )
    );

    bytes32 hashed = ECDSA.toTypedDataHash(newDomainSeparator, structHash);

    return (vm.sign(1, hashed));
  }
}
