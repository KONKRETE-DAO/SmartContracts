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
  uint256 amountToBuy = 1000 * makeDecimals;
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
  OTC orderPlatform = new OTC(address(dollar), feePot, 250);

  function setUp() public {}

  function testDebtHouse() public {
    console.log(block.chainid);
    orderPlatform.addToken(dFtToken);
    assert(orderPlatform.isToken(dFtToken));
    vm.startPrank(addr1);
    console.log(addr1);
    dollar.approve(address(dFtToken), max);
    (uint8 v, bytes32 r, bytes32 s) = getVRS(
      address(dFtToken),
      addr1,
      address(orderPlatform),
      amountToBuy,
      max
    );
    dollar.mint(10001 * makeDecimals);
    dFtToken.buy(addr1, amountToBuy);
    require(dFtToken.balanceOf(addr1) == amountToBuy, "Buy ft error");
    orderPlatform.initSellOrder(
      address(dFtToken),
      address(dollar),
      amountToBuy,
      123456 * makeDecimals,
      max,
      v,
      r,
      s
    );
    require(dFtToken.balanceOf(addr1) == 0, "Sell Order ft error");
    require(
      dFtToken.balanceOf(address(orderPlatform)) == amountToBuy,
      "Sell Order ft error"
    );
    vm.stopPrank();
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
