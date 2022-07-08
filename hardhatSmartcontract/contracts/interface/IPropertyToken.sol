//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.13;

import "@openzeppelin/contracts/token/ERC20/extensions/draft-IERC20Permit.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

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

interface IPropertyToken is IERC20, IERC20Permit {
    function MAX_SUPPLY() external view returns (uint256);

    //0xcce7ec13
    function buy(address _to, uint256 amount) external;

    //0x3ccfd60b
    function withdraw() external;

    function decimals() external view returns (uint256);

    //0x4320efc0
    function transferFromWithPermission(
        address from,
        address receiver,
        uint256 amount,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external;
}
