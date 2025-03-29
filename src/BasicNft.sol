// SPDX-License-Identifier: MIT
pragma solidity 0.8.27;

import {ERC721} from "@openzeppelin/contracts/token/ERC721/ERC721.sol";

contract BasicNft {
    //is ERC721 {
    uint256 private s_tokenCounter;
    address private s_owner;
    uint256 private s_firstFreeTokenId;

    mapping(address _nftOwner => uint256 _nftOwnerBalance) private s_balances;
    mapping(uint256 _tokenId => address _nftOwner) private s_tokens;

    event Transfer(
        address indexed _from,
        address indexed _to,
        uint256 indexed _tokenId
    );

    error OnlyOwnerCanMint(address _caller);
    error AddressZeroNotAllowedToOwnNft();

    constructor() {
        s_owner = msg.sender;
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

        uint256 l_tokenId = s_firstFreeTokenId;

        s_tokens[l_tokenId] = _to;

        s_balances[_to]++;

        s_firstFreeTokenId++;

        emit Transfer(address(0), _to, l_tokenId);
    }

    function balanceOf(address _nftOwner) external view returns (uint256) {
        if (_nftOwner == address(0)) {
            revert AddressZeroNotAllowedToOwnNft();
        }

        return s_balances[_nftOwner];
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
