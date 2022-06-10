//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.10;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

interface StakingContract  {
    function TOKEN_TO_STAKE() external view returns (IERC20);
    function    TOKEN_TO_STAKE_MAX_SUPPLY() external view returns (uint);
    function setTotalClaimableReward(uint128 ) external;
}
struct ContractInfo {
    StakingContract stakingContract;
    uint maxSupply;
}
abstract contract Treasury is IERC20, Ownable {
    mapping(address => ContractInfo ) public  stakingContractByProperty;
    event RentDeposit(address Property, uint amount);
    IERC20 immutable public moneyToken;

    constructor(IERC20 _moneyToken)  {
    moneyToken = _moneyToken;
    }

    function addStakingContract(address  _stakingContract) external onlyOwner{
        address propertyToken = address(StakingContract(_stakingContract).TOKEN_TO_STAKE());
        require(propertyToken != 0x0000000000000000000000000000000000000000, "Wrong staking address");
        stakingContractByProperty[propertyToken] = ContractInfo(StakingContract(_stakingContract), StakingContract(_stakingContract).TOKEN_TO_STAKE_MAX_SUPPLY());
    }
    function deposit(address propertyToken, uint amount) external onlyOwner {
        ContractInfo memory bufferContract = stakingContractByProperty[propertyToken];
        require (bufferContract.maxSupply != 0, "Wrong Contract");
        bufferContract.stakingContract.setTotalClaimableReward(uint128(amount));
        moneyToken.transferFrom(msg.sender, address(this), amount);
    }

    
}
