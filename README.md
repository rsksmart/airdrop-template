<img src="rootstock-logo.png" alt="RSK Logo" style="width:100%; height: auto;" />

# ERC1155 Airdrop Smart Contracts Template
This project is an open-source template for creating an ERC1155 airdrop smart contract on the RSK network. The template is designed to be easy to use and customize, and it includes a simple example of how to create an airdrop campaign and distribute tokens to multiple recipients.

## Deployment
The smart contracts in this template can be deployed to the RSK network using the next command:
```bash
npx hardhat ignition deploy ignition/modules/AirdropManager.ts --network rskTestnet
```

It will deploy the `AirdropManager`, `AirdropDeployerERC20Module` & `AirdropDeployerERC1155Module` contracts and its dependencies to the RSK Testnet network. You should see a response like:
```bash
Hardhat Ignition 🚀

Deploying [ AirdropManagerModule ]

Batch #1
  Executed AirdropDeployerERC1155Module#AirdropDeployerERC1155
  Executed AirdropDeployerERC20Module#AirdropDeployerERC20

Batch #2
  Executed AirdropManagerModule#AirdropManager

[ AirdropManagerModule ] successfully deployed 🚀

Deployed Addresses

AirdropDeployerERC1155Module#AirdropDeployerERC1155 - 0x6465331bBf430f53504cb94BF2d2AF32E5740F68
AirdropDeployerERC20Module#AirdropDeployerERC20 - 0xda0c531F4dAFED4E6bc6EfBe2D281C49BA5eE049
AirdropManagerModule#AirdropManager - 0x19Fa15E7084D802335cfC1B7d5AC22a6b80Bf6Ef
```
> Also, you can see the deployed contracts in the `ignition/deployments/chain-31/deployed_addresses` folder.

## Verify Contracts
To verify the contracts on the RSK network, you can use the next command:
1. AirdropDeployerERC1155
```bash
npx hardhat verify --network rskTestnet 0x49dbbA265c0f4a7Ca8C277F57E189f6B90998aEE
```
***Note: Replace the address `0x49dbbA265c0f4a7Ca8C277F57E189f6B90998aEE` with the address of the contract you want to verify.***

2. AirdropDeployerERC20
```bash
npx hardhat verify --network rskTestnet 0xe68B923822E0b9067413be380dBED46f295F2372
```
***Note: Replace the address `0xe68B923822E0b9067413be380dBED46f295F2372` with the address of the contract you want to verify.***

3. AirdropManager, for this contract verification, you need to pass the constructor arguments in the file `AirdropManagerArguments.js`, so make sure you replace them with your own args:
```bash
npx hardhat verify --constructor-args AirdropManagerArguments.js --network rskTestnet 0xFdEdc1427b745D9876B5BBF21e2F57922CF78117
```
You should see a response like this in each verification:
```bash
Successfully verified contract AirdropDeployerERC20 on the block explorer.
https://rootstock-testnet.blockscout.com/address/0xe68B923822E0b9067413be380dBED46f295F2372#code
```

## Deploy ERC1155
We have included an ERC1155 contract in the `contracts/ERC1155/Erc1155.sol` file. You can modify it as needed and deploy it to the RSK network.

To deploy your ERC1155 contract, you can use the next command:
```bash
npx hardhat ignition deploy ignition/modules/ERC1155.ts --network rskTestnet
```
And then you can use the next command to verify the contract:
```bash
npx hardhat verify --network rskTestnet 0xe68B923822E0b9067413be380dBED46f295F2372
```
## Smart Contracts Reference

### 1. **Administrable.sol**

The `Administrable.sol` contract provides the foundation for managing administrator roles within the system.

- **License and Version**: SPDX License Identifier: MIT, Solidity Compiler Version: 0.8.19.
- **Contract Declaration**: Defines the `Administrable` contract.
- **Mapping**: Tracks admin addresses with a `mapping(address => bool) _admins`.
- **Constructor**: Initializes the contract by adding initial admins from an array.
- **Modifier**: `onlyAdmins` restricts functions to admins.
- **Functions**:
  - `isAdmin`: Checks if an address is an admin.
  - `addAdmin`: Adds a new admin.
  - `removeAdmin`: Removes an existing admin.

