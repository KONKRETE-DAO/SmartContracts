//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.12;

import "@openzeppelin/contracts/access/Ownable.sol";
import "./interface/IOTC.sol";
import "./interface/IPropertyToken.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

contract OTC is Ownable, ReentrancyGuard {
  event SellOrderInitiated(orderInfo);
  event BuyOrderInitiated(orderInfo);
  event BuyOrderAccepted(orderInfo);
  event SellOrderAccepted(orderInfo);
  event SellOrderCancelled(orderInfo);
  event BuyOrderCancelled(orderInfo);

  mapping(address => orderInfo[]) public sellOrderByToken;
  mapping(address => orderInfo[]) public buyOrderByToken;
  mapping(address => currencyInfos) public currencyByLink;

  IERC20[] public tokenList;
  IERC20[] public currenciesUsed;

  address feeAddress;

  constructor(
    address _currencyUsed,
    address _feeAddress,
    uint16 feex10
  ) {
    currenciesUsed.push(IERC20(_currencyUsed));
    feeAddress = _feeAddress;
    currencyByLink[_currencyUsed] = currencyInfos(true, feex10, 0);
  }

  function setFeeAddress(address newFeeAddress) external onlyOwner {
    feeAddress = newFeeAddress;
  }

  function setCurrency(
    address newCurrency,
    uint16 feeX10,
    uint256 feePot
  ) external onlyOwner {
    if (!currencyByLink[newCurrency].exist) {
      tokenList.push(IERC20(newCurrency));
    }
    currencyByLink[newCurrency] = currencyInfos(true, feeX10, feePot);
  }

  function withdrawFee(address currency) external onlyOwner {
    currencyInfos memory buffer = currencyByLink[currency];
    IERC20(currency).transfer(feeAddress, buffer.feePot);
    buffer.feePot = 0;
    currencyByLink[currency] = buffer;
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

  function setFee(uint16 feePercentx10, address currency) external onlyOwner {
    require(feePercentx10 < 500, "Fee Too high");
    currencyByLink[currency].feeX10 = feePercentx10;
  }

  function initSellOrder(
    address token,
    address currencyWanted,
    uint256 amount,
    uint256 sellPrice,
    uint256 deadline,
    uint8 v,
    bytes32 r,
    bytes32 s
  ) external nonReentrant {
    require(isToken(IERC20(token)), "Token Not Registered");
    currencyInfos memory bufferCurrency = currencyByLink[currencyWanted];
    require(bufferCurrency.exist, "Currency not tolerated");
    uint64 index = uint64(sellOrderByToken[token].length);
    IPropertyToken(token).transferToWithPermission(
      msg.sender,
      address(this),
      amount,
      deadline,
      v,
      r,
      s
    );
    // Erreur prise en compte
    uint128 fee = uint128((sellPrice / 1000) * bufferCurrency.feeX10);
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
        amount,
        IERC20(currencyWanted)
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
        amount,
        IERC20(currencyWanted)
      )
    );
  }

  function initBuyOrder(
    address token,
    address currencyWanted,
    uint256 amount,
    uint256 sellPrice
  ) external nonReentrant {
    require(isToken(IERC20(token)), "Token Not Registered");
    currencyInfos memory bufferCurrency = currencyByLink[currencyWanted];
    require(bufferCurrency.exist, "Currency not tolerated");
    uint128 fee = uint128(((sellPrice * bufferCurrency.feeX10) / 1000));
    IERC20(currencyWanted).transferFrom(msg.sender, address(this), sellPrice); // Erreur prise en compte
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
        amount,
        IERC20(currencyWanted)
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
        amount,
        IERC20(currencyWanted)
      )
    );
  }

  function cancelOrder(
    address token,
    bool TrueForSellFalseForBuy,
    uint64 index
  ) external nonReentrant {
    require(isToken(IERC20(token)), "Token Unlisted");
    orderInfo memory orderToCancel = TrueForSellFalseForBuy
      ? sellOrderByToken[token][index]
      : buyOrderByToken[token][index];
    require(
      orderToCancel.seller == msg.sender || orderToCancel.buyer == msg.sender,
      "Cancel unauthorized"
    );
    orderToCancel.open = false;
    if (TrueForSellFalseForBuy) {
      IERC20(token).transfer(msg.sender, orderToCancel.amount);
      sellOrderByToken[token][index] = orderToCancel;
      emit SellOrderCancelled(orderToCancel);
    } else {
      orderToCancel.currency.transfer(msg.sender, orderToCancel.price);
      buyOrderByToken[token][index] = orderToCancel;
      emit BuyOrderCancelled(orderToCancel);
    }
  }

  function buy(address token, uint64 index) external nonReentrant {
    require(isToken(IERC20(token)), "Token Unlisted");
    orderInfo memory sellOrder = sellOrderByToken[token][index];
    require(sellOrder.open, "OrderClosed");
    sellOrder.buyer = msg.sender;
    sellOrder.propositionAccepted = true;
    sellOrder.open = false;
    sellOrder.currency.transferFrom(msg.sender, address(this), sellOrder.price);
    sellOrder.currency.transfer(
      sellOrder.seller,
      sellOrder.price - sellOrder.fee
    );
    currencyByLink[address(sellOrder.currency)].feePot += sellOrder.fee;
    sellOrderByToken[token][index] = sellOrder;
    IERC20(token).transfer(msg.sender, sellOrder.amount);
    emit SellOrderAccepted(sellOrder);
  }

  function sell(
    address token,
    uint64 index,
    uint256 deadline,
    uint8 v,
    bytes32 r,
    bytes32 s
  ) external nonReentrant {
    require(isToken(IERC20(token)), "Token Unlisted");
    orderInfo memory buyOrder = buyOrderByToken[token][index];
    require(buyOrder.open, "OrderClosed");
    buyOrder.seller = msg.sender;
    buyOrder.propositionAccepted = true;
    buyOrder.open = false;
    IPropertyToken(token).transferToWithPermission(
      msg.sender,
      buyOrder.buyer,
      buyOrder.amount,
      deadline,
      v,
      r,
      s
    );
    buyOrder.currency.transfer(msg.sender, buyOrder.price - buyOrder.fee);
    currencyByLink[address(buyOrder.currency)].feePot += buyOrder.fee;
    buyOrderByToken[token][index] = buyOrder;
    emit BuyOrderAccepted(buyOrder);
  }
}