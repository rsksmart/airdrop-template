// This setup uses Hardhat Ignition to manage smart contract deployments.
// Learn more about it at https://hardhat.org/ignition

import { buildModule } from '@nomicfoundation/hardhat-ignition/modules'

const ERC1155Module = buildModule(
  'ERC1155Module',
  (m) => {
    const erc1155 = m.contract('MyToken', [])
    return { erc1155 }
  }
)

export default ERC1155Module