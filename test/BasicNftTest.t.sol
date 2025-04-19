// SPDX-License-Identifier: MIT
pragma solidity 0.8.27;

import {Test} from "forge-std/Test.sol";
import {console} from "forge-std/console.sol";
import {BasicNft} from "../src/BasicNft.sol";
import {IERC721} from "../src/IERC721.sol";
import {IERC165} from "../src/IERC165.sol";
import {IERC721Metadata} from "../src/IERC721Metadata.sol";

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
        emit IERC721.Transfer(address(0), peter, 0);
        basicNft.mintNft(peter);
    }

    function test_mintNft_makesAddressTheOwner() public {
        address peter = makeAddr("peter");

        // fire
        basicNft.mintNft(peter);

        assertEq(basicNft.ownerOf(0), peter);
    }

    // ------------------------------------
    // Test mintNft with metadata

    function test_mintNft_setsAllMetadata() public {
        address peter = makeAddr("peter");
        string memory name = "My fantastic picture";
        string
            memory description = "My fantastic picture that show a mountain and a lake";
        string
            memory imageUri = "https://www.basicnftconnection.net/images/0.jpg";

        // fire
        basicNft.mintNft(peter, name, description, imageUri);

        string memory nftName = basicNft.tokenName(0);
        assertEq(nftName, name);

        string memory nftDescription = basicNft.tokenDescription(0);
        assertEq(nftDescription, description);

        string memory nftImageUri = basicNft.tokenImageUri(0);
        assertEq(nftImageUri, imageUri);

        BasicNft.NftMetadata memory nftMetadata = basicNft.tokenMetadata(0);
        assertEq(nftMetadata.name, name);
        assertEq(nftMetadata.description, description);
        assertEq(nftMetadata.imageUri, imageUri);
    }

    // --------------------------------------------------
    // Metadata: name, description , imageUri for token

    function test_tokenName_returnsTheNameOfTheNft() public {
        address peter = makeAddr("peter");
        basicNft.mintNft(peter);
        basicNft.mintNft(peter, "name", "desc", "imageUri");

        // fire
        string memory name = basicNft.tokenName(0);
        assertEq(name, "");
        name = basicNft.tokenName(1);
        assertEq(name, "name");
    }

    function test_tokenDescription_returnsTheNameOfTheNft() public {
        address peter = makeAddr("peter");
        basicNft.mintNft(peter);
        basicNft.mintNft(peter, "name", "desc", "imageUri");

        // fire
        string memory description = basicNft.tokenDescription(0);
        assertEq(description, "");
        description = basicNft.tokenDescription(1);
        assertEq(description, "desc");
    }

    function test_tokenImageUri_returnsTheNameOfTheNft() public {
        address peter = makeAddr("peter");
        basicNft.mintNft(peter);
        basicNft.mintNft(peter, "name", "desc", "imageUri");

        // fire
        string memory imageUri = basicNft.tokenImageUri(0);
        assertEq(imageUri, "");
        imageUri = basicNft.tokenImageUri(1);
        assertEq(imageUri, "imageUri");
    }

    // -------------------------------
    // Metadata for a token/nft

    function test_tokenMetadata_returnsTheNameOfTheNft() public {
        address peter = makeAddr("peter");
        basicNft.mintNft(peter);
        basicNft.mintNft(peter, "name", "desc", "imageUri");

        // fire
        BasicNft.NftMetadata memory nftMetadata = basicNft.tokenMetadata(0);
        assertEq(nftMetadata.name, "");
        assertEq(nftMetadata.description, "");
        assertEq(nftMetadata.imageUri, "");

        nftMetadata = basicNft.tokenMetadata(1);
        assertEq(nftMetadata.name, "name");
        assertEq(nftMetadata.description, "desc");
        assertEq(nftMetadata.imageUri, "imageUri");
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

    // -------------------------------
    // Test safeTransferFrom() without data argument

    function test_safeTransferFrom_whenSenderIsCurrentOwner_transfersTheOwnershipOfAnNftFromOneAddressToAnother()
        public
    {
        // setup
        address peter = makeAddr("peter");
        address panos = makeAddr("panos");
        basicNft.mintNft(peter);
        uint256 tokenId = 0;

        // fire
        vm.expectEmit(true, true, true, false, address(basicNft));
        emit IERC721.Transfer(peter, panos, tokenId);
        vm.prank(peter);
        basicNft.safeTransferFrom(peter, panos, tokenId);
    }

    function test_safeTransferFrom_whenMsgSenderIsNotCurrentOwnerNeitherAuthorizedOperatorNorApprovedAddress_itReverts()
        public
    {
        // setup
        address peter = makeAddr("peter");
        basicNft.mintNft(peter); // peter owns tokenId 0

        address panos = makeAddr("panos");

        // fire
        vm.expectRevert(
            abi.encodeWithSelector(
                BasicNft.NftIsNotOwnedByGivenAddress.selector,
                peter,
                panos,
                0
            )
        );
        basicNft.safeTransferFrom(panos, peter, 0);
    }

    function test_safeTransferFrom_whenMsgSenderIsAuthorizedOperator_itDoesTheTransfer()
        public
    {
        // setup
        address peter = makeAddr("peter");
        basicNft.mintNft(peter); // peter owns tokenId 0
        address panos = makeAddr("panos");
        address authorizedOperator = makeAddr("authorizedOperator");
        vm.prank(peter);
        basicNft.setApprovalForAll(authorizedOperator, true);

        // fire
        vm.expectEmit(true, true, true, false, address(basicNft));
        emit IERC721.Transfer(peter, panos, 0);

        vm.prank(authorizedOperator);
        basicNft.safeTransferFrom(peter, panos, 0);
    }

    function test_safeTransferFrom_whenMsgSenderIsAnApprovedAddress_itDoesTheTransfer()
        public
    {
        // setup
        address peter = makeAddr("peter");
        basicNft.mintNft(peter); // peter owns tokenId 0

        address panos = makeAddr("panos");
        address approvedAddress = makeAddr("approvedAddress");
        vm.prank(peter);
        basicNft.approve(approvedAddress, 0);

        // fire
        vm.expectEmit(true, true, true, false, address(basicNft));
        emit IERC721.Transfer(peter, panos, 0);
        vm.prank(approvedAddress);
        basicNft.safeTransferFrom(peter, panos, 0);
    }

    function test_safeTransferFrom_whenToIsZeroAddress_itReverts() public {
        // setup
        address peter = makeAddr("peter");
        basicNft.mintNft(peter); // peter owns tokenId 0

        // fire
        vm.expectRevert(
            abi.encodeWithSelector(
                BasicNft.TransferToAddressZeroNotAllowed.selector
            )
        );
        vm.prank(peter);
        basicNft.safeTransferFrom(peter, address(0), 0);
    }

    function test_safeTransferFrom_whenTokenIdIsNotValid_itReverts() public {
        // setup
        address peter = makeAddr("peter");
        basicNft.mintNft(peter); // peter owns tokenId 0
        address panos = makeAddr("panos");

        // fire
        vm.expectRevert(
            abi.encodeWithSelector(BasicNft.InvalidNft.selector, 1)
        );
        basicNft.safeTransferFrom(peter, panos, 1);
    }

    function test_safeTransferFrom_whenToIsSmartContractThatDoesNotImplementOnERC721Received_itReverts()
        public
    {
        // setup
        address peter = makeAddr("peter");
        basicNft.mintNft(peter);
        InvalidSmartContract invalidSmartContract = new InvalidSmartContract();

        // fire
        vm.expectRevert(
            abi.encodeWithSelector(
                BasicNft.TransferToSmartContractFailed.selector,
                address(invalidSmartContract)
            )
        );
        vm.prank(peter);
        basicNft.safeTransferFrom(peter, address(invalidSmartContract), 0);
    }

    function test_safeTransferFrom_whenToIsSmartContractThatDoesNotReturnCorrectData_itReverts()
        public
    {
        // setup
        address peter = makeAddr("peter");
        basicNft.mintNft(peter);
        InvalidSmartContractWrongData invalidSmartContract = new InvalidSmartContractWrongData();

        // fire
        vm.expectRevert(
            abi.encodeWithSelector(
                BasicNft.TransferToSmartContractWrongDataReturned.selector,
                address(invalidSmartContract),
                bytes4(0xeeafbddc)
            )
        );
        vm.prank(peter);
        basicNft.safeTransferFrom(peter, address(invalidSmartContract), 0);
    }

    // -------------------------------

    // test safeTransferFrom() with data

    function test_safeTransferFrom_withData_whenSenderIsCurrentOwner_transfersTheOwnershipOfAnNftFromOneAddressToAnother()
        public
    {
        // setup
        address peter = makeAddr("peter");
        address panos = makeAddr("panos");
        basicNft.mintNft(peter);
        uint256 tokenId = 0;

        // fire
        vm.expectEmit(true, true, true, false, address(basicNft));
        emit IERC721.Transfer(peter, panos, tokenId);
        vm.prank(peter);
        basicNft.safeTransferFrom(
            peter,
            panos,
            tokenId,
            abi.encode("Hello World")
        );
    }

    function test_safeTransferFrom_withData_whenMsgSenderIsNotCurrentOwnerNeitherAuthorizedOperatorNorApprovedAddress_itReverts()
        public
    {
        // setup
        address peter = makeAddr("peter");
        basicNft.mintNft(peter); // peter owns tokenId 0

        address panos = makeAddr("panos");

        // fire
        vm.expectRevert(
            abi.encodeWithSelector(
                BasicNft.NftIsNotOwnedByGivenAddress.selector,
                peter,
                panos,
                0
            )
        );
        basicNft.safeTransferFrom(panos, peter, 0, abi.encode("Hello World"));
    }

    function test_safeTransferFrom_withData_whenMsgSenderIsAuthorizedOperator_itDoesTheTransfer()
        public
    {
        // setup
        address peter = makeAddr("peter");
        basicNft.mintNft(peter); // peter owns tokenId 0
        address panos = makeAddr("panos");
        address authorizedOperator = makeAddr("authorizedOperator");
        vm.prank(peter);
        basicNft.setApprovalForAll(authorizedOperator, true);

        // fire
        vm.expectEmit(true, true, true, false, address(basicNft));
        emit IERC721.Transfer(peter, panos, 0);

        vm.prank(authorizedOperator);
        basicNft.safeTransferFrom(peter, panos, 0, abi.encode("Hello World"));
    }

    function test_safeTransferFrom_withData_whenMsgSenderIsAnApprovedAddress_itDoesTheTransfer()
        public
    {
        // setup
        address peter = makeAddr("peter");
        basicNft.mintNft(peter); // peter owns tokenId 0

        address panos = makeAddr("panos");
        address approvedAddress = makeAddr("approvedAddress");
        vm.prank(peter);
        basicNft.approve(approvedAddress, 0);

        // fire
        vm.expectEmit(true, true, true, false, address(basicNft));
        emit IERC721.Transfer(peter, panos, 0);
        vm.prank(approvedAddress);
        basicNft.safeTransferFrom(peter, panos, 0, abi.encode("Hello World"));
    }

    function test_safeTransferFrom_withData_whenToIsZeroAddress_itReverts()
        public
    {
        // setup
        address peter = makeAddr("peter");
        basicNft.mintNft(peter); // peter owns tokenId 0

        // fire
        vm.expectRevert(
            abi.encodeWithSelector(
                BasicNft.TransferToAddressZeroNotAllowed.selector
            )
        );
        vm.prank(peter);
        basicNft.safeTransferFrom(
            peter,
            address(0),
            0,
            abi.encode("Hello World")
        );
    }

    function test_safeTransferFrom_withData_whenTokenIdIsNotValid_itReverts()
        public
    {
        // setup
        address peter = makeAddr("peter");
        basicNft.mintNft(peter); // peter owns tokenId 0
        address panos = makeAddr("panos");

        // fire
        vm.expectRevert(
            abi.encodeWithSelector(BasicNft.InvalidNft.selector, 1)
        );
        basicNft.safeTransferFrom(peter, panos, 1, abi.encode("Hello World"));
    }

    function test_safeTransferFrom_withData_whenToIsSmartContract_itCallsOnERC721Received()
        public
    {
        // setup
        address peter = makeAddr("peter");
        basicNft.mintNft(peter);
        SmartContract smartContract = new SmartContract();

        // fire
        vm.prank(peter);
        basicNft.safeTransferFrom(
            peter,
            address(smartContract),
            0,
            abi.encode("Hello World")
        );

        bool called = smartContract.called();
        assertTrue(called, "onERC721Received was not called");

        address from = smartContract.from();
        assertEq(from, peter, "from is not correct");

        address operator = smartContract.operator();
        assertEq(operator, peter, "operator is not correct");

        uint256 tokenId = smartContract.tokenId();
        assertEq(tokenId, 0, "tokenId is not correct");

        bytes memory data = smartContract.data();
        assertEq(data, abi.encode("Hello World"), "data is not correct");
    }

    function test_safeTransferFrom_withData_whenToIsSmartContractThatDoesNotImplementOnERC721Received_itReverts()
        public
    {
        // setup
        address peter = makeAddr("peter");
        basicNft.mintNft(peter);
        InvalidSmartContract invalidSmartContract = new InvalidSmartContract();

        // fire
        vm.expectRevert(
            abi.encodeWithSelector(
                BasicNft.TransferToSmartContractFailed.selector,
                address(invalidSmartContract)
            )
        );
        vm.prank(peter);
        basicNft.safeTransferFrom(
            peter,
            address(invalidSmartContract),
            0,
            abi.encode("Hello World")
        );
    }

    function test_safeTransferFrom_withData_whenToIsSmartContractThatDoesNotReturnCorrectData_itReverts()
        public
    {
        // setup
        address peter = makeAddr("peter");
        basicNft.mintNft(peter);
        InvalidSmartContractWrongData invalidSmartContract = new InvalidSmartContractWrongData();

        // fire
        vm.expectRevert(
            abi.encodeWithSelector(
                BasicNft.TransferToSmartContractWrongDataReturned.selector,
                address(invalidSmartContract),
                bytes4(0xeeafbddc)
            )
        );
        vm.prank(peter);
        basicNft.safeTransferFrom(
            peter,
            address(invalidSmartContract),
            0,
            abi.encode("Hello World")
        );
    }

    // -------------------------------
    // Test transferFrom()

    function test_transferFrom_whenSenderIsCurrentOwner_transfersTheOwnershipOfAnNftFromOneAddressToAnother()
        public
    {
        // setup
        address peter = makeAddr("peter");
        address panos = makeAddr("panos");
        basicNft.mintNft(peter);
        uint256 tokenId = 0;

        // fire
        vm.expectEmit(true, true, true, false, address(basicNft));
        emit IERC721.Transfer(peter, panos, tokenId);
        vm.prank(peter);
        basicNft.transferFrom(peter, panos, tokenId);

        // TODO: We need to check for the Approval event that will reset approval to none
    }

    function test_transferFrom_whenMsgSenderIsNotCurrentOwnerNeitherAuthorizedOperatorNorApprovedAddress_itReverts()
        public
    {
        // setup
        address peter = makeAddr("peter");
        basicNft.mintNft(peter); // peter owns tokenId 0

        address panos = makeAddr("panos");

        // fire
        vm.expectRevert(
            abi.encodeWithSelector(
                BasicNft.NftIsNotOwnedByGivenAddress.selector,
                peter,
                panos,
                0
            )
        );
        basicNft.transferFrom(panos, peter, 0);
    }

    function test_transferFrom_whenMsgSenderIsAuthorizedOperator_itDoesTheTransfer()
        public
    {
        // setup
        address peter = makeAddr("peter");
        basicNft.mintNft(peter); // peter owns tokenId 0
        address panos = makeAddr("panos");
        address authorizedOperator = makeAddr("authorizedOperator");
        vm.prank(peter);
        basicNft.setApprovalForAll(authorizedOperator, true);

        // fire
        vm.expectEmit(true, true, true, false, address(basicNft));
        emit IERC721.Transfer(peter, panos, 0);

        vm.prank(authorizedOperator);
        basicNft.transferFrom(peter, panos, 0);
    }

    function test_transferFrom_whenMsgSenderIsAnApprovedAddress_itDoesTheTransfer()
        public
    {
        // setup
        address peter = makeAddr("peter");
        basicNft.mintNft(peter); // peter owns tokenId 0

        address panos = makeAddr("panos");
        address approvedAddress = makeAddr("approvedAddress");
        vm.prank(peter);
        basicNft.approve(approvedAddress, 0);

        // fire
        vm.expectEmit(true, true, true, false, address(basicNft));
        emit IERC721.Transfer(peter, panos, 0);
        vm.prank(approvedAddress);
        basicNft.transferFrom(peter, panos, 0);
    }

    function test_transferFrom_whenToIsZeroAddress_itReverts() public {
        // setup
        address peter = makeAddr("peter");
        basicNft.mintNft(peter); // peter owns tokenId 0

        // fire
        vm.expectRevert(
            abi.encodeWithSelector(
                BasicNft.TransferToAddressZeroNotAllowed.selector
            )
        );
        vm.prank(peter);
        basicNft.transferFrom(peter, address(0), 0);
    }

    function test_transferFrom_whenTokenIdIsNotValid_itReverts() public {
        // setup
        address peter = makeAddr("peter");
        basicNft.mintNft(peter); // peter owns tokenId 0
        address panos = makeAddr("panos");

        // fire
        vm.expectRevert(
            abi.encodeWithSelector(BasicNft.InvalidNft.selector, 1)
        );
        basicNft.transferFrom(peter, panos, 1);
    }
    // -------------------------------

    // -------------------------------
    // Test approve()

    function test_approve_whenMsgSenderIsNotCurrentNftOwner_itReverts() public {
        // setup
        address notNftOwner = makeAddr("paul");
        uint256 tokenId = 0;
        address approvedAddress = makeAddr("approvedAddress");
        address nftOwner = makeAddr("nftOwner");
        basicNft.mintNft(nftOwner); // nftOwner owns tokenId 0

        // fire
        vm.prank(notNftOwner);
        vm.expectRevert(
            abi.encodeWithSelector(
                BasicNft
                    .ApprovalSenderNotOwnerNorAuthorizedOperatorNorApprovedAddress
                    .selector,
                address(notNftOwner),
                address(nftOwner),
                0
            )
        );
        basicNft.approve(approvedAddress, tokenId);
    }

    function test_approve_whenSenderIsCurrentOwner_approvesAndEmitsEvent()
        public
    {
        // setup
        address peter = makeAddr("peter");
        address approvedAddress = makeAddr("approvedAddress");
        basicNft.mintNft(peter);
        uint256 tokenId = 0;

        // fire
        vm.expectEmit(true, true, true, false, address(basicNft));
        emit IERC721.Approval(peter, approvedAddress, tokenId);
        vm.prank(peter);
        basicNft.approve(approvedAddress, tokenId);
    }

    function test_approve_whenMsgSenderIsAuthorizedOperator_approvesAndEmitsEvent()
        public
    {
        // setup
        address peter = makeAddr("peter");
        basicNft.mintNft(peter); // peter owns tokenId 0
        address panos = makeAddr("panos");
        address authorizedOperator = makeAddr("authorizedOperator");
        vm.prank(peter);
        basicNft.setApprovalForAll(authorizedOperator, true);

        // fire
        vm.expectEmit(true, true, true, false, address(basicNft));
        emit IERC721.Approval(peter, panos, 0);

        vm.prank(authorizedOperator);
        basicNft.approve(panos, 0);
    }

    // The standard specifies that `approve` should throw unless `msg.sender` is the current NFT owner
    // or an authorized operator. It does not allow an approved address for a specific token to call `approve`.
    // This is distinct from the rules for `transfer`, which allow an approved address to transfer the token.
    // This distinction is intentional in the standard and not a conflict.
    //
    function test_approve_whenMsgSenderIsAnApprovedAddressForTheGivenToken_itReverts()
        public
    {
        // setup
        address peter = makeAddr("peter");
        basicNft.mintNft(peter); // peter owns tokenId 0

        address panos = makeAddr("panos");
        address approvedAddress = makeAddr("approvedAddress");
        vm.prank(peter);
        basicNft.approve(approvedAddress, 0);

        // fire
        vm.expectRevert(
            abi.encodeWithSelector(
                BasicNft
                    .ApprovalSenderNotOwnerNorAuthorizedOperatorNorApprovedAddress
                    .selector,
                address(approvedAddress),
                address(peter),
                0
            )
        );
        vm.prank(approvedAddress);
        basicNft.approve(panos, 0);
    }

    function test_approve_whenZeroAddress_itMeansThereIsNoApprovedAddress()
        public
    {
        address peter = makeAddr("peter");
        basicNft.mintNft(peter); // peter owns tokenId 0
        basicNft.mintNft(peter); // peter owns tokenId 1

        // setup
        uint256 tokenId = 1;

        // fire
        vm.expectEmit(true, true, true, false, address(basicNft));
        emit IERC721.Approval(peter, address(0), tokenId);
        vm.prank(peter);
        basicNft.approve(address(0), tokenId);

        address approvedAddress = basicNft.getApproved(1);
        assertEq(approvedAddress, address(0), "approvedAddress is not correct");
    }

    // a given NFT can have only one approved address at a time.
    //
    function test_approve_changesTheApprovedAddressForTheGivenNft() public {
        // setup
        address peter = makeAddr("peter");
        basicNft.mintNft(peter); // peter owns tokenId 0
        address oldApprovedAddress = makeAddr("oldApprovedAddress");

        vm.prank(peter);
        basicNft.approve(oldApprovedAddress, 0); // oldApprovedAddress is approved for tokenId 0

        address newApprovedAddress = makeAddr("newApprovedAddress");

        // fire
        vm.prank(peter);
        basicNft.approve(newApprovedAddress, 0);

        assertEq(basicNft.getApproved(0), newApprovedAddress);
    }

    //--------------------------------
    // Test setApprovalForAll()

    function test_setApprovalForAll_whenTrue_itSetsTheOperatorAsApprovedForAllNftsOfMsgCaller()
        public
    {
        // setup
        address operator = makeAddr("operator");
        address nftOwner = makeAddr("nftOwner");
        basicNft.mintNft(nftOwner); // nftOwner owns tokenId 0

        // fire
        vm.expectEmit(true, true, false, true, address(basicNft));
        emit IERC721.ApprovalForAll(nftOwner, operator, true);
        vm.prank(nftOwner);
        basicNft.setApprovalForAll(operator, true);

        bool isApproved = basicNft.isApprovedForAll(nftOwner, operator);
        assertTrue(
            isApproved,
            "isApprovedForAll is not correct. It should be true"
        );
    }

    function test_setApprovalForAll_whenFalse_itSetsTheOperatorAsNotApprovedForAllNftsOfMsgCaller()
        public
    {
        // setup
        address operator = makeAddr("operator");
        address nftOwner = makeAddr("nftOwner");
        basicNft.mintNft(nftOwner); // nftOwner owns tokenId 0

        // fire
        vm.expectEmit(true, true, false, true, address(basicNft));
        emit IERC721.ApprovalForAll(nftOwner, operator, false);
        vm.prank(nftOwner);
        basicNft.setApprovalForAll(operator, false);

        bool isApproved = basicNft.isApprovedForAll(nftOwner, operator);
        assertFalse(
            isApproved,
            "isApprovedForAll is not correct. It should be false"
        );
    }

    function test_setApprovalForAll_canSetFlagForManyOperators() public {
        // setup
        address nftOwner = makeAddr("nftOwner");
        address operator1 = makeAddr("operator1");
        address operator2 = makeAddr("operator2");

        // fire
        vm.prank(nftOwner);
        basicNft.setApprovalForAll(operator1, true);
        basicNft.setApprovalForAll(operator1, true);

        bool isApproved = basicNft.isApprovedForAll(nftOwner, operator1);
        assertTrue(
            isApproved,
            "isApprovedForAll is not correct. It should be true"
        );

        isApproved = basicNft.isApprovedForAll(nftOwner, operator2);
        assertFalse(
            isApproved,
            "isApprovedForAll is not correct. It should be false"
        );
    }

    // --------------------------------

    // --------------------------------
    // Test getApproved()

    function test_getApproved_returnsTheApprovedAddressForTheGivenNft() public {
        // setup
        address peter = makeAddr("peter");
        basicNft.mintNft(peter); // peter owns tokenId 0
        address panos = makeAddr("panos");
        vm.prank(peter);
        basicNft.approve(panos, 0);

        // fire
        address approvedAddress = basicNft.getApproved(0);

        assertEq(
            approvedAddress,
            panos,
            "approvedAddress should have been panos"
        );
    }

    function test_getApproved_whenTokenIdIsNotValid_itReverts() public {
        // fire
        vm.expectRevert(
            abi.encodeWithSelector(BasicNft.InvalidNft.selector, 0)
        );
        basicNft.getApproved(0); // 0 is invalid it has not been minted yet
    }

    function test_getApproved_whenNoApprovedAddress_itReturnsZeroAddress()
        public
    {
        // setup
        address peter = makeAddr("peter");
        basicNft.mintNft(peter); // peter owns tokenId 0

        // fire
        address approvedAddress = basicNft.getApproved(0);

        assertEq(approvedAddress, address(0), "approvedAddress should be zero");
    }
    // --------------------------------

    // --------------------------------
    // Test isApprovedForAll()

    function test_isApprovedForAll_whenOperatorIsApproved_itReturnsTrue()
        public
    {
        // setup
        address operator = makeAddr("operator");
        address nftOwner = makeAddr("nftOwner");
        vm.prank(nftOwner);
        basicNft.setApprovalForAll(operator, true);

        // fire
        bool isApprovedForAll = basicNft.isApprovedForAll(nftOwner, operator);
        assertTrue(isApprovedForAll, "isApprovedForAll should be true");
    }

    function test_isApprovedForAll_whenOperatorIsNotApproved_itReturnsFalse()
        public
    {
        // setup
        address operator = makeAddr("operator");
        address nftOwner = makeAddr("nftOwner");
        vm.prank(nftOwner);
        basicNft.setApprovalForAll(operator, false);

        // fire
        bool isApprovedForAll = basicNft.isApprovedForAll(nftOwner, operator);
        assertFalse(isApprovedForAll, "isApprovedForAll should be false");
    }

    function test_isApprovedForAll_whenOperatorIsNotApprovedNeitherApproved_itReturnsFalse()
        public
    {
        // setup
        address operator = makeAddr("operator");
        address nftOwner = makeAddr("nftOwner");

        // fire
        bool isApprovedForAll = basicNft.isApprovedForAll(nftOwner, operator);
        assertFalse(isApprovedForAll, "isApprovedForAll should be false");
    }
    // --------------------------------

    // --------------------------------
    // Test supportsInterface()

    // 0x01ffc9a7 is the ERC165 interface id
    function test_supportsInterface_when0x01ffc9a7_itReturnsTrue() public view {
        // fire
        assertTrue(
            basicNft.supportsInterface(0x01ffc9a7),
            "contract does not support 'supportsInterface(bytes4)'"
        );
        assertTrue(
            basicNft.supportsInterface(type(IERC165).interfaceId),
            "contract does not support 'supportsInterface(bytes4)'"
        );
    }

    function test_supportsInterface_when0xffffffff_itReturnsFalse()
        public
        view
    {
        // fire
        assertFalse(
            basicNft.supportsInterface(0xffffffff),
            "contract should not support '0xffffffff'"
        );
    }

    // 0x80ac58cd is the ERC721 interface id
    function test_supportsInterface_when0x80ac58cd_itReturnsTrue() public view {
        // fire
        assertTrue(
            basicNft.supportsInterface(0x80ac58cd),
            "contract should support '0x80ac58cd' which is the ERC721 interface"
        );
        assertTrue(
            basicNft.supportsInterface(type(IERC721).interfaceId),
            "contract should support '0x80ac58cd' which is the ERC721 interface"
        );
    }

    // 0x5b5e139f is the ERC721Metadata interface id
    function test_supportsInterface_when0x5b5e139f_itReturnsTrue() public view {
        // fire
        assertTrue(
            basicNft.supportsInterface(0x5b5e139f),
            "contract should support '0x5b5e139f' which is the ERC721Metadata interface"
        );
        assertTrue(
            basicNft.supportsInterface(type(IERC721Metadata).interfaceId),
            "contract should support '0x5b5e139f' which is the ERC721Metadata interface"
        );
    }

    // ------------------------------

    // --------------------------------
    // Test name()

    function test_name_returnsCorrectName() public view {
        // fire
        string memory name = basicNft.name();

        assertEq(
            name,
            "Generic NFT Collection",
            "name should be 'Generic NFT Collection' but it is not"
        );
    }

    // -------------------------------------
    // Test symbol()

    function test_symbol_returnsCorrectSymbol() public view {
        // fire
        string memory symbol = basicNft.symbol();

        assertEq(symbol, "GNFTC", "symbol should be 'GNFTC' but it isn't");
    }

    // -------------------------------------
    // Test tokenURI()

    // --------------------------------
}

