//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.13;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/draft-ERC20Permit.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";

contract PropertyToken is ERC20Permit, Ownable {
    event Buying(address buyer, uint256 price, uint256 amount);

    mapping(address => uint256) public tokensBought;

    uint256 public constant TOKENPRICE = 10;
    uint256 public immutable MAX_SUPPLY;
    address public immutable multisig;

    enum Step {
        Deployed,
        Sale,
        Soldout
    }

    struct Variables {
        Step step;
        uint32 cexRatioX10000;
        bytes32 merkleRoot;
        uint128 MaxToBuy;
        IERC20 currencyUsed;
    }

    Variables public variables;

    constructor(
        IERC20 _currencyUsed,
        uint256 _MAX_SUPPLY,
        address _multiSig,
        string memory _name,
        string memory _symbol
    ) ERC20(_name, _symbol) ERC20Permit(_name) {
        variables = Variables(
            Step(0),
            0,
            0,
            uint128((_MAX_SUPPLY * 30) / 100),
            _currencyUsed
        );
        multisig = _multiSig;
        MAX_SUPPLY = _MAX_SUPPLY;
    }

    function withdraw() public onlyOwner {
        uint256 balance = variables.currencyUsed.balanceOf(address(this));
        variables.currencyUsed.transfer(multisig, balance);
    }

    function setCexRatio(uint32 _cexRatioX10000) external onlyOwner {
        require(_cexRatioX10000 < 16000, "1.6 euro for one dollar ?? ");
        require(_cexRatioX10000 > 6000, "0.6 euro for one dollar ?? ");
        variables.cexRatioX10000 = _cexRatioX10000;
        withdraw();
    }

    function setCurrency(IERC20 currencyToUse) external onlyOwner {
        variables.currencyUsed = currencyToUse;
        withdraw();
    }

    function setMaxToBuy(uint128 _MaxToBuy) external onlyOwner {
        require(
            _MaxToBuy > 100 * (10**decimals()),
            "Too low , check decimals!"
        );
        variables.MaxToBuy = _MaxToBuy;
        withdraw();
    }

    function setStep(uint256 step) external onlyOwner {
        require(step < 3, "Wrong number");
        variables.step = Step(step);
    }

    function setAllowListMerkleRoot(bytes32 merkleRoot) external onlyOwner {
        variables.merkleRoot = merkleRoot;
    }

    function _verify(bytes32[] calldata _proof) internal view returns (bool) {
        return
            MerkleProof.verifyCalldata(
                _proof,
                variables.merkleRoot,
                keccak256(abi.encodePacked(msg.sender))
            );
    }

    function transferFromWithPermission(
        address from,
        address receiver,
        uint256 amount,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external {
        permit(from, msg.sender, amount, deadline, v, r, s);
        transferFrom(from, receiver, amount);
    }

    modifier onlyWhitelist(bytes32[] calldata proof) {
        require(variables.step != Step(0), "Not yet");
        require(variables.step != Step(2), "Sold Out");
        require(_verify(proof), "Not Whitelisted");
        _;
    }

    function buy(
        address _to,
        uint256 price,
        bytes32[] calldata proof
    ) external onlyWhitelist(proof) {
        Variables memory bufferVariables = variables;
        uint256 amount = (price * bufferVariables.cexRatioX10000) /
            (10000 * TOKENPRICE);

        require(
            amount + totalSupply() <= MAX_SUPPLY,
            "Maximum supply exceeded"
        );
        require(
            tokensBought[msg.sender] + amount <= variables.MaxToBuy,
            "This Address bought too much tokens"
        );
        variables.currencyUsed.transferFrom(msg.sender, address(this), price);
        _mint(_to, amount);
        tokensBought[msg.sender] += amount;
        emit Buying(_to, price, amount);
    }
}
