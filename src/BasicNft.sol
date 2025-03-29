// SPDX-License-Identifier: MIT
pragma solidity 0.8.27;

import {ERC721} from "@openzeppelin/contracts/token/ERC721/ERC721.sol";

contract BasicNft {
    //is ERC721 {
    uint256 private s_tokenCounter;
    address private s_owner;
    uint256 private s_firstFreeTokenId;
    bool private s_allNftsMinted;

    mapping(address _nftOwner => uint256 _nftOwnerBalance) private s_balances;
    mapping(uint256 _tokenId => address _nftOwner) private s_owners;

    event Transfer(
        address indexed _from,
        address indexed _to,
        uint256 indexed _tokenId
    );

    error OnlyOwnerCanMint(address _caller);
    error OnlyOwnerCanSetFirstFreeTokenId(address _caller);
    error OnlyOwnerCanSetAllNftsMintedValue(address _caller);
    error AddressZeroNotAllowedToOwnNft();
    error NoMoreNftsLeftToMint();
    error TokenGivenIsNotOwned(uint256 _tokenId);

    constructor() {
        s_owner = msg.sender;
        s_allNftsMinted = false;
    }

    ////////////////////////////////
    //                            //
    //          external          //
    //                            //
    ////////////////////////////////

    function mintNft(address _to) external {
        if (msg.sender != s_owner) {
            revert OnlyOwnerCanMint({_caller: msg.sender});
        }

        if (s_allNftsMinted) {
            revert NoMoreNftsLeftToMint();
        }

        uint256 l_tokenId = s_firstFreeTokenId;

        s_owners[l_tokenId] = _to;

        s_balances[_to]++;

        if (s_firstFreeTokenId == type(uint256).max) {
            s_allNftsMinted = true;
        } else {
            s_firstFreeTokenId++;
        }

        emit Transfer(address(0), _to, l_tokenId);
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

    // function mintNft() public {}

    // function tokenURI(
    //     uint256 tokenId
    // ) public view override returns (string memory) {
    //     _requireOwned(tokenId);
    // }

    ////////////////////////////////
    //                            //
    //          internal          //
    //                            //
    ////////////////////////////////

    // function _baseURI() internal view virtual returns (string memory) {
    // return "https://foo.bar.com/nfts/dogie/";
    // }
}
