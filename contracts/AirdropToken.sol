// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

/// @title Airdrop ERC-20 Token COntract
/// @notice Contract name can be changed to suit the contract name. Also the Token moniker and name can be changed as needed
contract AirdropToken is ERC20 {
    constructor(uint256 initialSupply) ERC20("AirdropToken", "AIR") {
        _mint(msg.sender, initialSupply);
    }
}