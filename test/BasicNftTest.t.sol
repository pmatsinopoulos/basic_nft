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

    // -------------------------------
    // Test balanceOf

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
    // -------------------------------

    // -----------------------------
    // Test mintNft

    function test_mintNft_whenNotCalledByOwner_itReverts() public {
        // setup
        address peter = makeAddr("peter");
        address notOwner = makeAddr("notOwner");

        // fire
        vm.expectRevert(
            abi.encodeWithSelector(BasicNft.OnlyOwnerCanMint.selector, notOwner)
        );
        vm.prank(notOwner);
        basicNft.mintNft(peter);
    }

    function test_mintNft_whenThereIsNoNftLeftToMint_itReverts() public {
        address peter = makeAddr("peter");
        basicNft.setAllNftsMinted(true);

        // fire
        vm.expectRevert(BasicNft.NoMoreNftsLeftToMint.selector);
        basicNft.mintNft(peter);
    }

    function test_mintNft_assignsNewNftToAddress() public {
        // setup

        address peter = makeAddr("peter");
        uint256 balanceBefore = basicNft.balanceOf(peter);

        // fire

        basicNft.mintNft(peter);
        uint256 balanceAfter = basicNft.balanceOf(peter);
        assertEq(balanceAfter, balanceBefore + 1);
    }

    function test_mintNft_emitsTransferEvent() public {
        // setup
        address peter = makeAddr("peter");

        // fire
        vm.expectEmit(true, true, true, false, address(basicNft));
        emit BasicNft.Transfer(address(0), peter, 0);
        basicNft.mintNft(peter);
    }

    function test_mintNft_makesAddressTheOwner() public {
        address peter = makeAddr("peter");

        // fire
        basicNft.mintNft(peter);

        assertEq(basicNft.ownerOf(0), peter);
    }

    // -------------------------------
    // Test ownerOf

    function test_ownerOf_whenTokenGivenBelongsToAnAddress_theOwnerAddressIsReturned()
        public
    {
        // setup
        address peter = makeAddr("peter");
        basicNft.mintNft(peter);
        basicNft.mintNft(peter);
        uint256 tokenId = 1;

        // fire
        address result = basicNft.ownerOf(tokenId);

        assertEq(result, peter);
    }

    function test_ownerOf_whenTokenGivenDoesNotBelongToAnAddress_itReverts()
        public
    {
        uint256 tokenId = 25;

        // fire
        vm.expectRevert(
            abi.encodeWithSelector(
                BasicNft.TokenGivenIsNotOwned.selector,
                tokenId
            )
        );
        basicNft.ownerOf(tokenId);
    }

    // -------------------------------
}