contract SmartContract {
    bool s_called;
    address s_from;
    address s_operator;
    uint256 s_tokenId;
    bytes s_data;

    constructor() {
        s_called = false;
        s_operator = address(0);
        s_tokenId = 0;
    }

    function onERC721Received(
        address _operator,
        address _from,
        uint256 _tokenId,
        bytes memory _data
    ) external returns (bytes4) {
        s_called = true;
        s_from = _from;
        s_operator = _operator;
        s_tokenId = _tokenId;
        s_data = _data;
        return
            bytes4(
                keccak256("onERC721Received(address,address,uint256,bytes)")
            );
    }

    function called() external view returns (bool) {
        return s_called;
    }

    function from() external view returns (address) {
        return s_from;
    }

    function operator() external view returns (address) {
        return s_operator;
    }

    function tokenId() external view returns (uint256) {
        return s_tokenId;
    }

    function data() external view returns (bytes memory) {
        return s_data;
    }
}

contract InvalidSmartContract {}

contract InvalidSmartContractWrongData {
    bool s_called;

    constructor() {
        s_called = false;
    }

    function onERC721Received(
        address,
        address,
        uint256,
        bytes memory
    ) external returns (bytes4) {
        s_called = true;
        return 0xeeafbddc;
    }

    function called() external view returns (bool) {
        return s_called;
    }
}
