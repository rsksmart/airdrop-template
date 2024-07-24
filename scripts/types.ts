import { BytesLike } from "ethers";
import { Address } from "hardhat-deploy/types";

type ClaimPermit = { domain: { name: string; version: string }; authMsg: string; recipientMsg: string };

export type DeployParameters = {
  airdropGovernance?: {
    rootNode?: BytesLike;
    tokenAddress?: Address;
  };
  airdropVesting?: {
    registry?: Address;
    rootNode?: BytesLike;
    claimPermit: ClaimPermit;
    tokenAddress?: Address;
    percentages: number[];
    timeDeltas: number[];
  };
  gasLimit: number;
};
