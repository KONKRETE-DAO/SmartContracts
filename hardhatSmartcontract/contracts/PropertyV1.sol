//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.10;

import "@openzeppelin/contracts/access/Ownable.sol"; ////// To Copy !!!!!!!!!
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/extensions/draft-ERC20PermitUpgradeable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";
import "./interface/IPropertyToken.sol";

/*I had to copy and set the Owner of Oz to avoid Inheritance errors*/
contract PropertyTokenV1 is ERC20PermitUpgradeable {
    event Buying(address buyer, uint256 price, uint256 amount);
    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );
    uint256 public constant TOKENPRICE = 10;
    uint256 public constant MAX_SUPPLY = 65000 ether;

    mapping(address => uint256) public tokensBought;

    Variables public variables;
    address private _owner;

    modifier onlyOwner() {
        _checkOwner();
        _;
    }

    function owner() public view returns (address) {
        return _owner;
    }

    function _checkOwner() internal view {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
    }

    function transferOwnership(address newOwner) public onlyOwner {
        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }

    function initialize(
        address owner_,
        address _bank,
        address _currencyUsed,
        string memory _name,
        string memory _symbol
    ) external initializer {
        transferOwnership(owner_);
        variables = Variables(
            Step(0),
            0,
            0,
            uint128((MAX_SUPPLY * 30) / 100),
            _bank,
            IERC20(_currencyUsed)
        );
        __ERC20_init(_name, _symbol);
        __ERC20Permit_init(_name);
    }

    function withdraw() public onlyOwner {
        Variables memory bufferVariables = variables;
        bufferVariables.currencyUsed.transfer(
            bufferVariables.bank,
            bufferVariables.currencyUsed.balanceOf(address(this))
        );
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
        require(_MaxToBuy > 100 ether, "Too low , check decimals!");
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

    function transferToWithPermission(
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
