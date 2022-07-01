//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.10;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

struct StakeInfos {
    bool exist;
    uint64 rank;
    uint64 lastTimeStamp;
    uint256 preShare;
    uint256 amount;
    uint256 claimableReward;
}

struct TokenInfos {
    bool exist;
    uint64 monthTimeStamp;
    string symbol;
    address treasury;
    uint256 MAX_SUPPLY;
}

interface IStaking {
    function TOKEN_TO_STAKE() external view returns (address);

    function TOKEN_TO_STAKE_MAX_SUPPLY() external view returns (uint256);

    //0x672a0fb8
    function beginTimestamp() external;

    //0xa694fc3a
    function stake(uint256 amount) external;

    //0x5d3eea91
    function unStake(uint256 amount) external;

    //0xc3453153
    function getStakeInfos(address tokenHolder) external;

    //0xc26c60de
    function setTotalClaimableReward(uint256 totalReward)
        external
        returns (uint256);

    function stakeByOwner(address owner) external returns (StakeInfos memory);

    function resetClaimableReward(address token, address staker) external;
}
