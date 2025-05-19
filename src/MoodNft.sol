// SPDX-License-Identifier: MIT
pragma solidity 0.8.27;

import {ERC721} from "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {Base64} from "@openzeppelin/contracts/utils/Base64.sol";

contract MoodNft is ERC721, Ownable {
    enum Mood {
        SAD,
        HAPPY
    }

    uint256 private s_nextTokenId;
    mapping(uint256 => Mood) private s_tokenMoods;
    string private s_sadSvgImageUri;
    string private s_happySvgImageUri;

    error MoodNft__CantFlipMoodIfNotOwner();

    constructor(
        string memory _sadSvgImageUri,
        string memory _happySvgImageUri
    ) ERC721("MoodNFT", "MNFT") Ownable(msg.sender) {
        s_sadSvgImageUri = _sadSvgImageUri;
        s_happySvgImageUri = _happySvgImageUri;
    }

    ////////////////////////////////
    //                            //
    //          external          //
    //                            //
    ////////////////////////////////

    function mint(address _to) external onlyOwner returns (uint256) {
        uint256 tokenId = s_nextTokenId++;
        _safeMint(_to, tokenId);
        s_tokenMoods[tokenId] = Mood.HAPPY;
        return tokenId;
    }

    function getNextTokenId() external view returns (uint256) {
        return s_nextTokenId;
    }

    function flipMood(uint256 _tokenId) external {
        address currentOwner = ownerOf(_tokenId);
        if (!_isAuthorized(currentOwner, msg.sender, _tokenId)) {
            revert MoodNft__CantFlipMoodIfNotOwner();
        }

        if (s_tokenMoods[_tokenId] == Mood.SAD) {
            s_tokenMoods[_tokenId] = Mood.HAPPY;
        } else if (s_tokenMoods[_tokenId] == Mood.HAPPY) {
            s_tokenMoods[_tokenId] = Mood.SAD;
        }
    }

    ////////////////////////////////
    //                            //
    //          public            //
    //                            //
    ////////////////////////////////

    function tokenURI(
        uint256 _tokenId
    ) public view override(ERC721) returns (string memory) {
        string memory imageURI = "";
        if (s_tokenMoods[_tokenId] == Mood.HAPPY) {
            imageURI = s_happySvgImageUri;
        } else {
            imageURI = s_sadSvgImageUri;
        }

        return
            string(
                abi.encodePacked(
                    _baseURI(),
                    Base64.encode(
                        bytes(
                            abi.encodePacked(
                                '{"name": "',
                                name(),
                                '", "description": "An NFT that reflects the owners mood.", "attributes":',
                                '[{"trait_type":"moodiness", "value": 100}], "image": "',
                                imageURI,
                                '"}'
                            )
                        )
                    )
                )
            );
    }

    function supportsInterface(
        bytes4 _interfaceId
    ) public view override(ERC721) returns (bool) {
        return super.supportsInterface(_interfaceId);
    }

    ////////////////////////////////
    //                            //
    //          internal          //
    //                            //
    ////////////////////////////////

    function _baseURI() internal pure override returns (string memory) {
        return "data:application/json;base64,";
    }
}
