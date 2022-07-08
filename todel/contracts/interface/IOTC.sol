//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.10;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
struct orderInfo {
  bool open;
  bool propositionAccepted;
  uint64 index;
  uint64 date;
  address seller;
  address buyer;
  uint256 fee;
  uint256 price;
  uint256 amount;
  IERC20 currency;
}
struct currencyInfos {
  bool exist;
  uint16 feeX10;
  uint256 feePot; // maaybe
}

interface IOTC {
  //Variables
  function tokenList() external returns (IERC20[] calldata);

  function sellOrderByToken(IERC20 token)
    external
    returns (orderInfo[] calldata);

  function buyOrderByToken(IERC20 token)
    external
    returns (orderInfo[] calldata);

  function currencyUsed() external returns (IERC20);

  //0x19f37361
  function isToken(address) external returns (bool);

  //0xd48bfca7
  function addToken(address) external;

  //0x8e005553
  function setFee(uint16 feeX100) external;

  //0x6bdf6b39
  function initSellOrder(
    address,
    address,
    uint256,
    uint256,
    uint256,
    uint8,
    bytes32,
    bytes32
  ) external;

  //de8645e6
  function initBuyOrder(
    address,
    address,
    uint256,
    uint256
  ) external;

  //0xb127a88e
  function cancelOrder(
    IERC20 token,
    bool TrueForSellFalseForBuy,
    uint64 index
  ) external;

  //0xed0539b6
  function buy(IERC20 token, uint64 index) external;

  //0xd28c3a9b
  function sell(
    address,
    uint64,
    uint256,
    uint8,
    bytes32,
    bytes32
  ) external;
}
