//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.10;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/draft-ERC20Permit.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract DebtPropertyToken is ERC20Permit, Ownable {
  mapping(address => uint256) public tokenBought;
  uint256 public immutable MAX_SUPPLY;
  uint256 public immutable MAX_TO_BUY;
  IERC20 immutable currencyUsed;
  address public cexAddress;

  // uint public perTenThousand;
  event Buying(address buyer, uint256 amount);

  constructor(IERC20 _currencyUsed, uint256 _max_supply)
    ERC20("3 allee de l'epee, 78688 Voisin le Bretonneux", "3AdlE78VlB")
    ERC20Permit("3 allee de l'epee, 78688 Voisin le Bretonneux")
  {
    currencyUsed = _currencyUsed;
    MAX_SUPPLY = _max_supply;
    MAX_TO_BUY = (_max_supply * 30) / 100;
  }

  function buy(address _to, uint256 amount) external {
    IERC20 doll = currencyUsed;
    require(
      tokenBought[msg.sender] <= MAX_TO_BUY,
      "This Address bought too much tokens"
    );
    require(amount + totalSupply() <= MAX_SUPPLY, "Too much");
    bool res = doll.transferFrom(msg.sender, owner(), amount * 10);
    require(res, "Couldn't receive currencyUsed");
    _mint(_to, amount);
    emit Buying(_to, amount);
  }

  function withdraw() external onlyOwner {
    uint256 balance = currencyUsed.balanceOf(address(this));
    currencyUsed.transfer(cexAddress, balance);
  }
}
