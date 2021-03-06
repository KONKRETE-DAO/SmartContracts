//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.13;

import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./interface/IPropertyToken.sol";
import "./interface/IStaking.sol";

contract KonkretStaking is Ownable, ReentrancyGuard {
    event MonthRentRewardArrived(uint256 rentAmount);
    event Staked(address who, uint256 amount, uint256 timeStamp);
    event unStaked(address who, uint256 amount, uint256 timeStamp);

    mapping(address => StakeInfos) public stakeByOwner;

    IPropertyToken public immutable TOKEN_TO_STAKE;
    uint256 public immutable TOKEN_TO_STAKE_MAX_SUPPLY;
    IERC20 immutable currency;
    address immutable treasury;

    address[] public stakers;
    uint256 public monthTimeStamp;

    constructor(
        address _tokenToStake,
        address _currencyUsedToPay,
        address _treasury
    ) {
        TOKEN_TO_STAKE = IPropertyToken(_tokenToStake);
        TOKEN_TO_STAKE_MAX_SUPPLY = IPropertyToken(_tokenToStake).MAX_SUPPLY();
        currency = IERC20(_currencyUsedToPay);
        treasury = _treasury;
    }

    modifier onlyTreasury() {
        require(msg.sender == treasury);
        _;
    }

    function _calculateShareratio(
        uint256 amount,
        uint256 lowTimestamp,
        uint256 lastTimeStamp
    ) private pure returns (uint256 res) {
        uint256 lol = amount * (lastTimeStamp - lowTimestamp);

        res = lol;
    }

    function beginTimestamp() external onlyOwner {
        monthTimeStamp = block.timestamp;
    }

    function stake(
        uint256 _amount,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external nonReentrant {
        require(monthTimeStamp != 0, "Staking is not activated");
        IPropertyToken tokenToStakeBuff = TOKEN_TO_STAKE;

        IPropertyToken(tokenToStakeBuff).transferFromWithPermission(
            msg.sender,
            address(this),
            _amount,
            deadline,
            v,
            r,
            s
        );

        StakeInfos memory infoBuffer = stakeByOwner[msg.sender];

        if (infoBuffer.rank == 0) {
            stakers.push(msg.sender);
            infoBuffer.rank = uint64(stakers.length);
        }

        uint256 newTimeStamp = block.timestamp;

        infoBuffer.preShare = _calculateShareratio(
            infoBuffer.amount,
            infoBuffer.lastTimeStamp,
            newTimeStamp
        );

        infoBuffer.lastTimeStamp = uint64(newTimeStamp);

        infoBuffer.amount += _amount;

        stakeByOwner[msg.sender] = infoBuffer;

        emit Staked(msg.sender, _amount, newTimeStamp);
    }

    function unStake(uint256 _amount) external nonReentrant {
        StakeInfos memory infoBuffer = stakeByOwner[msg.sender];

        require(infoBuffer.amount >= _amount, "Can't unstake this much");

        uint256 newTimeStamp = uint256(block.timestamp);

        infoBuffer.preShare = _calculateShareratio(
            infoBuffer.amount,
            infoBuffer.lastTimeStamp,
            newTimeStamp
        );

        infoBuffer.lastTimeStamp = uint64(newTimeStamp);

        infoBuffer.amount -= _amount;

        TOKEN_TO_STAKE.transfer(msg.sender, _amount);

        stakeByOwner[msg.sender] = infoBuffer;

        emit unStaked(msg.sender, _amount, newTimeStamp);
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

    function getStakeInfos(address tokenHolder)
        public
        view
        returns (StakeInfos memory)
    {
        return ((stakeByOwner[tokenHolder]));
    }

    function setTotalClaimableReward(uint256 totalReward)
        external
        nonReentrant
        onlyTreasury
        returns (uint256)
    {
        uint256 rest = totalReward;

        StakeInfos memory buffer;

        address[] memory stakersBuffer = stakers;

        uint256 newTimeStamp = block.timestamp;

        uint256 totalDenominator = (newTimeStamp - monthTimeStamp) *
            TOKEN_TO_STAKE_MAX_SUPPLY;

        for (uint256 i = 0; i < stakersBuffer.length; ) {
            buffer = _getClaimableReward(
                newTimeStamp,
                stakeByOwner[stakersBuffer[i]],
                totalDenominator,
                totalReward
            );

            rest -= buffer.amount;

            stakeByOwner[stakersBuffer[i]] = buffer;
            unchecked {
                ++i;
            }
        }

        monthTimeStamp = newTimeStamp;

        emit MonthRentRewardArrived(totalReward);

        return (rest);
    }
}
