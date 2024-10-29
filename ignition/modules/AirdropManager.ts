// This setup uses Hardhat Ignition to manage smart contract deployments.
// Learn more about it at https://hardhat.org/ignition

import { buildModule } from '@nomicfoundation/hardhat-ignition/modules'

const AirdropDeployerERC20Module = buildModule(
  'AirdropDeployerERC20Module',
  (m) => {
    const airdropDeployerERC20 = m.contract('AirdropDeployerERC20', [])
    return { airdropDeployerERC20 }
  }
)
const AirdropDeployerERC1155Module = buildModule(
  'AirdropDeployerERC1155Module',
  (m) => {
    const airdropDeployerERC1155 = m.contract('AirdropDeployerERC1155', [])
    return { airdropDeployerERC1155 }
  }
)

const AirdropManagerModule = buildModule('AirdropManagerModule', (m) => {
  const { airdropDeployerERC20 } = m.useModule(AirdropDeployerERC20Module)
  const { airdropDeployerERC1155 } = m.useModule(AirdropDeployerERC1155Module)
  const initialValues = ['0x6927ABD63Da2Da250E6676c64cF14586E1E1fA10']
  const initialAdmins = m.getParameter('initialAdmins', initialValues)

  const airdropManager = m.contract('AirdropManager', [
    initialAdmins,
    airdropDeployerERC20,
    airdropDeployerERC1155,
  ])
  return { airdropManager }
})

export default AirdropManagerModule
