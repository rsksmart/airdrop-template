// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/access/Ownable.sol";
import { MerkleProof } from "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";

interface IERC1155 {
    function safeTransferFrom(address from, address to, uint256 id, uint256 amount, bytes memory data) external;
    function balanceOf(address account, uint256 id) external view returns (uint256);
}

enum AirdropType {
    CUSTOM,
    MERKLE
}

struct AirdropInfo {
    string airdropName;
    address airdropAddress;
    uint256 totalAirdropAmount;
    uint256 airdropAmountLeft;
    uint256 claimAmount;
    uint256 expirationDate;
    AirdropType airdropType;
}

contract CustomAirdrop1155Merkle is Ownable {
    event Claim(address recipient, uint256 amount);

    IERC1155 _tokenContract;
    uint256 _totalAirdropAmount;
    uint256 _airdropAmountLeft;
    uint256 _claimAmount;
    uint256 _expirationDate;
    uint256 _tokenId;
    string _airdropName;
    AirdropType _airdropType;

    // (account,amount) Merkle Tree root
    bytes32 public root;
    error InvalidProof();
    error UsedLeaf();

    mapping(address => bool) _addressesThatAlreadyClaimed;
    mapping(bytes32 => bool) public claimedLeaf;

    constructor(
        string memory airdropName,
        address initialOwner,
        address tokenAddress,
        uint256 tokenId,
        uint256 totalAirdropAmount,
        uint256 expirationDate,
        AirdropType airdropType
    ) Ownable(initialOwner) {
        _tokenContract = IERC1155(tokenAddress);
        _airdropName = airdropName;
        _tokenId = tokenId;
        _totalAirdropAmount = totalAirdropAmount;
        _airdropAmountLeft = totalAirdropAmount;
        _expirationDate = expirationDate;
        _airdropType = airdropType;
    }

    function setRoot(bytes32 _root) public onlyOwner {
        root = _root;
    }

    function claim(address user, uint256 amount, bytes32[] calldata proof) external onlyOwner{
        _claim(user, amount, proof);
    }

    function _claim(address origin_, uint256 amount_, bytes32[] calldata proof_) internal {
        bytes32 leaf = _buildLeaf(origin_, amount_);

        if (!MerkleProof.verifyCalldata(proof_, root, leaf)) revert InvalidProof();
        if (claimedLeaf[leaf]) revert UsedLeaf();
        claimedLeaf[leaf] = true;
        require(!hasExpired(), "Airdrop already expired.");
        require(!hasBeenTotallyClaimed(), "Airdrop has been totally claimed already.");

        _tokenContract.safeTransferFrom(address(this), origin_, _tokenId, amount_, '');
        _airdropAmountLeft -= amount_;
        _addressesThatAlreadyClaimed[origin_] = true;

        emit Claim(origin_, amount_);
    }

    function _buildLeaf(address origin_, uint256 amount_) internal pure returns (bytes32) {
        return keccak256(bytes.concat(keccak256(abi.encode(origin_, amount_))));
    }

    function getAirdropInfo() public view returns(AirdropInfo memory) {
        return AirdropInfo(_airdropName, address(this), _totalAirdropAmount, _airdropAmountLeft, 0, _expirationDate, _airdropType);
    }

    function hasBeenTotallyClaimed() public view returns(bool) {
        return _airdropAmountLeft < 1;
    }

    function hasClaimed(address _address) public view returns(bool) {
        return _addressesThatAlreadyClaimed[_address];
    }

    function hasExpired() public view returns(bool) {
        return _expirationDate < block.timestamp;
    }

    function getExpirationDate() public view returns(uint256) {
        return _expirationDate;
    }

    function getTotalAirdropAmount() public view returns(uint256) {
        return _totalAirdropAmount;
    }

    function getAirdropAmountLeft() public view returns(uint256) {
        return _airdropAmountLeft;
    }

    function getBalance() public view returns(uint256) {
        return _tokenContract.balanceOf(address(this), _tokenId);
    }

    function onERC1155Received(address operator, address from, uint256 id, uint256 value, bytes memory data) external pure returns (bytes4) {
        return bytes4(keccak256("onERC1155Received(address,address,uint256,uint256,bytes)"));
    }
}