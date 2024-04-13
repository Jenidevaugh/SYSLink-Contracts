// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity 0.8.20;

import { IERC20 } from './interface/IERC20.sol';
import { Airdrop } from './airdrop.sol';

contract AirdropFactory {
    address public owner;

    Airdrop[] public airdrop;

    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can call this function");
        _;
    }

    constructor() {
        owner = msg.sender;
    }

    function createAirdrop(address _token, bytes32 _merkleRoot, uint256 _amount) public onlyOwner() {
        Airdrop airdropContract = new Airdrop(_token, owner, _merkleRoot);
        if (_amount > 0) {
            IERC20(_token).transferFrom(msg.sender, address(airdropContract), _amount);
        }
        airdrop.push(airdropContract);
    }

    function multipleAirdrop(address[] memory _token, bytes32[] memory _merkleRoot, uint256[] memory _amounts) public onlyOwner() {
        require(_token.length == _merkleRoot.length && _merkleRoot.length == _amounts.length, "Invalid input");
        for (uint256 i = 0; i < _token.length; i++) {
            createAirdrop(_token[i], _merkleRoot[i], _amounts[i]);
        }
    }
    
}
