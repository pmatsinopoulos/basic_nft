// SPDX-License-Identifier: MIT
pragma solidity 0.8.27;

import {console, Script} from "forge-std/Script.sol";
import {BasicNft} from "../src/BasicNft.sol";

contract DeployBasicNft is Script {
    function run() external {
        // start the Broadcast
        vm.startBroadcast();

        // Deploy the contract
        BasicNft basicNft = new BasicNft();

        // stop the broadcast
        vm.stopBroadcast();

        // Print the contract address
        console.log("BasicNft contract deployed to:", address(basicNft));
    }

    function checkBalance() external view {
        address firstAccountAddress = 0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266;
        uint256 balance = address(firstAccountAddress).balance;
        console.log("Check balance", balance);
    }
}
