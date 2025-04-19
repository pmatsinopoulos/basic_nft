// SPDX-License-Identifier: MIT

pragma solidity 0.8.27;

// import {ERC721} from "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import {Strings} from "@openzeppelin/contracts/utils/Strings.sol";
import {IERC721} from "./IERC721.sol";
import {IERC165} from "./IERC165.sol";
import {IERC721Metadata} from "./IERC721Metadata.sol";

contract BasicNft is IERC721, IERC165 {
    struct NftMetadata {
        string name;
        string description;
        string imageUri;
    }

    uint256 private s_tokenCounter;
    address private s_owner;
    uint256 private s_firstFreeTokenId;
    bool private s_allNftsMinted;

    mapping(address _nftOwner => uint256 _nftOwnerBalance) private s_balances;
    mapping(uint256 _tokenId => address _nftOwner) private s_owners;
    mapping(address _nftOwner => mapping(address _operator => bool _approvedFlag))
        private s_approvalsForAll;
    mapping(uint256 _tokenId => address _approvedAddress)
        private s_tokenToApprovedAddress;
    mapping(uint256 _tokenId => NftMetadata _nftMetadata) private s_nftMetadata;

    bytes4 internal constant SAFE_TRANSFER_FROM_SMART_CONTRACT_RETURN_VALUE =
        bytes4(keccak256("onERC721Received(address,address,uint256,bytes)"));

    // ---------------------------
    // ERRORS
    // ---------------------------

    error OnlyOwnerCanMint(address _caller);

    error OnlyOwnerCanSetFirstFreeTokenId(address _caller);

    error OnlyOwnerCanSetAllNftsMintedValue(address _caller);

    error AddressZeroNotAllowedToOwnNft();

    error NoMoreNftsLeftToMint();

    error TokenGivenIsNotOwned(uint256 _tokenId);

    error SenderNotOwnerNorAuthorizedOperatorNorApprovedAddress(
        address _sender,
        address _from,
        address _to,
        uint256 _tokenId
    );

    error ApprovalSenderNotOwnerNorAuthorizedOperatorNorApprovedAddress(
        address _notNftOwner,
        address _nftOwner,
        uint256 _tokenId
    );

    error TransferToAddressZeroNotAllowed();

    error InvalidNft(uint256 _tokenId);

    error NftIsNotOwnedByGivenAddress(
        address _currentOwner,
        address _from,
        uint256 _tokenId
    );

    error TransferToSmartContractFailed(address _to);

    error TransferToSmartContractWrongDataReturned(
        address _to,
        bytes4 _returnedValue
    );

    constructor() {
        s_owner = msg.sender;
        s_allNftsMinted = false;
    }

    ////////////////////////////////
    //                            //
    //          external          //
    //                            //
    ////////////////////////////////

    function name() external pure returns (string memory) {
        return "Generic NFT Collection";
    }

    function tokenName(uint256 _tokenId) external view returns (string memory) {
        return s_nftMetadata[_tokenId].name;
    }

    function tokenDescription(
        uint256 _tokenId
    ) external view returns (string memory) {
        return s_nftMetadata[_tokenId].description;
    }

    function tokenImageUri(
        uint256 _tokenId
    ) external view returns (string memory) {
        return s_nftMetadata[_tokenId].imageUri;
    }

    function tokenMetadata(
        uint256 _tokenId
    ) external view returns (NftMetadata memory) {
        return s_nftMetadata[_tokenId];
    }

    function tokenURI(uint256 _tokenId) external pure returns (string memory) {
        return
            string(
                abi.encodePacked(
                    "https://www.basicnftcollection.net/nfts/",
                    Strings.toString(_tokenId),
                    "/metadata"
                )
            );
    }

    function symbol() external pure returns (string memory) {
        return "GNFTC";
    }

    function mintNft(address _to) external {
        _mintNft(_to);
    }

    function mintNft(
        address _to,
        string calldata _name,
        string calldata _description,
        string calldata _imageUri
    ) external {
        uint256 tokenId = _mintNft(_to);
        s_nftMetadata[tokenId] = NftMetadata(_name, _description, _imageUri);
    }

    function setFirstFreeTokenId(uint256 _firstFreeTokenId) external {
        if (msg.sender != s_owner) {
            revert OnlyOwnerCanSetFirstFreeTokenId({_caller: msg.sender});
        }

        s_firstFreeTokenId = _firstFreeTokenId;
    }

    function setAllNftsMinted(bool _allNftsMinted) external {
        if (msg.sender != s_owner) {
            revert OnlyOwnerCanSetAllNftsMintedValue({_caller: msg.sender});
        }

        s_allNftsMinted = _allNftsMinted;
    }

    function balanceOf(address _nftOwner) external view returns (uint256) {
        if (_nftOwner == address(0)) {
            revert AddressZeroNotAllowedToOwnNft();
        }

        return s_balances[_nftOwner];
    }

    function ownerOf(uint256 _tokenId) external view returns (address) {
        if (s_owners[_tokenId] == address(0)) {
            revert TokenGivenIsNotOwned(_tokenId);
        }
        return s_owners[_tokenId];
    }

    function safeTransferFrom(
        address _from,
        address _to,
        uint256 _tokenId
    ) external payable {
        safeTransferFrom(_from, _to, _tokenId, "");
    }

    function safeTransferFrom(
        address _from,
        address _to,
        uint256 _tokenId,
        bytes memory data
    ) public payable {
        _transferFrom(_from, _to, _tokenId);

        if (_isContract(_to)) {
            (bool success, bytes memory returnData) = _to.call(
                abi.encodeWithSignature(
                    "onERC721Received(address,address,uint256,bytes)",
                    msg.sender,
                    _from,
                    _tokenId,
                    data
                )
            );

            if (!success) {
                revert TransferToSmartContractFailed(_to);
            }

            bytes4 returnedValue = abi.decode(returnData, (bytes4));
            if (
                returnedValue != SAFE_TRANSFER_FROM_SMART_CONTRACT_RETURN_VALUE
            ) {
                revert TransferToSmartContractWrongDataReturned(
                    _to,
                    returnedValue
                );
            }
        }

        emit Transfer(_from, _to, _tokenId);
    }

    function transferFrom(
        address _from,
        address _to,
        uint256 _tokenId
    ) external payable {
        _transferFrom(_from, _to, _tokenId);

        emit Transfer(_from, _to, _tokenId);
    }

    function setApprovalForAll(address _operator, bool _approved) external {
        s_approvalsForAll[msg.sender][_operator] = _approved;
        emit ApprovalForAll(msg.sender, _operator, _approved);
    }

    function approve(address _approved, uint256 _tokenId) external {
        address currentOwner = s_owners[_tokenId];
        bool authorizedOperator = s_approvalsForAll[currentOwner][msg.sender] ==
            true;

        if (msg.sender != currentOwner && !authorizedOperator) {
            revert ApprovalSenderNotOwnerNorAuthorizedOperatorNorApprovedAddress(
                msg.sender,
                currentOwner,
                _tokenId
            );
        }

        s_tokenToApprovedAddress[_tokenId] = _approved;
        emit Approval(currentOwner, _approved, _tokenId);
    }

    function getApproved(uint256 _tokenId) external view returns (address) {
        if (_tokenId >= s_firstFreeTokenId) {
            revert InvalidNft(_tokenId);
        }

        return s_tokenToApprovedAddress[_tokenId];
    }

    function isApprovedForAll(
        address _owner,
        address _operator
    ) external view returns (bool) {
        return s_approvalsForAll[_owner][_operator];
    }

    // function mintNft() public {}

    // function tokenURI(
    //     uint256 tokenId
    // ) public view override returns (string memory) {
    //     _requireOwned(tokenId);
    // }

    function supportsInterface(
        bytes4 interfaceID
    ) external pure returns (bool) {
        return
            (interfaceID == type(IERC721).interfaceId ||
                interfaceID == type(IERC165).interfaceId) ||
            interfaceID == type(IERC721Metadata).interfaceId;
    }

    ////////////////////////////////
    //                            //
    //          internal          //
    //                            //
    ////////////////////////////////

    // function _baseURI() internal view virtual returns (string memory) {
    // return "https://foo.bar.com/nfts/dogie/";
    // }

    function _mintNft(address _to) internal returns (uint256) {
        if (msg.sender != s_owner) {
            revert OnlyOwnerCanMint({_caller: msg.sender});
        }

        if (s_allNftsMinted) {
            revert NoMoreNftsLeftToMint();
        }

        uint256 tokenId = s_firstFreeTokenId;

        s_owners[tokenId] = _to;

        s_balances[_to]++;

        if (s_firstFreeTokenId == type(uint256).max) {
            s_allNftsMinted = true;
        } else {
            s_firstFreeTokenId++;
        }

        emit Transfer(address(0), _to, tokenId);

        return tokenId;
    }

    function _isContract(address _addr) internal view returns (bool) {
        uint256 size;
        assembly {
            size := extcodesize(_addr)
        }
        return size > 0;
    }

    function _transferFrom(
        address _from,
        address _to,
        uint256 _tokenId
    ) internal {
        if (_to == address(0)) {
            revert TransferToAddressZeroNotAllowed();
        }

        if (_tokenId >= s_firstFreeTokenId) {
            revert InvalidNft(_tokenId);
        }

        address currentOwner = s_owners[_tokenId];

        if (currentOwner != _from) {
            revert NftIsNotOwnedByGivenAddress(currentOwner, _from, _tokenId);
        }

        bool authorizedOperator = s_approvalsForAll[currentOwner][msg.sender] ==
            true;
        bool approvedAddress = s_tokenToApprovedAddress[_tokenId] == msg.sender;

        if (
            msg.sender != currentOwner &&
            !authorizedOperator &&
            !approvedAddress
        ) {
            revert SenderNotOwnerNorAuthorizedOperatorNorApprovedAddress(
                msg.sender,
                _from,
                _to,
                _tokenId
            );
        }

        s_owners[_tokenId] = _to;
        s_balances[_from]--;
        s_balances[_to]++;
    }
}
