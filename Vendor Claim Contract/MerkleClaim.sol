// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity 0.8.20;

import { IERC20 } from './interface/IERC20.sol';
import { MerkleProof } from './library/MerkleProof.sol';


contract Airdrop {

  IERC20 public token;
  bytes32 public merkleRoot;
  address public owner;


  mapping(address => bool) public claimers;


  event Claim(address indexed to, uint256 amount);


  modifier onlyOwner() {
    require(msg.sender == owner);
    _;
  }

  constructor(address _token, address _owner, bytes32 _merkleRoot) {
    token = IERC20(_token);
    merkleRoot= _merkleRoot;
    owner = _owner;
  }

  function isValidLeaf(address to, uint256 amount, bytes32[] calldata proof) public view returns (bool) {
    bytes32 leaf = keccak256(abi.encodePacked(to, amount));
    return MerkleProof.verify(proof, merkleRoot, leaf);
  }

  function claim(address to, uint256 amount, bytes32[] calldata proof) external {
    require(!claimers[to], 'already claimed');
    require(isValidLeaf(to, amount, proof), 'not whitelisted');

    claimers[to] = true;

    token.transfer(to, amount);

    emit Claim(to, amount);
  }

  function protocolFallback(uint256 amount) public onlyOwner() {
    token.transfer(owner, amount);
  }

  function updateRoot(bytes32 _merkleRoot) public onlyOwner() {
    merkleRoot = _merkleRoot;
  }

}
