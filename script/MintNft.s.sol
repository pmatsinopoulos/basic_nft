// SPDX-License-Identifier: MIT
pragma solidity 0.8.27;

import {console, Script} from "forge-std/Script.sol";
import {BasicNft} from "../src/BasicNft.sol";

contract MintNft is Script {
    function run(
        address _basicNft,
        address _to,
        string calldata _name,
        string calldata _description,
        string calldata _imageUri
    ) external {
        BasicNft basicNft = BasicNft(_basicNft);

        // start the Broadcast
        vm.startBroadcast();

        // Mint the NFT
        basicNft.mintNft(_to, _name, _description, _imageUri);

        // stop the broadcast
        vm.stopBroadcast();
    }
}
