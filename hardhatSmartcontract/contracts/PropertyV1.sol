//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.13;

import "@openzeppelin/contracts-upgradeable/token/ERC20/extensions/draft-ERC20PermitUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/security/ReentrancyGuardUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";
import "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./interface/IPropertyToken.sol";

/* ERROR MESSAGES :
{
"RTH"     : "Ratio Too High"
"RTL"     : "Ratio Too Low"
"TLCD"    : "Too low , check decimals!"
"SINA"    : "Sale is Not active"
"SO"      : "Sold out"
"NWL"     : "Not Whitelisted"
"EMS"     : "Exceed max supply"
"TABTMT"  : "This Address bought too much tokens"
}
*/
contract PropertyTokenV1 is
    ERC20PermitUpgradeable,
    AccessControlUpgradeable,
    UUPSUpgradeable,
    ReentrancyGuardUpgradeable
{
    event Buying(address buyer, uint256 price, uint256 amount);

    uint256 public constant TOKENPRICE = 10;
    uint256 public constant MAX_SUPPLY = 65000 ether;
    bytes32 private constant DEV = keccak256("DEV");
    bytes32 private constant KONKRETE = keccak256("KONKRETE");

    Variables public variables;
    mapping(address => uint256) public tokensBought;

    function initialize(
        address _bank,
        address multisig,
        address _currencyUsed,
        string calldata _name,
        string calldata _symbol
    ) external initializer {
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
        __UUPSUpgradeable_init();
        _grantRole(DEV, msg.sender);
        _grantRole(DEV, multisig);
        _grantRole(KONKRETE, multisig);
        _setRoleAdmin(DEFAULT_ADMIN_ROLE, KONKRETE);
    }

    function _authorizeUpgrade(address) internal override onlyRole(KONKRETE) {}

    function withdraw() public onlyRole(DEV) {
        Variables memory bufferVariables = variables;
        bufferVariables.currencyUsed.transfer(
            bufferVariables.bank,
            bufferVariables.currencyUsed.balanceOf(address(this))
        );
    }

    function setCexRatio(uint32 _cexRatioX10000) external onlyRole(DEV) {
        require(_cexRatioX10000 < 16000, "RTH");
        require(_cexRatioX10000 > 6000, "RTL");

        variables.cexRatioX10000 = _cexRatioX10000;
        withdraw();
    }

    function setStep(uint256 step) public onlyRole(DEV) {
        variables.step = Step(step);
    }

    function setAllowListMerkleRoot(bytes32 merkleRoot) external onlyRole(DEV) {
        variables.merkleRoot = merkleRoot;
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
        require(
            MerkleProof.verifyCalldata(
                proof,
                variables.merkleRoot,
                keccak256(abi.encodePacked(msg.sender))
            ),
            "NWL"
        );
        _;
    }

    function buy(
        address _to,
        uint256 price,
        bytes32[] calldata proof
    ) external onlyWhitelist(proof) nonReentrant {
        Variables memory bufferVariables = variables;
        uint256 amount = (price * bufferVariables.cexRatioX10000) /
            (10000 * TOKENPRICE);
        uint256 cap = amount + totalSupply();
        //verif ratio
        require(bufferVariables.step != Step(0), "SINA");
        require(bufferVariables.step != Step(2), "SO");
        require(cap <= MAX_SUPPLY, "EMS");
        require(
            tokensBought[msg.sender] + amount <= bufferVariables.MaxToBuy,
            "TABTMT"
        );
        bufferVariables.currencyUsed.transferFrom(
            msg.sender,
            address(this),
            price
        );
        _mint(_to, amount);
        tokensBought[msg.sender] += amount;
        if (cap == MAX_SUPPLY) {
            setStep(2);
        }
        emit Buying(_to, price, amount);
    }
}
