// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/access/Ownable.sol";

interface IERC1155 {
    function safeTransferFrom(address from, address to, uint256 id, uint256 amount, bytes memory data) external;
    function balanceOf(address account, uint256 id) external view returns (uint256);
}

contract CustomAirdrop1155 is Ownable {
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
    mapping(address => bool) _allowedAddresses;
    mapping(address => bool) _addressesThatAlreadyClaimed;

    constructor(
        address initialOwner,
        address tokenAddress,
        uint256 tokenId,
        uint256 totalAirdropAmount,
        uint256 claimAmount,
        uint256 expirationDate
    ) Ownable(initialOwner) {
        _tokenContract = IERC1155(tokenAddress);
        _tokenId = tokenId;
        _totalAirdropAmount = totalAirdropAmount;
        _airdropAmountLeft = totalAirdropAmount;
        _claimAmount = claimAmount;
        _expirationDate = expirationDate;
    }

    function claim(address user) public {
        require(isAllowed(user), "Address not allowed to claim this airdrop");
        require(_expirationDate >= block.timestamp, "Airdrop already expired.");
        require(!_addressesThatAlreadyClaimed[user], "Address already claimed this airdrop.");
        require(_airdropAmountLeft <= _claimAmount, "Airdrop has been totally claimed already.");
        require(_claimAmount <= _tokenContract.balanceOf(address(this), _tokenId), "Airdrop contract has insufficient token balance.");

        _tokenContract.safeTransferFrom(address(this), user, _tokenId, _claimAmount, '');
        _airdropAmountLeft -= _claimAmount;
        _addressesThatAlreadyClaimed[user] = true;

        emit Claim(user, _claimAmount);
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