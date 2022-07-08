//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.13;

import "@openzeppelin/contracts-upgradeable/token/ERC20/extensions/draft-ERC20PermitUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts-upgradeable/security/ReentrancyGuardUpgradeable.sol";

enum Step {
    Deployed,
    Sale,
    Soldout
}
struct Variables {
    Step step;
    uint32 cexRatioX10000;
    bytes32 merkleRoot;
    uint128 MaxToBuy;
    address bank;
    IERC20 currencyUsed;
}

contract PropertyTokenV2 is
    ERC20PermitUpgradeable,
    AccessControlUpgradeable,
    UUPSUpgradeable,
    ReentrancyGuardUpgradeable
{
    uint256 public constant TOKENPRICE = 10;
    uint256 public constant MAX_SUPPLY = 65000 ether;
    bytes32 private constant DEV = keccak256("DEV");
    bytes32 private constant KONKRETE = keccak256("KONKRETE");
    Variables public variables;
    mapping(address => uint256) public tokensBought;

    function _authorizeUpgrade(address) internal override onlyRole(KONKRETE) {}

    function setCurrency(address currencyToUse) external onlyRole(DEV) {
        Variables memory bufferVariables = variables;
        bufferVariables.currencyUsed.transfer(
            bufferVariables.bank,
            bufferVariables.currencyUsed.balanceOf(address(this))
        );
        bufferVariables.currencyUsed = IERC20(currencyToUse);
        variables = bufferVariables;
    }

    function setMaxToBuy(uint128 _maxToBuy) external onlyRole(DEV) {
        require(_maxToBuy > 100 ether, "TLCD");
        variables.MaxToBuy = _maxToBuy;
    }
}
