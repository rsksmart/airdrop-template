// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

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
}

struct Airdrop {
    address airdropAddress;
    string airdropTokenName;
}

contract AirdropManager {
    address[] _owners;
    address[] _airdrops;

    constructor (address[] memory initialAdmins) {
        _owners = initialAdmins;
    }

    modifier onlyAdmins {
        bool allowed = false;
        for (uint i; i < _owners.length && !allowed; i++) {
            allowed = _owners[i] == msg.sender;
        }

        require(allowed, "Address not allowed to call this method");
        _;
    }

    function claim(address airdropAddress, address user) public onlyAdmins {
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

    function getAirdrops() public view onlyAdmins returns(address[] memory) {
        return _airdrops;
    }

    function addAirdrop(address airdropAddress) public onlyAdmins {
        _airdrops.push(airdropAddress);
    }

    function removeAirdrop(address airdropAddress) public onlyAdmins {
        address[] storage filteredAirdrops = _airdrops;

        for (uint i; i < _airdrops.length; i++) {
            if (_airdrops[i] != airdropAddress) filteredAirdrops.push(_airdrops[i]);
        }

        _airdrops = filteredAirdrops;
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