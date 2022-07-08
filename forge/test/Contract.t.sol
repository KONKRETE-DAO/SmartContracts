// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../src/PropertyToken.sol";
import "../src/OTC.sol";
import "../src/interface/IOTC.sol";
import "../src/mocktoken.sol";

contract ContractTest is Test {
  uint256 public makeDecimals = 10**18;
  uint256 public max =
    0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff;

  uint256 public housePrice = 221550 * makeDecimals;
  uint256 public dFtMAX_SUPPLY = housePrice / 10; /* in dollar for now*/
  address public addr1 = vm.addr(1);
  address public addr2 = vm.addr(2);
  address public feePot = vm.addr(3);
  address public multisig = vm.addr(4);
  address public bank = vm.addr(5);
  MockToken public dollar = new MockToken("lol", "ll", 18);
  PropertyToken public pToken =
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

  function getVRS(
    address token,
    address owner,
    address spender,
    uint256 firstPrice,
    uint256 dl,
    uint256 priv_key
  )
    public
    returns (
      uint8,
      bytes32,
      bytes32
    )
  {
    bytes32 structHash = keccak256(
      abi.encode(
        keccak256(
          "Permit(address owner,address spender,uint256 value,uint256 nonce,uint256 deadline)"
        ),
        owner,
        spender,
        firstPrice,
        IERC20Permit(token).nonces(owner),
        dl
      )
    );
    bytes32 newDomainSeparator = keccak256(
      abi.encode(
        keccak256(
          "EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)"
        ),
        keccak256(bytes(IPropertyToken(token).name())), // ERC-20 Name
        keccak256(bytes("1")), // Version
        block.chainid,
        address(IERC20Permit(token))
      )
    );
    bytes32 hashed = ECDSA.toTypedDataHash(newDomainSeparator, structHash);
    return (vm.sign(priv_key, hashed));
  }
}
