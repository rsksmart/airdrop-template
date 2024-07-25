// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "./Administrable.sol";

struct AirdropInfo {
    string airdropName;
    address airdropAddress;
    uint256 totalAirdropAmount;
    uint256 airdropAmountLeft;
    uint256 claimAmount;
    uint256 expirationDate;
}

interface IAirdrop1155 {
    function claim(address user) external;
    function hasClaimed(address _address) external view returns(bool);
    function hasExpired() external view returns(bool);
    function allowAddress(address _address) external;
    function allowAddresses(address[] memory addresses) external;
    function disallowAddresses(address[] memory addresses) external;
    function disallowAddress(address _address) external;
    function isAllowed(address _address) external view returns(bool);
    function getExpirationDate() external view returns(uint256);
    function getClaimAmount() external view returns(uint256);
    function getTotalAirdropAmount() external view returns(uint256);
    function getAirdropAmountLeft() external view returns(uint256);
    function getBalance() external view returns(uint256);
    function getAirdropInfo() external view returns(AirdropInfo memory info);
    function setRoot(bytes32 _root) external;
    function claimWithProof(uint256 amount_, bytes32[] calldata proof_) external;
}

contract AirdropManager is Administrable {
    address[] _airdrops;

    constructor (address[] memory initialAdmins) Administrable(initialAdmins) {}

    event AirdropAdded(address airdropAddress);
    event AirdropRemoved(address airdropAddress);

    function claim(address airdropAddress, address user) public {
        IAirdrop1155 airdrop = IAirdrop1155(airdropAddress);
        airdrop.claim(user);
    }

    function hasClaimed(address airdropAddress, address user) public view returns(bool) {
        IAirdrop1155 airdrop = IAirdrop1155(airdropAddress);
        return airdrop.hasClaimed(user);
    }

    function hasExpired(address airdropAddress) public view returns(bool) {
        IAirdrop1155 airdrop = IAirdrop1155(airdropAddress);
        return airdrop.hasExpired();
    }

    function isAllowed(address airdropAddress, address user) public view returns(bool) {
        IAirdrop1155 airdrop = IAirdrop1155(airdropAddress);
        return airdrop.isAllowed(user);
    }

    function getExpirationDate(address airdropAddress) public view returns(uint256) {
        IAirdrop1155 airdrop = IAirdrop1155(airdropAddress);
        return airdrop.getExpirationDate();
    }

    function getClaimAmount(address airdropAddress) public view returns(uint256) {
        IAirdrop1155 airdrop = IAirdrop1155(airdropAddress);
        return airdrop.getClaimAmount();
    }

    function getAirdropInfo(address airdropAddress) public view returns(AirdropInfo memory) {
        IAirdrop1155 airdrop = IAirdrop1155(airdropAddress);
        return airdrop.getAirdropInfo();
    }

    function getTotalAirdropAmount(address airdropAddress) public view returns(uint256) {
        IAirdrop1155 airdrop = IAirdrop1155(airdropAddress);
        return airdrop.getTotalAirdropAmount();
    }

    function getAirdropAmountLeft(address airdropAddress) public view returns(uint256) {
        IAirdrop1155 airdrop = IAirdrop1155(airdropAddress);
        return airdrop.getAirdropAmountLeft();
    }

    function getBalance(address airdropAddress) public view returns(uint256) {
        IAirdrop1155 airdrop = IAirdrop1155(airdropAddress);
        return airdrop.getBalance();
    }

    function getAirdrops() public view returns(address[] memory) {
        return _airdrops;
    }

    function addAirdrop(address newAirdropAddress) public onlyAdmins {
        bool exists = false;
        for (uint i = 0; i < _airdrops.length && !exists; i++) {
            exists = _airdrops[i] == newAirdropAddress;
        }

        require(!exists, "Airdrop already added");
        _airdrops.push(newAirdropAddress);
        emit AirdropAdded(newAirdropAddress);
    }

    function removeAirdrop(address airdropAddress) public onlyAdmins {
        bool exists = false;
        for (uint i = 0; i < _airdrops.length && !exists; i++) {
            if (_airdrops[i] == airdropAddress) {
                exists = true;
                _airdrops[i] = _airdrops[_airdrops.length -1];
                _airdrops.pop();
            }
        }

        if (exists) emit AirdropRemoved(airdropAddress);
    }

    function allowAddress(address airdropAddress, address user) public onlyAdmins {
        IAirdrop1155 airdrop = IAirdrop1155(airdropAddress);
        airdrop.allowAddress(user);
    }

    function allowAddresses(address airdropAddress, address[] memory users) public onlyAdmins {
        IAirdrop1155 airdrop = IAirdrop1155(airdropAddress);
        airdrop.allowAddresses(users);
    }

    function disallowAddress(address airdropAddress, address user) public onlyAdmins {
        IAirdrop1155 airdrop = IAirdrop1155(airdropAddress);
        airdrop.disallowAddress(user);
    }

    function disallowAddresses(address airdropAddress, address[] memory users) public onlyAdmins {
        IAirdrop1155 airdrop = IAirdrop1155(airdropAddress);
        airdrop.disallowAddresses(users);
    }
}