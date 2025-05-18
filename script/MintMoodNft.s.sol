// SPDX-License-Identifier: MIT
pragma solidity 0.8.27;

import {Script} from "forge-std/Script.sol";
import {MoodNft} from "../src/MoodNft.sol";

contract MintMoodNft is Script {
    function run(address _moodNft, address _receiver) external {
        vm.startBroadcast();

        MoodNft moodNft = MoodNft(_moodNft);

        moodNft.mint(_receiver);

        vm.stopBroadcast();
    }
}
