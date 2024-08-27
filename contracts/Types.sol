// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

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

interface IAirdrop {
    function claim(address user, uint256 amount_, bytes32[] calldata proof_) external;
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
}

interface IERC20 {
    function transfer(address to, uint256 amount) external;
    function balanceOf(address account) external view returns (uint256);
}

interface IERC1155 {
    function safeTransferFrom(address from, address to, uint256 id, uint256 amount, bytes memory data) external;
    function balanceOf(address account, uint256 id) external view returns (uint256);
}
