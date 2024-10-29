// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "../ERC1155/CustomAirdrop1155.sol";
import "../ERC1155/CustomAirdrop1155Merkle.sol";
import "../Tools/Types.sol";

contract AirdropDeployerERC1155 {
    constructor() {}
    function deployAndAddAirdrop(
        string memory airdropName,
        address tokenAddress,
        uint256 tokenId,
        uint256 totalAirdropAmount,
        uint256 claimAmount,
        uint256 expirationDate,
        uint256 mode
    ) public returns (address) {
        if (mode == 0) {
            CustomAirdrop1155 deployedAirdrop = new CustomAirdrop1155(
                airdropName,
                address(this),
                tokenAddress,
                tokenId,
                totalAirdropAmount,
                claimAmount,
                expirationDate,
                AirdropType.CUSTOM
            );
            address airdropAddress = address(deployedAirdrop);
            return airdropAddress;
        } else if (mode == 1) {
            CustomAirdrop1155Merkle deployedAirdrop = new CustomAirdrop1155Merkle(
                    airdropName,
                    address(this),
                    tokenAddress,
                    tokenId,
                    totalAirdropAmount,
                    expirationDate,
                    AirdropType.MERKLE
                );
            address airdropAddress = address(deployedAirdrop);
            return airdropAddress;
        } else {
            return address(0);
        }
    }
}
