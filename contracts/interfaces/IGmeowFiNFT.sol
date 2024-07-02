/// SPDX-License-Identifier: MIT
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";

interface IGmeowFiNFT is IERC721 {
    function safeMint(address to) external;
}
