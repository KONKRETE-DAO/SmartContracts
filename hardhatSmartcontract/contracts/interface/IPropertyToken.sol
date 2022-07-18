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

    //83b43589
    function initialize(
        address,
        address,
        address,
        string calldata,
        string calldata
    ) external;

    //d5e5a5b4
    function withdraw(IERC20) external;

    //f75d6f80
    function setCexRatio(uint32) external;

    //f8dcbddb
    function setStep(uint256) external;

    //ea7a42e4
    function setAllowListMerkleRoot(bytes32) external;

    //cfac414b
    function transferFromWithPermission(
        address,
        address,
        uint256,
        uint256,
        uint8,
        bytes32,
        bytes32
    ) external;

    //e7572230
    function getPrice(uint256) external view returns (uint256);

    //4c13a639
    function buy(
        address,
        uint256,
        bytes32[] calldata
    ) external;
}
