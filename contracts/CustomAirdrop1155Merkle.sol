// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/access/Ownable.sol";

interface IERC1155 {
    function safeTransferFrom(address from, address to, uint256 id, uint256 amount, bytes memory data) external;
    function balanceOf(address account, uint256 id) external view returns (uint256);
}

struct AirdropInfo {
    string airdropName;
    address airdropAddress;
    uint256 totalAirdropAmount;
    uint256 airdropAmountLeft;
    uint256 claimAmount;
    uint256 expirationDate;
}

contract CustomAirdrop1155Merkle is Ownable {
    event Claim(address recipient, uint256 amount);
    event AddressAllowed(address allowedAddress);
    event AddressDisallowed(address disallowedAddress);

    IERC1155 _tokenContract;
    address _initialOwner;
    uint256 _totalAirdropAmount;
    uint256 _airdropAmountLeft;
    uint256 _claimAmount;
    uint256 _expirationDate;
    uint256 _tokenId;
    string _airdropName;
    mapping(address => bool) _allowedAddresses;
    mapping(address => bool) _addressesThatAlreadyClaimed;
    bytes32 public merkleRoot;

    constructor(
        string memory airdropName,
        address initialOwner,
        address tokenAddress,
        uint256 tokenId,
        uint256 totalAirdropAmount,
        uint256 claimAmount,
        uint256 expirationDate
    ) Ownable(initialOwner) {
        _tokenContract = IERC1155(tokenAddress);
        _airdropName = airdropName;
        _tokenId = tokenId;
        _totalAirdropAmount = totalAirdropAmount;
        _airdropAmountLeft = totalAirdropAmount;
        _claimAmount = claimAmount;
        _expirationDate = expirationDate;
    }

    function claim(address user) public onlyOwner {
        require(isAllowed(user), "Address not allowed to claim this airdrop");
        require(!hasExpired(), "Airdrop already expired.");
        require(!hasClaimed(user), "Address already claimed this airdrop.");
        require(!hasBeenTotallyClaimed(), "Airdrop has been totally claimed already.");
        require(hasBalanceToClaim(), "Airdrop contract has insufficient token balance.");

        _tokenContract.safeTransferFrom(address(this), user, _tokenId, _claimAmount, '');
        _airdropAmountLeft -= _claimAmount;
        _addressesThatAlreadyClaimed[user] = true;

        emit Claim(user, _claimAmount);
    }

    function claimProof(uint256 amount, bytes32[] calldata proof) public onlyOwner {
        require(!hasExpired(), "Airdrop already expired.");
        require(!hasClaimed(msg.sender), "Address already claimed this airdrop.");
        require(!hasBeenTotallyClaimed(), "Airdrop has been totally claimed already.");
        require(hasBalanceToClaim(), "Airdrop contract has insufficient token balance.");
        require(verify(proof, msg.sender, amount), "Invalid proof.");

        _tokenContract.safeTransferFrom(address(this), msg.sender, _tokenId, _claimAmount, '');
        _airdropAmountLeft -= _claimAmount;
        _addressesThatAlreadyClaimed[msg.sender] = true;

        emit Claim(msg.sender, _claimAmount);
    }

    function verify(bytes32[] calldata proof, address account, uint256 amount) internal view returns (bool) {
        bytes32 node = keccak256(abi.encodePacked(account, amount));
        bytes32 computedHash = node;

        for (uint256 i = 0; i < proof.length; i++) {
            bytes32 proofElement = proof[i];

            if (computedHash <= proofElement) {
                computedHash = keccak256(abi.encodePacked(computedHash, proofElement));
            } else {
                computedHash = keccak256(abi.encodePacked(proofElement, computedHash));
            }
        }

        return computedHash == merkleRoot;
    }

    function setMerkleRoot(bytes32 _merkleRoot) external onlyOwner {
        merkleRoot = _merkleRoot;
    }

    function getAirdropInfo() public view returns(AirdropInfo memory) {
        return AirdropInfo(_airdropName, address(this), _totalAirdropAmount, _airdropAmountLeft, _claimAmount, _expirationDate);
    }

    function hasBalanceToClaim() public view returns(bool) {
        return _tokenContract.balanceOf(address(this), _tokenId) >= _claimAmount;
    }

    function hasBeenTotallyClaimed() public view returns(bool) {
        return _airdropAmountLeft < _claimAmount;
    }

    function hasClaimed(address _address) public view returns(bool) {
        return _addressesThatAlreadyClaimed[_address];
    }

    function hasExpired() public view returns(bool) {
        return _expirationDate < block.timestamp;
    }

    function allowAddress(address _address) public onlyOwner {
        _allowedAddresses[_address] = true;
        emit AddressAllowed(_address);
    }

    function allowAddresses(address[] memory addresses) public onlyOwner {
        for (uint i; i < addresses.length; i++) {
            _allowedAddresses[addresses[i]] = true;
            emit AddressAllowed(addresses[i]);
        }
    }

    function disallowAddresses(address[] memory addresses) public onlyOwner {
        for (uint i; i < addresses.length; i++) {
            _allowedAddresses[addresses[i]] = false;
            emit AddressDisallowed(addresses[i]);
        }
    }

    function disallowAddress(address _address) public onlyOwner {
        _allowedAddresses[_address] = false;
        emit AddressDisallowed(_address);
    }

    function isAllowed(address _address) public view returns(bool) {
        return _allowedAddresses[_address];
    }

    function getExpirationDate() public view returns(uint256) {
        return _expirationDate;
    }

    function getClaimAmount() public view returns(uint256) {
        return _claimAmount;
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