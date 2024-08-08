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

To get readable data in JSON format for using in the front end, obtain the log output and paste in a JSON file in the frontend, it comes with the structure:
[
  {
      address: '0x00000000000....',
      amount: 200,
      proof: [
        '0xba8f682129e462b575103ae73480848cc7f24ebcabf3cb5f12334c54d710948c',
        '0xa53e43a19488d623be788a0b9d368f9475e162543c55802a4327d960f593029f',
        '0xdbbf324f8ebd33ce189c7d56bae6f754b7aee80a1c09cf4d1a458f1f5fdc2141',
        '0x6d72bed3b7e2fc756c477b203bd24b333db18283ea59d61db24723ea66d3a018'
      ]
  }
  ...
]