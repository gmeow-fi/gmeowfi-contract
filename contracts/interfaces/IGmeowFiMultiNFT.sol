pragma solidity ^0.8.20;
import "@openzeppelin/contracts/token/ERC1155/IERC1155.sol";

interface IGmeowFiMultiNFT is IERC1155 {
    function mint(
        address account,
        uint256 id,
        uint256 amount,
        bytes memory data
    ) external;

    function mintBatch(
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) external;

    function burn(address account, uint256 id, uint256 amount) external;

    function burnBatch(
        address account,
        uint256[] memory ids,
        uint256[] memory amounts
    ) external;

    function hardCaps(uint256 id) external view returns (uint256);
    function totalSupply(uint256 id) external view returns (uint256);
}
