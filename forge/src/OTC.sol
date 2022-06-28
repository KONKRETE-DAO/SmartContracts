//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.12;

import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./interface/IPropertyToken.sol";
import "./interface/IOTC.sol";

contract OTC is Ownable, ReentrancyGuard {
  event SellOrderInitiated(OrderInfo);
  event SellOrderCancelled(OrderInfo);
  event SellOrderAccepted(OrderInfo);
  event BuyOrderInitiated(OrderInfo);
  event BuyOrderCancelled(OrderInfo);
  event BuyOrderAccepted(OrderInfo);

  mapping(address => OrderInfo[]) public sellOrderByToken;
  mapping(address => OrderInfo[]) public buyOrderByToken;
  mapping(address => CurrencyInfos) public currencyInfosByAddress;

  IERC20[] public tokenList;
  IERC20[] public currenciesUsed;

  address feeAddress;

  constructor(
    address _currencyUsed,
    address _feeAddress,
    uint16 feex10
  ) {
    require(feex10 <= 1000);
    currenciesUsed.push(IERC20(_currencyUsed));
    feeAddress = _feeAddress;
    currencyInfosByAddress[_currencyUsed] = CurrencyInfos(true, feex10, 0);
  }

  function setFeeAddress(address newFeeAddress) external onlyOwner {
    feeAddress = newFeeAddress;
  }

  function setCurrency(
    address newCurrency,
    uint16 feeX10,
    uint256 feePot
  ) external onlyOwner {
    if (!currencyInfosByAddress[newCurrency].exist) {
      tokenList.push(IERC20(newCurrency));
    }
    currencyInfosByAddress[newCurrency] = CurrencyInfos(true, feeX10, feePot);
  }

  function withdrawFee(address currency) external onlyOwner {
    CurrencyInfos memory buffer = currencyInfosByAddress[currency];
    IERC20(currency).transfer(feeAddress, buffer.feePot);
    buffer.feePot = 0;
    currencyInfosByAddress[currency] = buffer;
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
    currencyInfosByAddress[currency].feeX10 = feePercentx10;
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
    require(sellPrice > 1000, "SellPrice too low");
    require(isToken(IERC20(token)), "Token Not Registered");
    CurrencyInfos memory bufferCurrency = currencyInfosByAddress[
      currencyWanted
    ];
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
    uint256 fee = feeCalculation(sellPrice, bufferCurrency.feeX10);
    sellOrderByToken[token].push(
      OrderInfo(
        true,
        false,
        index,
        uint64(block.timestamp),
        msg.sender,
        address(0),
        fee,
        sellPrice,
        amount,
        IERC20(currencyWanted)
      )
    );
    emit SellOrderInitiated(
      OrderInfo(
        true,
        false,
        index,
        uint64(block.timestamp),
        msg.sender,
        address(0),
        fee,
        sellPrice,
        amount,
        IERC20(currencyWanted)
      )
    );
  }

  function feeCalculation(uint256 price, uint16 feex10)
    internal
    pure
    returns (uint256 res)
  {
    res = feex10 > 0 ? (price * uint256(feex10)) / 1000 : 0;
  }

  function initBuyOrder(
    address token,
    address currencyWanted,
    uint256 amount,
    uint256 sellPrice
  ) external nonReentrant {
    require(sellPrice > 1000, "SellPrice too low");
    require(isToken(IERC20(token)), "Token Not Registered");
    CurrencyInfos memory bufferCurrency = currencyInfosByAddress[
      currencyWanted
    ];
    require(bufferCurrency.exist, "Currency not tolerated");
    IERC20(currencyWanted).transferFrom(msg.sender, address(this), sellPrice); // Erreur prise en compte
    uint64 index = uint64(buyOrderByToken[token].length);
    uint256 fee = feeCalculation(sellPrice, bufferCurrency.feeX10);
    buyOrderByToken[token].push(
      OrderInfo(
        true,
        false,
        index,
        uint64(block.timestamp),
        address(0),
        msg.sender,
        fee,
        sellPrice,
        amount,
        IERC20(currencyWanted)
      )
    );
    emit BuyOrderInitiated(
      OrderInfo(
        true,
        false,
        index,
        uint64(block.timestamp),
        address(0),
        msg.sender,
        fee,
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
    OrderInfo memory orderToCancel = TrueForSellFalseForBuy
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
    OrderInfo memory sellOrder = sellOrderByToken[token][index];
    require(sellOrder.open, "OrderClosed");
    sellOrder.buyer = msg.sender;
    sellOrder.propositionAccepted = true;
    sellOrder.open = false;
    sellOrder.currency.transferFrom(msg.sender, address(this), sellOrder.price);
    sellOrder.currency.transfer(
      sellOrder.seller,
      sellOrder.price - sellOrder.fee
    );
    currencyInfosByAddress[address(sellOrder.currency)].feePot += sellOrder.fee;
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
    OrderInfo storage buyOrder = buyOrderByToken[token][index];
    require(buyOrder.open, "OrderClosed");
    require(buyOrder.buyer != address(0), "Wrong address");
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
    currencyInfosByAddress[address(buyOrder.currency)].feePot += buyOrder.fee;
    buyOrderByToken[token][index] = buyOrder;
    emit BuyOrderAccepted(buyOrder);
  }
}
