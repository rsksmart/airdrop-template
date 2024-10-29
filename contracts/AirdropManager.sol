// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "./Lib/Administrable.sol";
import "./Tools/Types.sol";

contract AirdropManager is Administrable {
    address _airdropDeployerERC20Address;
    address _airdropDeployerERC1155Address;
    address[] _airdrops;

    event AirdropAdded(address airdropAddress);
    event AirdropRemoved(address airdropAddress);
    event AirdropERC20Deployed(address airdropAddress);
    event AirdropERC1155Deployed(address airdropAddress);

    constructor(
        address[] memory initialAdmins,
        address airdropDeployerERC20Address,
        address airdropDeployerERC1155Address
    ) Administrable(initialAdmins) {
        _airdropDeployerERC20Address = airdropDeployerERC20Address;
        _airdropDeployerERC1155Address = airdropDeployerERC1155Address;
    }

    function claim(
        address airdropAddress,
        address user,
        uint256 amount,
        bytes32[] calldata proof
    ) public {
        IAirdrop airdrop = IAirdrop(airdropAddress);
        airdrop.claim(user, amount, proof);
    }

    function hasClaimed(
        address airdropAddress,
        address user
    ) public view returns (bool) {
        IAirdrop airdrop = IAirdrop(airdropAddress);
        return airdrop.hasClaimed(user);
    }

    function hasExpired(address airdropAddress) public view returns (bool) {
        IAirdrop airdrop = IAirdrop(airdropAddress);
        return airdrop.hasExpired();
    }

    function isAllowed(
        address airdropAddress,
        address user
    ) public view returns (bool) {
        IAirdrop airdrop = IAirdrop(airdropAddress);
        return airdrop.isAllowed(user);
    }

    function getExpirationDate(
        address airdropAddress
    ) public view returns (uint256) {
        IAirdrop airdrop = IAirdrop(airdropAddress);
        return airdrop.getExpirationDate();
    }

    function getClaimAmount(
        address airdropAddress
    ) public view returns (uint256) {
        IAirdrop airdrop = IAirdrop(airdropAddress);
        return airdrop.getClaimAmount();
    }

    function getAirdropInfo(
        address airdropAddress
    ) public view returns (AirdropInfo memory) {
        IAirdrop airdrop = IAirdrop(airdropAddress);
        return airdrop.getAirdropInfo();
    }

    function getTotalAirdropAmount(
        address airdropAddress
    ) public view returns (uint256) {
        IAirdrop airdrop = IAirdrop(airdropAddress);
        return airdrop.getTotalAirdropAmount();
    }

    function getAirdropAmountLeft(
        address airdropAddress
    ) public view returns (uint256) {
        IAirdrop airdrop = IAirdrop(airdropAddress);
        return airdrop.getAirdropAmountLeft();
    }

    function getBalance(address airdropAddress) public view returns (uint256) {
        IAirdrop airdrop = IAirdrop(airdropAddress);
        return airdrop.getBalance();
    }

    function getAirdrops() public view returns (address[] memory) {
        return _airdrops;
    }

    function deployAndAddAirdropERC20(
        string memory airdropName,
        address tokenAddress,
        uint256 totalAirdropAmount,
        uint256 claimAmount,
        uint256 expirationDate
    ) public returns(address) {
        IDeployerERC20 deployerERC20 = IDeployerERC20(_airdropDeployerERC20Address);
        address deployedAddress = deployerERC20.deployAndAddAirdrop(
            airdropName,
            tokenAddress,
            totalAirdropAmount,
            claimAmount,
            expirationDate
        );
        addAirdrop(deployedAddress);
        emit AirdropERC20Deployed(deployedAddress);
        return deployedAddress;
    }

    function deployAndAddAirdropERC1155(
        string memory airdropName,
        address tokenAddress,
        uint256 tokenId,
        uint256 totalAirdropAmount,
        uint256 claimAmount,
        uint256 expirationDate,
        uint256 mode
    ) public returns(address) {
        IDeployer1155 deployer1155 = IDeployer1155(_airdropDeployerERC1155Address);
        address deployedAddress = deployer1155.deployAndAddAirdrop(
            airdropName,
            tokenAddress,
            tokenId,
            totalAirdropAmount,
            claimAmount,
            expirationDate,
            mode
        );
        require(deployedAddress != address(0), "Error, wrong mode selected");
        addAirdrop(deployedAddress);
        emit AirdropERC1155Deployed(deployedAddress);
        return deployedAddress;
    }

    function addAirdrop(address newAirdropAddress) internal {
        bool exists = false;
        for (uint i = 0; i < _airdrops.length && !exists; i++) {
            exists = _airdrops[i] == newAirdropAddress;
        }
        require(!exists, "Airdrop already added");
        _airdrops.push(newAirdropAddress);
        emit AirdropAdded(newAirdropAddress);
    }

    function setRoot(address airdropAddress, bytes32 _root) public onlyAdmins {
        IAirdrop airdrop = IAirdrop(airdropAddress);
        airdrop.setRoot(_root);
    }

    function removeAirdrop(address airdropAddress) public onlyAdmins {
        bool exists = false;
        for (uint i = 0; i < _airdrops.length && !exists; i++) {
            if (_airdrops[i] == airdropAddress) {
                exists = true;
                _airdrops[i] = _airdrops[_airdrops.length - 1];
                _airdrops.pop();
            }
        }

        if (exists) emit AirdropRemoved(airdropAddress);
    }

    function allowAddress(
        address airdropAddress,
        address user
    ) public onlyAdmins {
        IAirdrop airdrop = IAirdrop(airdropAddress);
        airdrop.allowAddress(user);
    }

    function allowAddresses(
        address airdropAddress,
        address[] memory users
    ) public onlyAdmins {
        IAirdrop airdrop = IAirdrop(airdropAddress);
        airdrop.allowAddresses(users);
    }

    function disallowAddress(
        address airdropAddress,
        address user
    ) public onlyAdmins {
        IAirdrop airdrop = IAirdrop(airdropAddress);
        airdrop.disallowAddress(user);
    }

    function disallowAddresses(
        address airdropAddress,
        address[] memory users
    ) public onlyAdmins {
        IAirdrop airdrop = IAirdrop(airdropAddress);
        airdrop.disallowAddresses(users);
    }
}
