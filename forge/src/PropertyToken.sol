//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.10;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/draft-ERC20Permit.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract PropertyToken is ERC20Permit, Ownable {
  event Buying(address buyer, uint256 amount);

  mapping(address => uint256) public tokensBought;

  uint256 public immutable MAX_SUPPLY;
  uint256 public immutable MAX_TO_BUY;
  address public immutable multisig;
  IERC20 immutable currencyUsed;

  constructor(
    IERC20 _currencyUsed,
    uint256 _max_supply,
    address _multiSig,
    string memory _name,
    string memory _symbol
  ) ERC20(_name, _symbol) ERC20Permit(_name) {
    currencyUsed = _currencyUsed;
    multisig = _multiSig;
    MAX_SUPPLY = _max_supply;
    MAX_TO_BUY = (_max_supply * 30) / 100;
  }

  function transferToWithPermission(
    address from,
    address spender,
    address receiver,
    uint256 amount,
    uint256 deadline,
    uint8 v,
    bytes32 r,
    bytes32 s
  ) external {
    permit(from, spender, amount, deadline, v, r, s);
    transferFrom(from, receiver, amount);
  }

  function buy(address _to, uint256 amount) external {
    IERC20 doll = currencyUsed;
    require(
      tokensBought[msg.sender] + amount <= MAX_TO_BUY,
      "This Address bought too much tokens"
    );
    require(amount + totalSupply() <= MAX_SUPPLY, "Maximum supply exceeded");
    doll.transferFrom(msg.sender, owner(), amount * 10);
    _mint(_to, amount);
    tokensBought[msg.sender] += amount;
    emit Buying(_to, amount);
  }

  function withdraw() external onlyOwner {
    uint256 balance = currencyUsed.balanceOf(address(this));
    currencyUsed.transfer(multisig, balance);
  }
}
