import { BigNumberish, ContractTransactionReceipt, ContractTransactionResponse, toBigInt } from "ethers";
import { HardhatRuntimeEnvironment } from "hardhat/types/runtime";
import { ethers } from "hardhat";
import { StandardMerkleTree } from "@openzeppelin/merkle-tree";
import { Address } from "hardhat-deploy/types";

export const CONSTANTS = {
  ZERO_ADDRESS: ethers.ZeroAddress,
  MAX_UINT256: ethers.MaxUint256,
  MAX_BALANCE: ethers.MaxUint256 / BigInt(10 ** 17),
  PRECISION: BigInt(10 ** 18),
  ONE: BigInt(10 ** 18),
};

export const DEFAULT_ADMIN_ROLE = "0x0000000000000000000000000000000000000000000000000000000000000000";
export const MINTER_ROLE = ethers.id("MINTER_ROLE");
export const BURNER_ROLE = ethers.id("BURNER_ROLE");
export const PAUSER_ROLE = ethers.id("PAUSER_ROLE");

export const waitForTxConfirmation = async (
  tx: Promise<ContractTransactionResponse>,
  confirmations: number = 1,
): Promise<ContractTransactionReceipt | null> => {
  return (await tx).wait(confirmations);
};

export const getNetworkDeployParams = (hre: HardhatRuntimeEnvironment) => {
  const network = hre.network.name === "localhost" ? "hardhat" : hre.network.name;
  return hre.config.networks[network].deployParameters;
};

export const deployUUPSArtifact = async ({
  hre,
  artifactBaseName,
  contract,
  initializeArgs,
}: {
  hre: HardhatRuntimeEnvironment;
  artifactBaseName?: string;
  contract: string;
  initializeArgs?: any[];
}) => {
  const {
    deployments: { deploy },
    getNamedAccounts,
  } = hre;
  const { deployer } = await getNamedAccounts();
  const gasLimit = getNetworkDeployParams(hre).gasLimit;
  artifactBaseName = artifactBaseName || contract;
  let execute;
  if (initializeArgs) {
    execute = {
      init: {
        methodName: "initialize",
        args: initializeArgs,
      },
    };
  }
  const deployResult = await deploy(`${artifactBaseName}Proxy`, {
    contract,
    from: deployer,
    proxy: {
      proxyContract: "ERC1967Proxy",
      proxyArgs: ["{implementation}", "{data}"],
      execute,
    },
    gasLimit,
  });
  console.log(`${contract}, as ${artifactBaseName} implementation deployed at ${deployResult.implementation}`);
  console.log(`${artifactBaseName}Proxy ERC1967Proxy deployed at ${deployResult.address}`);
  return deployResult;
};

export const createMerkleTree = (merkleTreeValues: Array<[Address, BigNumberish]>) => {
  return StandardMerkleTree.of(merkleTreeValues, ["address", "uint256"]);
};

export const createDefaultMerkleTree = async (hre: HardhatRuntimeEnvironment) => {
  const namedAccounts = await hre.getNamedAccounts();
  const defaultMerkleTreeReceivers: Array<Address> = [
    namedAccounts.alice,
    namedAccounts.bob,
    namedAccounts.charly,
    namedAccounts.david,
  ];
  const defaultMerkleTreeValues: Array<[Address, BigNumberish]> = defaultMerkleTreeReceivers.map((recipientt, i) => [
    recipientt,
    (BigInt(10 ** 18) * BigInt(i + 1)).toString(),
  ]);
  let totalClaimSupply = BigInt(0);
  const defaultMerkleTreeMap: Map<Address, BigNumberish> = new Map();
  for (const value of defaultMerkleTreeValues) {
    defaultMerkleTreeMap.set(value[0], value[1]);
    totalClaimSupply += toBigInt(value[1]);
  }

  const defaultMerkleTree = await createMerkleTree(defaultMerkleTreeValues);
  return { defaultMerkleTree, defaultMerkleTreeReceivers, defaultMerkleTreeMap, totalClaimSupply };
};
