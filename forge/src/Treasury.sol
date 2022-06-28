//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.10;

import "@openzeppelin/contracts/access/Ownable.sol";
import "./interface/IStaking.sol";
import "./interface/ITreasury.sol";
import "./interface/IPropertyToken.sol";

contract Treasury is Ownable {
  event RentDeposit(uint256 amount);

  IERC20 public immutable currencyUsed;
  address public immutable pToken;
  IStaking public immutable stakingContract;
  uint256 public immutable MAX_TOKEN_SUPPLY;
  address public konkreteTreasury;

  constructor(
    IERC20 _currencyUsed,
    address _pToken,
    address _stakingContract
  ) {
    currencyUsed = _currencyUsed;
    pToken = _pToken;
    stakingContract = IStaking(_stakingContract);
    MAX_TOKEN_SUPPLY = IPropertyToken(_pToken).MAX_SUPPLY();
  }

  /*deposit the rent(amount) associated with the property,
  just keep the tamount claimable by the stakers */
  function deposit(uint256 amount) external onlyOwner {
    uint256 claimableByStaker = amount -
      stakingContract.setTotalClaimableReward(amount);
    currencyUsed.transferFrom(msg.sender, address(this), claimableByStaker);
    emit RentDeposit(amount);
  }

  function claimReward() external {
    IStaking bufferStaking = stakingContract;
    bufferStaking.stakeByOwner(msg.sender);
    bufferStaking.resetClaimableReward(pToken, msg.sender);
  }
}
