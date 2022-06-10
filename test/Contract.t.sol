// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../src//Staking.sol";
import "../src//FakeDoll.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "../src//PropertyToken.sol";

contract ContractTest is  Test {
    using Strings for uint;
    FakeDoll dollar = new FakeDoll();
    PropertyToken ftToken = new PropertyToken(dollar, 10000 * (10 ** dollar.decimals()));
    KonkretStaking staking = new KonkretStaking('Voir symbol', address(ftToken), address(dollar));
    function setUp() public {}

    function testExample() public {
        bool lol = (dollar.balanceOf(address(this)) == 20000*(10** 18));
        uint i;
        assert(lol);
         staking.beginTimestamp();
        vm.warp(block.timestamp + 1);
        uint diff = block.timestamp - staking.monthTimeStamp();
        require( diff == 0, string(abi.encodePacked(diff.toString() , ' Seconde de retard')));

    }
}
