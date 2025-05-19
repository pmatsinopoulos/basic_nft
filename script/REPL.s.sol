// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.27;

import {Vm} from "lib/forge-std/src/Vm.sol";

import {MoodNft} from "src/MoodNft.sol";
import {console} from "forge-std/Test.sol";

contract REPL {
    Vm internal constant vm = Vm(address(uint160(uint256(keccak256("hevm cheat code")))));

    /// @notice REPL contract entry point
    function run() public {
        MoodNft moodNft = MoodNft(0x5FbDB2315678afecb367f032d93F642f64180aa3);
        address owner = moodNft.owner();
        console.log(owner);
    }
}
