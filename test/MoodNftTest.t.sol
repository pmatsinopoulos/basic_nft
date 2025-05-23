// SPDX-License-Identifier: MIT
pragma solidity 0.8.27;

import {Test, console} from "forge-std/Test.sol";

import {MoodNft} from "../src/MoodNft.sol";

import {Base64} from "@openzeppelin/contracts/utils/Base64.sol";

contract MoodNftTest is Test {
    string constant SAD_SVG_IMAGE_URI =
        "data:image/svg+xml;base64,PD94bWwgdmVyc2lvbj0iMS4wIiBlbmNvZGluZz0iaXNvLTg4NTktMSI/Pg0KPCEtLSBVcGxvYWRlZCB0bzogU1ZHIFJlcG8sIHd3dy5zdmdyZXBvLmNvbSwgR2VuZXJhdG9yOiBTVkcgUmVwbyBNaXhlciBUb29scyAtLT4NCjxzdmcgaGVpZ2h0PSI4MDBweCIgd2lkdGg9IjgwMHB4IiB2ZXJzaW9uPSIxLjEiIGlkPSJMYXllcl8xIiB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciIHhtbG5zOnhsaW5rPSJodHRwOi8vd3d3LnczLm9yZy8xOTk5L3hsaW5rIiANCgkgdmlld0JveD0iMCAwIDI5NS45OTYgMjk1Ljk5NiIgeG1sOnNwYWNlPSJwcmVzZXJ2ZSI+DQo8Zz4NCgk8cGF0aCBzdHlsZT0iZmlsbDojRkZDRTAwOyIgZD0iTTI3MC45OTYsMTIzLjk5OGMwLTExLjMzNC0xLjM2My0yMi4zNDgtMy45MDctMzIuOWMtNy4yNjktMTUuMTUyLTE3LjM1LTI4LjcwOC0yOS41NTgtMzkuOTk2DQoJCWMtMjIuMzkxLTEzLjM3Ni00OC43NjYtMjAuNjY2LTc2Ljc3MS0xOS42NDVDODMuNDkyLDM0LjI3MywyMy4xMzksOTkuMTk2LDI1Ljk1NSwxNzYuNDYzYzAuNDEyLDExLjMwNCwyLjE3LDIyLjIzOSw1LjA4NywzMi42NzMNCgkJYzYuMzAzLDEyLjAxLDE0LjM5NywyMi45MzgsMjMuOTM0LDMyLjQyYzIxLjg5MiwxNC4xODksNDcuOTksMjIuNDQsNzYuMDIyLDIyLjQ0QzIwOC4zMTYsMjYzLjk5NiwyNzAuOTk2LDIwMS4zMTYsMjcwLjk5NiwxMjMuOTk4DQoJCXogTTE5Ny40OTcsOTguOTk4YzguODM2LDAsMTYsNy4xNjQsMTYsMTZzLTcuMTY0LDE2LTE2LDE2cy0xNi03LjE2NC0xNi0xNlMxODguNjYxLDk4Ljk5OCwxOTcuNDk3LDk4Ljk5OHogTTk4LjQ5Nyw5OC45OTgNCgkJYzguODM2LDAsMTYsNy4xNjQsMTYsMTZzLTcuMTY0LDE2LTE2LDE2cy0xNi03LjE2NC0xNi0xNlM4OS42NjEsOTguOTk4LDk4LjQ5Nyw5OC45OTh6IE05OC40OTgsMjQ3Ljg5OA0KCQljLTIyLjQ3NSwwLTQwLjc2LTE4LjI4NS00MC43Ni00MC43NmMwLTkuNTI3LDUuOTQ4LTIxLjQzOSwxOC4xODUtMzYuNDE2YzguNDE1LTEwLjMwMSwxNi43MjMtMTguMiwxNy4wNzItMTguNTMybDUuNTAzLTUuMjE2DQoJCWw1LjUwNCw1LjIxN2MwLjM0OSwwLjMzMSw4LjY1NSw4LjIzMSwxNy4wNywxOC41MzFjNC4zMTUsNS4yODIsNy44MzIsMTAuMTc1LDEwLjU5OCwxNC43MjQNCgkJYzExLjUxNC0yLjExMiwyMy40ODItMi4wNjEsMzUuMjQyLDAuMzk3YzIxLjI2Miw0LjQ0Nyw0MC4zNTQsMTYuMzkxLDUzLjc1NiwzMy42MzFsLTEyLjYzMSw5LjgyDQoJCWMtMTEuMDc4LTE0LjI0OS0yNi44NDctMjQuMTE4LTQ0LjQtMjcuNzg5Yy04LjQwNC0xLjc1OC0xNi45MzYtMi4wMTctMjUuMjQ0LTAuOTI4YzAuNTY1LDIuMzAyLDAuODYzLDQuNDkxLDAuODYzLDYuNTYxDQoJCUMxMzkuMjU2LDIyOS42MTMsMTIwLjk3MiwyNDcuODk4LDk4LjQ5OCwyNDcuODk4eiIvPg0KCTxwYXRoIHN0eWxlPSJmaWxsOiNGRkIxMDA7IiBkPSJNMjY3LjA4OSw5MS4wOThjMi41NDQsMTAuNTUzLDMuOTA3LDIxLjU2NiwzLjkwNywzMi45YzAsNzcuMzE4LTYyLjY4LDEzOS45OTgtMTM5Ljk5OCwxMzkuOTk4DQoJCWMtMjguMDMyLDAtNTQuMTMxLTguMjUxLTc2LjAyMi0yMi40NGMyMy44OCwyMy43NDQsNTYuNzY3LDM4LjQ0LDkzLjAyMiwzOC40NGM3Mi43ODQsMCwxMzEuOTk4LTU5LjIxNCwxMzEuOTk4LTEzMS45OTgNCgkJQzI3OS45OTYsMTI3LjYzNiwyNzUuMzU4LDEwOC4zMzcsMjY3LjA4OSw5MS4wOTh6Ii8+DQoJPHBhdGggc3R5bGU9ImZpbGw6I0ZGRTQ1NDsiIGQ9Ik0xNjAuNzYsMzEuNDU3YzI4LjAwNi0xLjAyMSw1NC4zODEsNi4yNjksNzYuNzcxLDE5LjY0NUMyMTMuOTg1LDI5LjMyOCwxODIuNTIxLDE2LDE0Ny45OTgsMTYNCgkJQzc1LjIxNCwxNiwxNiw3NS4yMTQsMTYsMTQ3Ljk5OGMwLDIyLjA0OSw1LjQ0Miw0Mi44NDksMTUuMDQyLDYxLjEzOGMtMi45MTctMTAuNDM0LTQuNjc1LTIxLjM2OS01LjA4Ny0zMi42NzMNCgkJQzIzLjEzOSw5OS4xOTYsODMuNDkyLDM0LjI3MywxNjAuNzYsMzEuNDU3eiIvPg0KCTxwYXRoIGQ9Ik0xNDcuOTk4LDBDNjYuMzkyLDAsMCw2Ni4zOTIsMCwxNDcuOTk4czY2LjM5MiwxNDcuOTk4LDE0Ny45OTgsMTQ3Ljk5OHMxNDcuOTk4LTY2LjM5MiwxNDcuOTk4LTE0Ny45OTgNCgkJUzIyOS42MDUsMCwxNDcuOTk4LDB6IE0xNDcuOTk4LDI3OS45OTZjLTM2LjI1NiwwLTY5LjE0My0xNC42OTYtOTMuMDIyLTM4LjQ0Yy05LjUzNi05LjQ4Mi0xNy42MzEtMjAuNDEtMjMuOTM0LTMyLjQyDQoJCUMyMS40NDIsMTkwLjg0NywxNiwxNzAuMDQ3LDE2LDE0Ny45OThDMTYsNzUuMjE0LDc1LjIxNCwxNiwxNDcuOTk4LDE2YzM0LjUyMywwLDY1Ljk4NywxMy4zMjgsODkuNTMzLDM1LjEwMg0KCQljMTIuMjA4LDExLjI4OCwyMi4yODksMjQuODQ0LDI5LjU1OCwzOS45OTZjOC4yNywxNy4yMzksMTIuOTA3LDM2LjUzOCwxMi45MDcsNTYuOQ0KCQlDMjc5Ljk5NiwyMjAuNzgyLDIyMC43ODIsMjc5Ljk5NiwxNDcuOTk4LDI3OS45OTZ6Ii8+DQoJPGNpcmNsZSBjeD0iOTguNDk3IiBjeT0iMTE0Ljk5OCIgcj0iMTYiLz4NCgk8Y2lyY2xlIGN4PSIxOTcuNDk3IiBjeT0iMTE0Ljk5OCIgcj0iMTYiLz4NCgk8cGF0aCBzdHlsZT0iZmlsbDojMjhFMEZGOyIgZD0iTTk4LjUwMSwxNjkuMjkyYy0xMS42NjIsMTIuMTczLTI0Ljc2MywyOS4xNzQtMjQuNzYzLDM3Ljg0N2MwLDEzLjY1MiwxMS4xMDcsMjQuNzYsMjQuNzYsMjQuNzYNCgkJYzEzLjY1MSwwLDI0Ljc1OC0xMS4xMDcsMjQuNzU4LTI0Ljc2QzEyMy4yNTYsMTk4LjQ0NSwxMTAuMTYsMTgxLjQ1Myw5OC41MDEsMTY5LjI5MnoiLz4NCgk8cGF0aCBkPSJNMTM4LjM5MywyMDAuNTc4YzguMzA5LTEuMDg5LDE2Ljg0LTAuODMsMjUuMjQ0LDAuOTI4YzE3LjU1NCwzLjY3MSwzMy4zMjIsMTMuNTQsNDQuNCwyNy43ODlsMTIuNjMxLTkuODINCgkJYy0xMy40MDItMTcuMjQtMzIuNDk0LTI5LjE4NC01My43NTYtMzMuNjMxYy0xMS43Ni0yLjQ1OC0yMy43MjktMi41MS0zNS4yNDItMC4zOTdjLTIuNzY2LTQuNTQ5LTYuMjgyLTkuNDQxLTEwLjU5OC0xNC43MjQNCgkJYy04LjQxNS0xMC4zLTE2LjcyMi0xOC4yLTE3LjA3LTE4LjUzMWwtNS41MDQtNS4yMTdsLTUuNTAzLDUuMjE2Yy0wLjM1LDAuMzMyLTguNjU3LDguMjMxLTE3LjA3MiwxOC41MzINCgkJYy0xMi4yMzYsMTQuOTc3LTE4LjE4NSwyNi44ODktMTguMTg1LDM2LjQxNmMwLDIyLjQ3NSwxOC4yODUsNDAuNzYsNDAuNzYsNDAuNzZjMjIuNDc0LDAsNDAuNzU4LTE4LjI4NSw0MC43NTgtNDAuNzYNCgkJQzEzOS4yNTYsMjA1LjA2OSwxMzguOTU3LDIwMi44OCwxMzguMzkzLDIwMC41Nzh6IE05OC40OTgsMjMxLjg5OGMtMTMuNjUyLDAtMjQuNzYtMTEuMTA3LTI0Ljc2LTI0Ljc2DQoJCWMwLTguNjczLDEzLjEwMS0yNS42NzQsMjQuNzYzLTM3Ljg0N2MxMS42NTksMTIuMTYxLDI0Ljc1NSwyOS4xNTMsMjQuNzU1LDM3Ljg0N0MxMjMuMjU2LDIyMC43OTEsMTEyLjE0OSwyMzEuODk4LDk4LjQ5OCwyMzEuODk4eg0KCQkiLz4NCjwvZz4NCjwvc3ZnPg==";
    string constant HAPPY_SVG_IMAGE_URI =
        "data:image/svg+xml;base64,PD94bWwgdmVyc2lvbj0iMS4wIiBlbmNvZGluZz0iaXNvLTg4NTktMSI/Pg0KPCEtLSBVcGxvYWRlZCB0bzogU1ZHIFJlcG8sIHd3dy5zdmdyZXBvLmNvbSwgR2VuZXJhdG9yOiBTVkcgUmVwbyBNaXhlciBUb29scyAtLT4NCjxzdmcgaGVpZ2h0PSI4MDBweCIgd2lkdGg9IjgwMHB4IiB2ZXJzaW9uPSIxLjEiIGlkPSJMYXllcl8xIiB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciIHhtbG5zOnhsaW5rPSJodHRwOi8vd3d3LnczLm9yZy8xOTk5L3hsaW5rIiANCgkgdmlld0JveD0iMCAwIDQ3My45MzEgNDczLjkzMSIgeG1sOnNwYWNlPSJwcmVzZXJ2ZSI+DQo8Y2lyY2xlIHN0eWxlPSJmaWxsOiNGRkMxMEU7IiBjeD0iMjM2Ljk2NiIgY3k9IjIzNi45NjYiIHI9IjIzNi45NjYiLz4NCjxnPg0KCTxwYXRoIHN0eWxlPSJmaWxsOiMzMzMzMzM7IiBkPSJNMzgzLjE2NCwyMzcuMTIzYy0xLjMzMiw4MC42OTktNjUuNTE0LDE0NC44NzMtMTQ2LjIxMywxNDYuMjA2DQoJCWMtODAuNzAyLDEuMzMyLTE0NC45MDctNjcuNTItMTQ2LjIwNi0xNDYuMjA2Yy0wLjE5OC0xMi4wNTItMTguOTA3LTEyLjA3MS0xOC43MDksMGMxLjUsOTAuOTIxLDczLjk5MywxNjMuNDE0LDE2NC45MTQsMTY0LjkxNA0KCQljOTAuOTI5LDEuNSwxNjMuNDU1LTc2LjI1LDE2NC45MjItMTY0LjkxNEM0MDIuMDcxLDIyNS4wNTIsMzgzLjM2MiwyMjUuMDcxLDM4My4xNjQsMjM3LjEyM0wzODMuMTY0LDIzNy4xMjN6Ii8+DQoJPGNpcmNsZSBzdHlsZT0iZmlsbDojMzMzMzMzOyIgY3g9IjE2NC45MzciIGN5PSIxNTUuMjI3IiByPSIzNy4yMTYiLz4NCgk8Y2lyY2xlIHN0eWxlPSJmaWxsOiMzMzMzMzM7IiBjeD0iMzA1LjY2NCIgY3k9IjE1NS4yMjciIHI9IjM3LjIxNiIvPg0KPC9nPg0KPC9zdmc+";

    MoodNft s_moodNft;
    address s_moodNftOwner;

    function setUp() public {
        s_moodNftOwner = msg.sender;

        s_moodNft = new MoodNft(SAD_SVG_IMAGE_URI, HAPPY_SVG_IMAGE_URI);
        s_moodNftOwner = s_moodNft.owner();
    }

    function test_tokenURI() public {
        string memory expectedUri = string(
            abi.encodePacked(
                "data:application/json;base64,",
                Base64.encode(
                    bytes(
                        abi.encodePacked(
                            '{"name": "',
                            "MoodNFT",
                            '", "description": "An NFT that reflects the owners mood.", "attributes":',
                            '[{"trait_type":"moodiness", "value": 100}], "image": "',
                            HAPPY_SVG_IMAGE_URI,
                            '"}'
                        )
                    )
                )
            )
        );
        address peter = makeAddr("peter");

        vm.prank(s_moodNftOwner);
        uint256 tokenId = s_moodNft.mint(peter);

        // fire
        string memory uri = s_moodNft.tokenURI(tokenId);

        assertEq(uri, expectedUri);
    }
}
