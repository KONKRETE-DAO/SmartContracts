//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.12;
import "@openzeppelin/contracts/token/ERC20/extensions//draft-IERC20Permit.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import "forge-std/Test.sol";

library Utils {
  bytes32 _PERMIT_TYPEHASH =
    keccak256(
      "Permit(address owner,address spender,uint256 value,uint256 nonce,uint256 deadline)"
    );

  function getVRS(
    address token,
    address owner,
    address spender,
    uint256 firstPrice,
    uint256 dl,
    uint256 priv_key
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
        keccak256(bytes(ERC20(token).name())), // ERC-20 Name
        keccak256(bytes("1")), // Version
        block.chainid,
        address(IERC20(token))
      )
    );
    bytes32 hashed = ECDSA.toTypedDataHash(newDomainSeparator, structHash);
    return (vm.sign(priv_key, hashed));
  }
}
