//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.12;

import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./interface/IPropertyToken.sol";
import "./interface/IStaking.sol";

contract KonkretStaking is IERC20, Ownable, ReentrancyGuard {
  event MonthRentRewardArrived(uint256 rentAmount);
  event Staked(address who, uint256 amount, uint256 timeStamp);
  event unStaked(address who, uint256 amount, uint256 timeStamp);

  mapping(address => mapping(address => stakeInfo)) public stakeOfTokenByOwner;
  mapping(address => tokenInfo) public infoForToken;

  uint256 public monthTimeStamp;

  constructor(address tokenToStake, address treasury) {
    infoForToken[tokenToStake] = tokenInfo(
      true,
      IERC20(tokenToStake).symbol(),
      treasury,
      IPropertyToken(tokenToStake).MAX_SUPPLY()
    );
  }

  modifier onlyTreasury(address tokenAssociated) {
    require(msg.sender == infoForToken[tokenAssociated].treasury);
    _;
  }

  function _calculateShareratio(
    uint256 amount,
    uint256 lowTimestamp,
    uint256 lastTimeStamp
  ) private pure returns (uint256 res) {
    res = amount * (lastTimeStamp - lowTimestamp);
  }

  function beginTimestamp() external onlyOwner {
    monthTimeStamp = block.timestamp;
  }

  function stake(
    address token,
    uint256 _amount,
    uint256 deadline,
    uint8 v,
    bytes32 r,
    bytes32 s
  ) external nonReentrant {
    require(
      _amount > 1 * (10**IERC20(token).decimals()),
      "You have to stake at least 1 pToken"
    );
    require(
      _amount <= IERC20(token).balanceOf(msg.sender),
      "You have to stake at least 1 pToken"
    );

    IPropertyToken(token).transferToWithPermission(
      msg.sender,
      address(this),
      _amount,
      deadline,
      v,
      r,
      s
    );

    stakeInfo memory stakeBuffer = stakeOfTokenByOwner[token][msg.sender];

    if (stakeBuffer.rank == 0) {
      stakers.push(msg.sender);
      stakeBuffer.rank = uint64(stakers.length);
    }

    uint256 newTimeStamp = block.timestamp;

    stakeBuffer.preShare = _calculateShareratio(
      stakeBuffer.amount,
      stakeBuffer.lastTimeStamp,
      newTimeStamp
    );

    stakeBuffer.lastTimeStamp = uint64(newTimeStamp);

    stakeBuffer.amount += _amount;

    stakeOfTokenByOwner[token][msg.sender] = stakeBuffer;

    emit Staked(msg.sender, _amount, newTimeStamp);
  }

  function unStake(uint256 _amount) external nonReentrant {
    stakeInfo memory stakeBuffer = stakeOfTokenByOwner[token][msg.sender];

    require(stakeBuffer.amount >= _amount, "Can't unstake this much");

    uint256 newTimeStamp = uint256(block.timestamp);

    stakeBuffer.preShare = _calculateShareratio(
      stakeBuffer.amount,
      stakeBuffer.lastTimeStamp,
      newTimeStamp
    );

    stakeBuffer.lastTimeStamp = uint64(newTimeStamp);

    stakeBuffer.amount -= _amount;

    TOKEN_TO_STAKE.transfer(msg.sender, _amount);

    stakeOfTokenByOwner[token][msg.sender] = stakeBuffer;

    emit unStaked(msg.sender, _amount, newTimeStamp);
  }

  function _getClaimableReward(
    uint256 newTimeStamp,
    stakeInfo memory _stakeInfo,
    uint256 denominator,
    uint256 _totalreward
  ) private pure returns (stakeInfo memory) {
    _stakeInfo.claimableReward =
      (_totalreward *
        (_stakeInfo.preShare +
          _calculateShareratio(
            _stakeInfo.amount,
            _stakeInfo.lastTimeStamp,
            newTimeStamp
          ))) /
      denominator;

    _stakeInfo.lastTimeStamp = uint64(newTimeStamp);

    _stakeInfo.preShare = 0;

    return (_stakeInfo);
  }

  function getStakeInfo(address tokenHolder)
    public
    view
    returns (stakeInfo memory)
  {
    return ((stakeOfTokenByOwner[token][tokenHolder]));
  }

  function setTotalClaimableReward(uint256 totalReward)
    external
    nonReentrant
    onlyTreasury
    returns (uint256)
  {
    uint256 rest = totalReward;

    stakeInfo memory buffer;

    address[] memory stakersBuffer = stakers;

    uint256 newTimeStamp = block.timestamp;

    uint256 totalDenominator = (newTimeStamp - monthTimeStamp) *
      TOKEN_TO_STAKE_MAX_SUPPLY;

    for (uint256 i = 0; i < stakersBuffer.length; ) {
      buffer = _getClaimableReward(
        newTimeStamp,
        stakeOfTokenByOwner[token][stakersBuffer[i]],
        totalDenominator,
        totalReward
      );

      rest -= buffer.amount;

      stakeOfTokenByOwner[token][stakersBuffer[i]] = buffer;
      unchecked {
        ++i;
      }
    }

    monthTimeStamp = newTimeStamp;

    emit MonthRentRewardArrived(totalReward);

    return (rest);
  }
}
