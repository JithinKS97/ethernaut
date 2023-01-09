// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import './base/Level.sol';
import './Shuttle.sol';

contract ShuttleFactory is Level {
  function createInstance(address _player) override public payable returns (address) {
    _player;
    bytes32 password = 0x50cb9fe53daa9737b786ab3646f04d0150dc50ef4e75f59509d83667ad5adb20;
    Shuttle instance = new Shuttle(password);
    return address(instance);
  }

  function validateInstance(address payable _instance, address _player) view override public returns (bool) {
    Shuttle instance = Shuttle(_instance);
    return instance.launched();
  }
}