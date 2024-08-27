// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/access/Ownable.sol";
import "./Types.sol";

contract OpenAirdropERC20 is Ownable {
    event Claim(address recipient, uint256 amount);
    event AddressAllowed(address allowedAddress);
    event AddressDisallowed(address disallowedAddress);

    IERC20 _tokenContract;
    uint256 _totalAirdropAmount;
    uint256 _airdropAmountLeft;
    uint256 _claimAmount;
    uint256 _expirationDate;
    string _airdropName;
    AirdropType _airdropType;

    mapping(address => bool) _allowedAddresses;
    mapping(address => bool) _addressesThatAlreadyClaimed;

    constructor(
        string memory airdropName,
        address initialOwner,
        address tokenAddress,
        uint256 totalAirdropAmount,
        uint256 claimAmount,
        uint256 expirationDate
    ) Ownable(initialOwner) {
        _tokenContract = IERC20(tokenAddress);
        _airdropName = airdropName;
        _totalAirdropAmount = totalAirdropAmount;
        _airdropAmountLeft = totalAirdropAmount;
        _claimAmount = claimAmount;
        _expirationDate = expirationDate;
        _airdropType = AirdropType.CUSTOM;
    }

    function claim(address user, uint256 amount, bytes32[] calldata proof) public onlyOwner {
        require(!hasExpired(), "Airdrop already expired.");
        require(!hasClaimed(user), "Address already claimed this airdrop.");
        require(!hasBeenTotallyClaimed(), "Airdrop has been totally claimed already.");
        require(hasBalanceToClaim(), "Airdrop contract has insufficient token balance.");

        _tokenContract.transfer(user, _claimAmount);
        _airdropAmountLeft -= _claimAmount;
        _addressesThatAlreadyClaimed[user] = true;

        emit Claim(user, _claimAmount);
    }
    
    function isAllowed(address user) public pure returns(bool) {
        return true;
    }

    function getAirdropInfo() public view returns(AirdropInfo memory) {
        return AirdropInfo(_airdropName, address(this), _totalAirdropAmount, _airdropAmountLeft, _claimAmount, _expirationDate, _airdropType);
    }

    function hasBalanceToClaim() public view returns(bool) {
        return _tokenContract.balanceOf(address(this)) >= _claimAmount;
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
        return _tokenContract.balanceOf(address(this));
    }
}