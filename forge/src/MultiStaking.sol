//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.12;

import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./interface/IPropertyToken.sol";
import "./interface/IStaking.sol";

contract KonkretStaking is Ownable, ReentrancyGuard {
  event MonthRentRewardArrived(uint256 rentAmount, address token);
  event Staked(address who, address token, uint256 amount, uint256 timeStamp);
  event unStaked(address who, address token, uint256 amount, uint256 timeStamp);

  mapping(address => mapping(address => StakeInfos)) public stakeOfTokenByOwner;
  mapping(address => TokenInfos) public infoForToken;
  mapping(address => address[]) public stakersBytoken;

  constructor(
    address tokenToStake,
    address treasury,
    string memory symbol
  ) {
    infoForToken[tokenToStake] = TokenInfos(
      true,
      0,
      symbol,
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

  function beginTimestamp(address token) external onlyOwner {
    infoForToken[token].monthTimeStamp = uint64(block.timestamp);
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
      _amount > 10**IPropertyToken(token).decimals(),
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
    StakeInfos memory stakeBuffer = stakeOfTokenByOwner[token][msg.sender];

    if (stakeBuffer.rank == 0) {
      stakersBytoken[token].push(msg.sender);
      stakeBuffer.rank = uint64(stakersBytoken[token].length);
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

    emit Staked(msg.sender, token, _amount, newTimeStamp);
  }

  function resetClaimableReward(address token, address staker)
    external
    onlyTreasury(token)
  {
    stakeOfTokenByOwner[token][staker].claimableReward = 0;
  }

  function unStake(uint256 _amount, address token) external nonReentrant {
    StakeInfos memory stakeBuffer = stakeOfTokenByOwner[token][msg.sender];

    require(stakeBuffer.amount >= _amount, "Can't unstake this much");

    uint256 newTimeStamp = uint256(block.timestamp);

    stakeBuffer.preShare = _calculateShareratio(
      stakeBuffer.amount,
      stakeBuffer.lastTimeStamp,
      newTimeStamp
    );

    stakeBuffer.lastTimeStamp = uint64(newTimeStamp);

    stakeBuffer.amount -= _amount;

    IERC20(token).transfer(msg.sender, _amount);

    stakeOfTokenByOwner[token][msg.sender] = stakeBuffer;

    emit unStaked(msg.sender, token, _amount, newTimeStamp);
  }

  function getStakeInfos(address tokenHolder, address token)
    public
    view
    returns (StakeInfos memory)
  {
    return ((stakeOfTokenByOwner[token][tokenHolder]));
  }

  function _getClaimableReward(
    uint256 newTimeStamp,
    StakeInfos memory _StakeInfos,
    uint256 denominator,
    uint256 _totalreward
  ) private pure returns (StakeInfos memory) {
    _StakeInfos.claimableReward +=
      (_totalreward *
        (_StakeInfos.preShare +
          _calculateShareratio(
            _StakeInfos.amount,
            _StakeInfos.lastTimeStamp,
            newTimeStamp
          ))) /
      denominator;

    _StakeInfos.lastTimeStamp = uint64(newTimeStamp);

    _StakeInfos.preShare = 0;

    return (_StakeInfos);
  }

  function popStaker(address staker_, address token_) private {
    address[] memory stakers = stakersBytoken[token_];
    for (uint256 i = 0; i < stakers.length; ) {
      if (stakers[i] == staker_) {
        stakers[i] = stakers[stakers.length - 1];
        stakersBytoken[token_] = stakers;
        stakersBytoken[token_].pop();
        break;
      }
      unchecked {
        ++i;
      }
    }
  }

  function setTotalClaimableReward(uint256 totalReward, address token)
    external
    nonReentrant
    onlyTreasury(token)
    returns (uint256)
  {
    uint256 rest = totalReward;

    StakeInfos memory buffer;

    address[] memory stakersBuffer = stakersBytoken[token];

    uint256 newTimeStamp = block.timestamp;

    uint256 totalDenominator = (newTimeStamp -
      infoForToken[token].monthTimeStamp) * IPropertyToken(token).MAX_SUPPLY();

    for (uint256 i = 0; i < stakersBuffer.length; ) {
      buffer = _getClaimableReward(
        newTimeStamp,
        stakeOfTokenByOwner[token][stakersBuffer[i]], // Maybe go to assembly to improve as efficiency
        totalDenominator,
        totalReward
      );

      rest -= buffer.amount;

      stakeOfTokenByOwner[token][stakersBuffer[i]] = buffer;
      unchecked {
        ++i;
      }
    }

    infoForToken[token].monthTimeStamp = uint64(newTimeStamp);

    emit MonthRentRewardArrived(totalReward, token);

    return (rest);
  }
}
