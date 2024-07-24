import { BigNumberish, toBigInt } from "ethers";
import { HardhatRuntimeEnvironment } from "hardhat/types/runtime";
import { StandardMerkleTree } from "@openzeppelin/merkle-tree";
import { Address } from "hardhat-deploy/types";

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
