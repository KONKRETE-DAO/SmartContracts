//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.12;


import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

struct stakeInfo{
     uint64     rank;
    uint128     preShare;
    uint128     lastTimeStamp;
    uint128     amount;
    uint128     claimableReward;
}

interface  MYERC20  {
    function  MAX_SUPPLY() external view returns (uint);

}
contract KonkretStaking is ERC20, Ownable, ReentrancyGuard{
    mapping(address => stakeInfo) public stakeByOwner;
    address[] public stakers;
    uint public monthTimeStamp;
    IERC20 immutable TOKEN_TO_STAKE;
    uint immutable   TOKEN_TO_STAKE_MAX_SUPPLY;
    IERC20 immutable fakeDoll;





    event Staked(address who,uint amount , uint timeStamp);
    event unStaked(address who,uint amount , uint timeStamp);

    constructor(string memory protoSymbol, address _tokenToStake, address _currencyUsedToPay) ERC20("stakedKonkreteToken", protoSymbol) {
        TOKEN_TO_STAKE = IERC20(_tokenToStake);
        /// A changer
        TOKEN_TO_STAKE_MAX_SUPPLY = MYERC20(_tokenToStake).MAX_SUPPLY();
        fakeDoll = IERC20(_currencyUsedToPay);

    }

    function _calculateShareratio(uint amount, uint lowTimestamp, uint lastTimeStamp) private pure returns(uint128 res){
        return(uint128(amount * (lastTimeStamp - lowTimestamp)));
    }

    function beginTimestamp() external onlyOwner {
        monthTimeStamp = block.timestamp;
    }
    function stake(uint128 _amount) external nonReentrant {
        IERC20 tokenToStakeBuff = TOKEN_TO_STAKE;
        require(tokenToStakeBuff.allowance(msg.sender, address(this)) >= _amount, "Need to allow transfer first");
        require(tokenToStakeBuff.balanceOf(msg.sender) >= _amount, "Too much for balance");
        bool res = tokenToStakeBuff.transferFrom(msg.sender, address(this), _amount);
        require(res, "Transfer failed");
        stakeInfo memory infoBuffer = stakeByOwner[msg.sender];
        if (infoBuffer.rank == 0) {
            stakers.push(msg.sender);
            infoBuffer.rank = uint64(stakers.length);
        }
        uint128 newTimeStamp = uint128(block.timestamp);
        infoBuffer.preShare = _calculateShareratio(infoBuffer.amount, infoBuffer.lastTimeStamp, newTimeStamp);
        infoBuffer.lastTimeStamp = newTimeStamp;
        infoBuffer.amount += _amount;
        stakeByOwner[msg.sender] = infoBuffer;
        emit Staked(msg.sender, _amount, newTimeStamp);
    }

    function unStake(uint128 _amount) external nonReentrant {
        stakeInfo memory infoBuffer =  stakeByOwner[msg.sender];
        require(infoBuffer.amount >= _amount, "Can't unstake this much");
        uint128 newTimeStamp = uint128(block.timestamp);
        infoBuffer.preShare = _calculateShareratio(infoBuffer.amount, infoBuffer.lastTimeStamp, newTimeStamp);
        infoBuffer.lastTimeStamp = newTimeStamp;
        infoBuffer.amount -= _amount;
        TOKEN_TO_STAKE.transfer(msg.sender, _amount);
        stakeByOwner[msg.sender] = infoBuffer;
        emit unStaked(msg.sender , _amount, newTimeStamp);
    }
  
    function _getClaimableReward(uint128 newTimeStamp, stakeInfo memory _stakeInfo, uint128 denominator, uint128 _totalreward) private pure returns (stakeInfo memory) {
        _stakeInfo.claimableReward = _totalreward * (_stakeInfo.preShare + 
            _calculateShareratio(_stakeInfo.amount, _stakeInfo.lastTimeStamp,newTimeStamp )) / denominator;
        _stakeInfo.lastTimeStamp = newTimeStamp;
        _stakeInfo.preShare = 0;
        return(_stakeInfo);
    }
    function getStakeInfo(address tokenHolder) public view returns(stakeInfo memory) {
        return (
            (stakeByOwner[tokenHolder])
        );
    } 

    function setTotalClaimableReward(uint128 totalReward) external onlyOwner nonReentrant {
        address[] memory stakersBuffer = stakers;
        uint128 newTimeStamp = uint128(block.timestamp);
        uint totalDenominator = (newTimeStamp - monthTimeStamp) * TOKEN_TO_STAKE_MAX_SUPPLY;
        for (uint i = 0; i < stakersBuffer.length ;){
            stakeByOwner[stakersBuffer[i]] = _getClaimableReward(newTimeStamp, stakeByOwner[stakersBuffer[i]], uint128(totalDenominator), totalReward);
            unchecked {++i;}
        }
        monthTimeStamp = newTimeStamp;
    }
    // function getStakeInfo()
    function claimReward() external nonReentrant {
        uint amount = uint256((stakeByOwner[msg.sender]).claimableReward);
        require(amount > 0 , "Can't claim anything");
        address moneyOwner = owner();
        fakeDoll.transferFrom(moneyOwner, msg.sender, amount);
    }
                                                                                             
}

