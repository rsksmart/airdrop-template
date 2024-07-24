import "@nomiclabs/hardhat-solhint";
import "@nomicfoundation/hardhat-toolbox";
import "@nomicfoundation/hardhat-ethers";
import "@openzeppelin/hardhat-upgrades";
import "@typechain/hardhat";
import { resolve } from "path";
import { config as dotenvConfig } from "dotenv";
import "hardhat-contract-sizer";
import "hardhat-deploy";
import "hardhat-docgen";
import "hardhat-gas-reporter";
import { removeConsoleLog } from "hardhat-preprocessor";
import { HardhatUserConfig } from "hardhat/config";
import { NetworkUserConfig } from "hardhat/types";
import "solidity-coverage";
import "hardhat-storage-layout";
import "hardhat-erc1820";
import "hardhat-storage-layout-diff";
import { DeployParameters } from "./scripts/types";

dotenvConfig({ path: resolve(__dirname, "./.env") });

declare module "hardhat/types/config" {
  export interface HardhatNetworkUserConfig {
    deployParameters: DeployParameters;
  }
  export interface HardhatNetworkConfig {
    deployParameters: DeployParameters;
  }
  export interface HttpNetworkConfig {
    deployParameters: DeployParameters;
  }
}

const chainIds = {
  ganache: 1337,
  goerli: 5,
  hardhat: 31337,
  kovan: 42,
  mainnet: 1,
  rinkeby: 4,
  ropsten: 3,
  rskTestnet: 31,
};

// Ensure that we have all the environment variables we need.
let mnemonic: string;
if (!process.env.MNEMONIC) {
  throw new Error("Please set your MNEMONIC in a .env file");
} else {
  mnemonic = process.env.MNEMONIC;
}

let infuraApiKey: string;
if (!process.env.INFURA_API_KEY) {
  throw new Error("Please set your INFURA_API_KEY in a .env file");
} else {
  infuraApiKey = process.env.INFURA_API_KEY;
}

const createTestnetConfig = (network: keyof typeof chainIds): NetworkUserConfig => {
  const url: string = "https://" + network + ".infura.io/v3/" + infuraApiKey;
  return {
    accounts: {
      count: 10,
      initialIndex: 0,
      mnemonic,
      path: "m/44'/60'/0'/0",
    },
    chainId: chainIds[network],
    url,
  };
};

const config: HardhatUserConfig = {
  defaultNetwork: "hardhat",
  namedAccounts: {
    deployer: 0,
    otherUser: 1,
    alice: 2,
    bob: 3,
    charly: 4,
    david: 5,
    nonUser: 10,
  },
  networks: {
    hardhat: {
      accounts: {
        mnemonic,
        accountsBalance: "100000000000000000000000000000000000",
      },
      chainId: chainIds.hardhat,
      gasPrice: 0,
      initialBaseFeePerGas: 0,
      hardfork: "london", // FIXME: latest evm version supported by rsk explorers, keep it updated
      deployParameters: {
        gasLimit: 30000000, // high value to avoid coverage issue. https://github.com/NomicFoundation/hardhat/issues/3121
        airdropGovernance: {
          // Not necessary because in local deployments we calculate this on the fly, otherwise it should be a 32 bytes string written like "0x..
          rootNode: undefined,
          tokenAddress: undefined, // A mock token will be deployed
        },
        airdropVesting: {
          // Not necessary because in local deployments we calculate this on the fly, otherwise it should be a 32 bytes string written like "0x..
          rootNode: undefined,
          tokenAddress: undefined, // A mock token will be deployed
          claimPermit: {
            domain: { name: "EIP712Example", version: "1" },
            authMsg: "I authorize claim to",
            recipientMsg: "I authorize claim to be receive on",
          },
          registry: undefined, // A mock registry will be deployed
          percentages: [10000, 5000, 0],
          timeDeltas: [0, 3600, 7200],
        },
      },
      tags: ["local"],
    },
    rskTestnetDev: {
      accounts: process.env.PK ? [`0x${process.env.PK}`] : { mnemonic },
      chainId: chainIds.rskTestnet,
      url: "https://public-node.testnet.rsk.co",
      deployParameters: {
        gasLimit: 30000000, // high value to avoid coverage issue. https://github.com/NomicFoundation/hardhat/issues/3121
        airdropGovernance: {
          rootNode: "0xe8d063961b7d4bf4b67d3049fb28b83ccd2fc8b66237f6fa8bf1eb4a9b97dc13",
          tokenAddress: "0x2f778249852746b12c80f5246293539126061976",
        },
        airdropVesting: {
          rootNode: "0xe8d063961b7d4bf4b67d3049fb28b83ccd2fc8b66237f6fa8bf1eb4a9b97dc13",
          tokenAddress: "0x2f778249852746b12c80f5246293539126061976",
          claimPermit: {
            domain: { name: "EIP712Example", version: "1" },
            authMsg: "I authorize claim to",
            recipientMsg: "I authorize claim to be receive on",
          },
          registry: undefined, // A mock registry will be deployed
          percentages: [10000, 5000, 0],
          timeDeltas: [0, 3600, 7200],
        },
      },
      tags: ["local"],
    },
    goerli: createTestnetConfig("goerli"),
    kovan: createTestnetConfig("kovan"),
    rinkeby: createTestnetConfig("rinkeby"),
    ropsten: createTestnetConfig("ropsten"),
  },
  paths: {
    artifacts: "./artifacts",
    cache: "./cache",
    sources: "./contracts",
    tests: "./test",
  },
  solidity: {
    version: "0.8.20",
    settings: {
      // https://hardhat.org/hardhat-network/#solidity-optimizer-support
      optimizer: {
        enabled: true,
        runs: 200,
      },
      evmVersion: "london", // FIXME: latest evm version supported by rsk explorers, keep it updated
      outputSelection: {
        "*": {
          "*": ["storageLayout"],
        },
      },
    },
  },
  typechain: {
    outDir: "typechain",
    target: "ethers-v6",
    alwaysGenerateOverloads: false,
  },
  gasReporter: {
    enabled: process.env.REPORT_GAS ? true : false,
    currency: "USD",
    gasPrice: 21,
  },
  preprocess: {
    eachLine: removeConsoleLog(hre => !["hardhat", "localhost"].includes(hre.network.name)),
  },
  docgen: {
    path: "./docs",
    clear: false,
    runOnCompile: false,
    except: ["^contracts/echidna/", "^contracts/mocks/"],
  },
  contractSizer: {
    alphaSort: true,
    runOnCompile: true,
    disambiguatePaths: false,
    except: ["^contracts/echidna/", "^contracts/mocks/"],
  },
  mocha: {
    timeout: 100000,
  },
};

export default config;
