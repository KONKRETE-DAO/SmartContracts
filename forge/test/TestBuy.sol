pragma solidity ^0.8.13;

import "./Contract.t.sol";

contract BuyTokenTest is ContractTest {
  function testBuy(uint256 firstPrice) public {
    pToken.setStep(1);
    pToken.setCexRatio(10000);
    vm.assume(firstPrice < pToken.MAX_SUPPLY());
    vm.startPrank(addr1);
    dollar.mint(addr1, firstPrice);
    dollar.approve(address(pToken), firstPrice);
    pToken.buy(addr1, firstPrice / 10);
    vm.stopPrank();
  }
}
