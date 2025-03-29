// SPDX-License-Identifier: MIT
pragma solidity 0.8.27;

import {Test} from "forge-std/Test.sol";
import {console} from "forge-std/console.sol";
import {BasicNft} from "../src/BasicNft.sol";

contract BasicNftTest is Test {
    BasicNft basicNft;

    function setUp() public {
        basicNft = new BasicNft();
    }

    ////////////////////////////////
    //                            //
    //          external          //
    //                            //
    ////////////////////////////////

    /// Test balanceOf

    function test_balanceOf_whenAddressGivenDoesNotOwnAnNft_itReturns_0()
        public
    {
        address peter = makeAddr("peter");

        // fire
        uint256 result = basicNft.balanceOf(peter);

        assertEq(result, 0);
    }

    function test_balanceOf_whenAddressGivenOwns1Nft_itReturns_1() public {
        // setup
        address peter = makeAddr("peter");
        basicNft.mintNft(peter);

        // fire
        uint256 result = basicNft.balanceOf(peter);

        assertEq(result, 1);
    }

    function test_balanceOf_whenAddressGivenOwns2Nfts_itReturns_2() public {
        // setup
        address peter = makeAddr("peter");
        basicNft.mintNft(peter);
        basicNft.mintNft(peter);

        // fire
        uint256 result = basicNft.balanceOf(peter);
        assertEq(result, 2);
    }

    function test_balanceOf_whenAddressGivenIsZero_itThrows() public {
        // setup
        address zero = address(0);

        // fire
        vm.expectRevert(BasicNft.AddressZeroNotAllowedToOwnNft.selector);
        basicNft.balanceOf(zero);
    }
}
