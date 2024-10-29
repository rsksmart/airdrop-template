import { HardhatUserConfig } from 'hardhat/config'
import '@nomicfoundation/hardhat-toolbox'
import "dotenv/config";

const RSK_MAINNET_RPC_URL = process.env.RSK_MAINNET_RPC_URL
const RSK_TESTNET_RPC_URL = process.env.RSK_TESTNET_RPC_URL
const PRIVATE_KEY = process.env.PRIVATE_KEY
console.log('RSK_MAINNET_RPC_URL:', process.env.RSK_MAINNET_RPC_URL)
console.log('RSK_MAINNET_RPC_URL:', RSK_MAINNET_RPC_URL)
// Ensure environment variables are configured
if (!RSK_MAINNET_RPC_URL) {
  throw new Error('The RPC URL for the mainnet is not configured.')
}

if (!RSK_TESTNET_RPC_URL) {
  // Fixed duplicate check for RSK_MAINNET_RPC_URL
  throw new Error('The RPC URL for the testnet is not configured.')
}

if (!PRIVATE_KEY) {
  throw new Error('Private key is not configured.')
}

const config: HardhatUserConfig = {
  solidity: '0.8.24',
  networks: {
    hardhat: {
      // If you want to do some forking, uncomment this
      // forking: {
      //   url: MAINNET_RPC_URL
      // }
    },
    localhost: {
      url: 'http://127.0.0.1:8545',
    },
    rskMainnet: {
      url: RSK_MAINNET_RPC_URL,
      chainId: 30,
      gasPrice: 60000000,
      gas: 80000000,
      accounts: [PRIVATE_KEY],
    },
    rskTestnet: {
      url: RSK_TESTNET_RPC_URL,
      chainId: 31,
      gasPrice: 60000000,
      gas: 80000000,
      accounts: [PRIVATE_KEY],
    },
  },
  etherscan: {
    apiKey: {
      // Is not required by blockscout. Can be any non-empty string
      rsktestnet: 'your API key',
      rskmainnet: 'your API key',
    },
    customChains: [
      {
        network: 'rsktestnet',
        chainId: 31,
        urls: {
          apiURL: 'https://rootstock-testnet.blockscout.com/api/',
          browserURL: 'https://rootstock-testnet.blockscout.com/',
        },
      },
      {
        network: 'rskmainnet',
        chainId: 30,
        urls: {
          apiURL: 'https://rootstock.blockscout.com/api/',
          browserURL: 'https://rootstock.blockscout.com/',
        },
      },
    ],
  }
}

export default config
