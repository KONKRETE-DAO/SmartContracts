//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.12;

import "@openzeppelin/contracts/access/Ownable.sol";
import "./interface/IOTC.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

contract OTC is Ownable, ReentrancyGuard {
  event SellOrderInitiated(orderInfo);
  event BuyOrderInitiated(orderInfo);

  mapping(IERC20 => orderInfo[]) public sellOrderByToken;
  mapping(IERC20 => orderInfo[]) public buyOrderByToken;

  IERC20[] public tokenList;
  IERC20 public immutable currencyUsed;

  contractVariables public c;

  constructor(
    IERC20 _currencyUsed,
    address _feeAddress,
    uint16 feex10
  ) {
    currencyUsed = _currencyUsed;
    c.feeAddress = _feeAddress;
    c.feeX10 = feex10;
  }

  function setFeeAddress(address newFeeAddress) external onlyOwner {
    c.feeAddress = newFeeAddress;
  }

  function withdrawFee() external onlyOwner {
    contractVariables memory buffer = c;
    currencyUsed.transfer(buffer.feeAddress, buffer.feePot);
  }

  function addToken(IERC20 token) external onlyOwner {
    require(!isToken(token), "Token already added");
    tokenList.push(token);
  }

  function isToken(IERC20 token) public view returns (bool) {
    IERC20[] memory buffer = tokenList;
    uint256 max = buffer.length;
    for (uint256 i = 0; i < max; ) {
      if (buffer[i] == token) {
        return true;
      }
      unchecked {
        ++i;
      }
    }
    return false;
  }

  function setFee(uint16 feePercentx10) external onlyOwner {
    c.feeX10 = feePercentx10;
  }

  function sellOrder(
    IERC20 token,
    uint256 amount,
    uint256 sellPrice
  ) external nonReentrant {
    require(isToken(token), "Token Not Registered");
    // Le front verifiera a l'avance l'allowance et la balance.
    uint64 index = uint64(sellOrderByToken[token].length);
    token.transferFrom(msg.sender, address(this), amount);
    // Erreur prise en compte
    uint128 fee = uint128((sellPrice / 1000) * c.feeX10);
    sellOrderByToken[token].push(
      orderInfo(
        true,
        false,
        index,
        uint64(block.timestamp),
        fee,
        msg.sender,
        address(0),
        sellPrice,
        amount
      )
    );
    emit SellOrderInitiated(
      orderInfo(
        true,
        false,
        index,
        uint64(block.timestamp),
        fee,
        msg.sender,
        address(0),
        sellPrice,
        amount
      )
    );
  }

  function buyOrder(
    IERC20 token,
    uint256 amount,
    uint256 sellPrice
  ) external nonReentrant {
    require(isToken(token), "Token Not Registered");
    // Le front verifiera a l'avance l'allowance et la balance.
    uint128 fee = uint128(((sellPrice * uint256(c.feeX10)) / 1000));
    currencyUsed.transferFrom(msg.sender, address(this), sellPrice); // Erreur prise en compte
    uint64 index = uint64(buyOrderByToken[token].length);
    buyOrderByToken[token].push(
      orderInfo(
        true,
        false,
        index,
        uint64(block.timestamp),
        fee,
        address(0),
        msg.sender,
        sellPrice,
        amount
      )
    );
    emit BuyOrderInitiated(
      orderInfo(
        true,
        false,
        index,
        uint64(block.timestamp),
        fee,
        address(0),
        msg.sender,
        sellPrice,
        amount
      )
    );
  }

  function cancelOrder(
    IERC20 token,
    bool TrueForSellFalseForBuy,
    uint64 index
  ) external nonReentrant {
    require(isToken(token), "Token Unlisted");
    orderInfo memory buffer = TrueForSellFalseForBuy
      ? sellOrderByToken[token][index]
      : buyOrderByToken[token][index];
    require(
      buffer.seller == msg.sender || buffer.buyer == msg.sender,
      "Cancel unauthorized"
    );
    buffer.open = false;
    if (TrueForSellFalseForBuy) {
      token.transfer(msg.sender, buffer.amount);
      sellOrderByToken[token][index] = buffer;
    } else {
      currencyUsed.transfer(msg.sender, buffer.amount + buffer.fee);
      buyOrderByToken[token][index] = buffer;
    }
  }

  function buy(IERC20 token, uint64 index) external nonReentrant {
    require(isToken(token), "Token Unlisted");
    orderInfo memory buffer = sellOrderByToken[token][index];
    require(buffer.open, "OrderClosed");
    buffer.buyer = msg.sender;
    buffer.propositionAccepted = true;
    sellOrderByToken[token][index] = buffer;
    currencyUsed.transferFrom(msg.sender, address(this), buffer.price);
    currencyUsed.transfer(buffer.seller, buffer.price - buffer.fee);
    c.feePot += buffer.fee;
    token.transfer(msg.sender, buffer.amount);
  }

  function sell(IERC20 token, uint64 index) external nonReentrant {
    require(isToken(token), "Token Unlisted");
    orderInfo memory buffer = buyOrderByToken[token][index];
    require(buffer.open, "OrderClosed");
    buffer.seller = msg.sender;
    buffer.propositionAccepted = true;
    token.transferFrom(msg.sender, buffer.buyer, buffer.amount);
    currencyUsed.transfer(msg.sender, buffer.price - buffer.fee);
    c.feePot += buffer.fee;
    buyOrderByToken[token][index] = buffer;
  }
}
