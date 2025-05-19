// SPDX-License-Identifier: MIT
pragma solidity 0.8.27;

import {Script, console} from "forge-std/Script.sol";
import {MoodNft} from "../src/MoodNft.sol";

contract ManageMoodNft is Script {
    function mint(address _moodNft, address _receiver) external {
        vm.startBroadcast();

        MoodNft moodNft = MoodNft(_moodNft);

        uint256 tokenId = moodNft.mint(_receiver);

        console.log("tokenId", tokenId);

        vm.stopBroadcast();
    }

    function flipMood(address _moodNftContract, uint256 _tokenId) external {
        vm.startBroadcast();

        MoodNft moodNft = MoodNft(_moodNftContract);

        moodNft.flipMood(_tokenId);

        vm.stopBroadcast();
    }
}