### 2. **AirdropManager.sol**

`AirdropManager.sol` is responsible for managing different types of airdrops and facilitating the claiming process.

- **Imports**: The `Administrable` contract is imported.
- **Enum**: `AirdropType` defines two types of airdrops: CUSTOM and MERKLE.
- **Struct**: `AirdropInfo` stores essential information about each airdrop.
- **Interface**: `IAirdrop1155` defines required functions for ERC-1155 airdrop contracts.
- **Inheritance**: `AirdropManager` inherits from `Administrable`, allowing admin management.
- **Functions**:
  - `claim`: Allows users to claim airdrop tokens.
  - `hasClaimed`, `hasExpired`, `isAllowed`, `getExpirationDate`, `getClaimAmount`, `getAirdropInfo`, `getTotalAirdropAmount`: Provide data related to the airdrop.

### 3. **CustomAirdrop1155.sol**

This contract implements logic for distributing tokens using the ERC-1155 standard, supporting multi-token airdrops.

- **Imports**: Utilizes the `Ownable` contract from OpenZeppelin for ownership management.
- **Interface**: The `IERC1155` interface defines essential token transfer functions.
- **Functions**:
  - `claim`: Allows the owner to facilitate claims.
  - `allowAddress`, `disallowAddress`: Manage which addresses can claim tokens.
  - `hasClaimed`, `hasExpired`, `getAirdropInfo`: Retrieve data without modifying the contract state.

### 4. **CustomAirdrop1155ClaimMerkle.sol**

Extends the functionality of `CustomAirdrop1155.sol` by incorporating Merkle Tree validation for claims.

- **Imports**: Includes the `MerkleProof` library for efficient address verification.
- **Functions**:
  - `claim`: Allows users to claim tokens using Merkle Proofs.
  - `setRoot`: Allows the owner to set the Merkle root for the airdrop.
  - `_claim`: Internal function to handle the logic for verifying Merkle Proofs and facilitating claims.

### 5. **Erc1155.sol**

Implements the ERC-1155 standard for managing multiple token types and enabling transfers of various tokens.

- **Imports**: Leverages OpenZeppelin's `ERC1155` and `Ownable` contracts.
- **Functions**:
  - `mint`: Allows the owner to mint tokens.
  - `mintBatch`: Facilitates minting multiple token types in a single transaction.


```deployed address : 0xB12261Ce8A7088a63C7A62ffdd568d8Fd50bee1D```



# Disclaimer
The software provided in this GitHub repository is offered “as is,” without warranty of any kind, express or implied, including but not limited to the warranties of merchantability, fitness for a particular purpose, and non-infringement.
- **Testing:** The software has not undergone testing of any kind, and its functionality, accuracy, reliability, and suitability for any purpose are not guaranteed.
- **Use at Your Own Risk:** The user assumes all risks associated with the use of this software. The author(s) of this software shall not be held liable for any damages, including but not limited to direct, indirect, incidental, special, consequential, or punitive damages arising out of the use of or inability to use this software, even if advised of the possibility of such damages.
- **No Liability:** The author(s) of this software are not liable for any loss or damage, including without limitation, any loss of profits, business interruption, loss of information or data, or other pecuniary loss arising out of the use of or inability to use this software.
- **Sole Responsibility:** The user acknowledges that they are solely responsible for the outcome of the use of this software, including any decisions made or actions taken based on the software’s output or functionality.
- **No Endorsement:** Mention of any specific product, service, or organization does not constitute or imply endorsement by the author(s) of this software.
- **Modification and Distribution:** This software may be modified and distributed under the terms of the license provided with the software. By modifying or distributing this software, you agree to be bound by the terms of the license.
- **Assumption of Risk:** By using this software, the user acknowledges and agrees that they have read, understood, and accepted the terms of this disclaimer and assumes all risks associated with the use of this software.