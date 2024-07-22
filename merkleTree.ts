const { MerkleTree } = require('merkletreejs');
const keccak256 = require('keccak256');

const airdropList = [
  { address: '0x91F643a0Eb273F1b526450cAf1D2f1B711B50d1C', amount: 1 },
  { address: '0xEE0F2CA40cd73256f9cBb658A671E404931e6c4c', amount: 10 },
  { address: '0x643B41669c2B374AFf42f4bd311d325D571687Ed', amount: 5 },
  { address: '0x50a8B761d9bc0C7806deC8869f677BA21e9d01C9', amount: 8 },
];


const leaves = airdropList.map(x => keccak256(x.address + x.amount));

const merkleTree = new MerkleTree(leaves, keccak256, { sortPairs: true });

const root = merkleTree.getRoot().toString('hex');

console.log('Merkle Root:', root);


const leaf = keccak256('0x91F643a0Eb273F1b526450cAf1D2f1B711B50d1C' + 1);
const proof = merkleTree.getProof(leaf).map(x => x.data.toString('hex'));

console.log('Proof for 0xAddress1:', proof);