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
        emit BasicNft.Transfer(peter, panos, tokenId);
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
        emit BasicNft.Transfer(peter, panos, 0);

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
        emit BasicNft.Transfer(peter, panos, 0);
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
        emit BasicNft.Transfer(peter, panos, tokenId);
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
        emit BasicNft.Transfer(peter, panos, 0);

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
        emit BasicNft.Transfer(peter, panos, 0);
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
        emit BasicNft.Transfer(peter, panos, tokenId);
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
        emit BasicNft.Transfer(peter, panos, 0);

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
        emit BasicNft.Transfer(peter, panos, 0);
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
        emit BasicNft.Approval(peter, approvedAddress, tokenId);
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
        emit BasicNft.Approval(peter, panos, 0);

        vm.prank(authorizedOperator);
        basicNft.approve(panos, 0);
    }

    function test_approve_whenMsgSenderIsAnApprovedAddress_approvesAndEmitsEvent()
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
        emit BasicNft.Approval(peter, panos, 0);
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
        emit BasicNft.Approval(peter, address(0), tokenId);
        vm.prank(peter);
        basicNft.approve(address(0), tokenId);

        address approvedAddress = basicNft.getApproved(1);
        assertEq(approvedAddress, address(0), "approvedAddress is not correct");
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
        emit BasicNft.ApprovalForAll(nftOwner, operator, true);
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
        emit BasicNft.ApprovalForAll(nftOwner, operator, false);
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
