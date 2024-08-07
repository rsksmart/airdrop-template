# Merkle tree builder

This scripts allows you to generate the merkle tree root for an [address,uint256] array set.

You can run it with hardhat scripts like:

`INPUT_PATH="./scripts/merkle-tree/input-example.json" npx hardhat run ./scripts/merkle-tree/build-root.ts`

Where `INPUT_PATH` environment variable has the path to a JSON file following this structure, like [.input-example.json](input-example.json):

```json
{
  "entries": [
    ["0x794ECa71579286398C4aee17e3D96E8DaF7559bA", 1000],
    ...
  ]
]
```

Where `entries` property, is and tuple array set containing what will become each leaf of the tree, with `address` and `value`. In Airdrop use case, `value` will be the balance airdropped.

This script will console output two values, the root of the tree and the sum of each leaf value ("TotalClaimSupply"), like:

```sh
MerkleTree root is: 0x9067d4a327babf16807f1425adf037e2aeba79bd2b811a45d8de1a1450baeef6
TotalClaimSupply is: 47600n
```

_Note_: this script is intended to be use with small sets (less that ~100k entries), as the whole JSON file is loaded into memory. For bigger data sets, a new version with stream file reading should be adapted.
