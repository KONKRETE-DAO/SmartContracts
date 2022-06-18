//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.10;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

struct ContractInfo {
  address stakingContract;
  uint256 maxSupply;
}

interface StakingContract {
  function TOKEN_TO_STAKE() external view returns (address);

  function TOKEN_TO_STAKE_MAX_SUPPLY() external view returns (uint256);

  function setTotalClaimableReward(uint256) external;
}

contract Treasury is Ownable {
  mapping(address => ContractInfo) public stakingContractByProperty;
  event RentDeposit(address Property, uint256 amount);
  IERC20 public immutable moneyToken;

  constructor(IERC20 _moneyToken) {
    moneyToken = _moneyToken;
  }

  function addStakingContract(address _stakingContract) external onlyOwner {
    require(
      _stakingContract != 0x0000000000000000000000000000000000000000,
      "Wrong Address"
    );
    StakingContract buffer = StakingContract(_stakingContract);
    stakingContractByProperty[buffer.TOKEN_TO_STAKE()] = ContractInfo(
      _stakingContract,
      buffer.TOKEN_TO_STAKE_MAX_SUPPLY()
    );
  }

  function deposit(address propertyToken, uint256 amount) external onlyOwner {
    ContractInfo memory bufferContract = stakingContractByProperty[
      propertyToken
    ];
    require(bufferContract.maxSupply != 0, "Wrong Contract");

    StakingContract(bufferContract.stakingContract).setTotalClaimableReward(
      amount
    );
    moneyToken.approve(bufferContract.stakingContract, amount);

    moneyToken.transferFrom(msg.sender, address(this), amount);
  }
}
