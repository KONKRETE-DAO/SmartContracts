// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../src/PropertyToken.sol";
import "../src/MockStable.sol";
import "../src/OTC.sol";

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
  PropertyToken dFtToken =
    new PropertyToken(
      dollar,
      dFtMaxSupply,
      multisig,
      "1 rue Affre, 75018 Paris",
      "1A75018"
    );

  function setUp() public {}

  function testBuy(uint256 amount) public {
    vm.assume(amount < dFtToken.MAX_SUPPLY());
    vm.startPrank(addr1);
    dollar.mint(amount);
    dollar.approve(address(dFtToken), amount);
    dFtToken.buy(addr1, amount / 10);
    vm.stopPrank();
  }

  function testStake() public {}

  function testOTCsellOrder(
    uint256 amount,
    uint256 price,
    uint16 fee
  ) public {
    vm.assume(fee < 1000);
    vm.assume(amount / 10 < (dFtToken.MAX_SUPPLY() / 1000) * 30);
    vm.assume(amount > 0);
    vm.assume(price > 1000);
    vm.assume(price < max / 1000);
    OTC orderPlatform = new OTC(address(dollar), feePot, fee);
    uint256 rentAmount = amount / 10;
    orderPlatform.addToken(dFtToken);
    // orderPlatform.setCurrency(dFtToken);
    assert(orderPlatform.isToken(dFtToken));
    ///SELLLER
    vm.startPrank(addr1);
    dollar.approve(address(dFtToken), max);
    dollar.mint(amount);
    dFtToken.buy(addr1, rentAmount);
    require(dFtToken.balanceOf(addr1) == rentAmount, "Buy ft error");
    (uint8 v, bytes32 r, bytes32 s) = getVRS(
      address(dFtToken),
      addr1,
      address(orderPlatform),
      rentAmount,
      max
    );

    orderPlatform.initSellOrder(
      address(dFtToken),
      address(dollar),
      rentAmount,
      price,
      max,
      v,
      r,
      s
    );
    require(dFtToken.balanceOf(addr1) == 0, "Sell Order ft error");
    require(
      dFtToken.balanceOf(address(orderPlatform)) == rentAmount,
      "Sell Order ft error"
    );
    vm.stopPrank();
    //BUYER
    vm.startPrank(addr2);
    dollar.mint(price);
    dollar.approve(address(orderPlatform), max);
    orderPlatform.buy(address(dFtToken), 0);
    vm.stopPrank();
    //CONTRACT
    orderPlatform.withdrawFee(address(dollar));

    require((price / 1000) * fee == dollar.balanceOf(feePot), "FeeProblem");
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
        IERC20Permit(token).nonces(addr1),
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
