/**
 * This scripts take a JSON file as input, and calculates the MerkleTree root
 * hash for the Airdrop. The file should follow the account/balance schema.
 */

import fs from "fs";
import { BigNumberish, toBigInt } from "ethers";
import { Address } from "hardhat-deploy/types";
import { createMerkleTree } from "../utils";

async function main() {
  let inputPath = process.env.INPUT_PATH;
  if (!inputPath) {
    inputPath = "./scripts/merkle-tree/input-example.json";
    console.log(`No <INPUT_PATH> set, using ${inputPath} instead.`);
  }
  const rawData = fs.readFileSync(inputPath, "utf8");
  const jsonData = JSON.parse(rawData);
  const merkleTreeValues: Array<[Address, BigNumberish]> = new Array<[Address, BigNumberish]>();
  let totalClaimSupply = BigInt(0);

  const controlMap: Map<Address, BigNumberish> = new Map();
  jsonData.entries.forEach((leaf: [Address, BigNumberish], index: number) => {
    if (controlMap.has(leaf[0])) throw Error(`No duplications allow: ${leaf[0]} at position ${index}`);
    if (toBigInt(leaf[1]) <= BigInt(0)) throw Error(`Value cannot be zero: position ${index}`);
    controlMap.set(leaf[0], leaf[1]);

    merkleTreeValues.push(leaf);
    totalClaimSupply += toBigInt(leaf[1]);
  });

  const merkleTree = createMerkleTree(merkleTreeValues);
  jsonData.entries.forEach((leaf: [Address, BigNumberish]) => {
    console.log(`Proof for ${leaf[0]} is: ${merkleTree.getProof(leaf)}`);
  });
  console.log("------------------------");
  console.log("MerkleTree root is:", merkleTree.root);
  console.log("TotalClaimSupply is:", totalClaimSupply);
}

main().catch(error => {
  console.error(error);
  process.exitCode = 1;
});
