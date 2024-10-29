// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "../ERC20/OpenAirdropERC20.sol";
import "../Tools/Types.sol";

contract AirdropDeployerERC20{
    constructor() {}
    function deployAndAddAirdrop(
        string memory airdropName,
        address tokenAddress,
        uint256 totalAirdropAmount,
        uint256 claimAmount,
        uint256 expirationDate
    ) public returns (address) {
        OpenAirdropERC20 deployedAirdrop = new OpenAirdropERC20(
            airdropName,
            msg.sender,
            tokenAddress,
            totalAirdropAmount,
            claimAmount,
            expirationDate
        );
        address airdropAddress = address(deployedAirdrop);
        return airdropAddress;
    }
}
