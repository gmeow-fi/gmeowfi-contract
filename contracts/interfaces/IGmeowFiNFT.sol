/// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/IERC721Enumerable.sol";

interface IGmeowFiNFT is IERC721, IERC721Enumerable {
    function safeMint(address to) external;
    function burn(uint256 tokenId) external;
}
