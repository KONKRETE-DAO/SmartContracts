//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.10;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/draft-ERC20Permit.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";

contract PropertyToken is ERC20Permit, Ownable {
  event Buying(address buyer, uint256 amount);

  mapping(address => uint256) public tokensBought;

  uint256 constant tokenPrice = 10;
  uint256 public immutable MAX_SUPPLY;
  uint256 public immutable MAX_TO_BUY;
  address public immutable multisig;
  IERC20 public immutable currencyUsed;

  enum Step {
    Deployed,
    Sale,
    Soldout
  }

  struct Variables {
    Step step;
    uint32 cexRatioX10000;
    bytes32 merkleRoot;
  }

  Variables public variables;

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

  function withdraw() public onlyOwner {
    uint256 balance = currencyUsed.balanceOf(address(this));
    currencyUsed.transfer(multisig, balance);
  }

  function setCexRatio(uint32 _cexRatioX10000) external onlyOwner {
    require(_cexRatioX10000 < 16000, "1.6 euro for one dollar ?? ");
    require(_cexRatioX10000 > 6000, "0.6 euro for one dollar ?? ");
    variables.cexRatioX10000 = _cexRatioX10000;
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
    IERC20 doll = currencyUsed;
    uint256 amount = (price * bufferVariables.cexRatioX10000) /
      (10000 * tokenPrice);

    require(amount + totalSupply() <= MAX_SUPPLY, "Maximum supply exceeded");
    require(
      tokensBought[msg.sender] + amount <= MAX_TO_BUY,
      "This Address bought too much tokens"
    );
    doll.transferFrom(msg.sender, address(this), price);
    _mint(_to, amount);
    tokensBought[msg.sender] += amount;
    emit Buying(_to, amount);
  }
}
