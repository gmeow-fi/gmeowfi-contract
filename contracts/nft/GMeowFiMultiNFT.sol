// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/token/ERC1155/extensions/ERC1155Pausable.sol";
import "@openzeppelin/contracts/token/ERC1155/extensions/ERC1155Burnable.sol";
import "@openzeppelin/contracts/token/ERC1155/extensions/ERC1155Supply.sol";

contract GMeowFiMultiNFT is
    ERC1155,
    AccessControl,
    ERC1155Pausable,
    ERC1155Burnable,
    ERC1155Supply
{
    bytes32 public constant PAUSER_ROLE = keccak256("PAUSER_ROLE");
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");

    string public name = "GMeowFi Multi Non-Fungible Token";
    string public symbol = "GM-MNFT";

    mapping(uint256 => string) public nftNames;
    mapping(uint256 => string) public nftSymbols;
    mapping(uint256 => string) public nftURIs;
    mapping(uint256 => uint256) public hardCaps;

    constructor() ERC1155("") {
        _grantRole(DEFAULT_ADMIN_ROLE, _msgSender());
        _grantRole(PAUSER_ROLE, _msgSender());
        _grantRole(MINTER_ROLE, _msgSender());
    }

    function setNFT(
        uint256 id,
        string memory _name,
        string memory _symbol,
        string memory _uri,
        uint256 _hardCaps
    ) public onlyRole(DEFAULT_ADMIN_ROLE) {
        nftNames[id] = _name;
        nftSymbols[id] = _symbol;
        nftURIs[id] = _uri;
        hardCaps[id] = _hardCaps;
    }

    function pause() public onlyRole(PAUSER_ROLE) {
        _pause();
    }

    function unpause() public onlyRole(PAUSER_ROLE) {
        _unpause();
    }

    function mint(
        address account,
        uint256 id,
        uint256 amount,
        bytes memory data
    ) public onlyRole(MINTER_ROLE) {
        _mint(account, id, amount, data);
    }

    function mintBatch(
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) public onlyRole(MINTER_ROLE) {
        _mintBatch(to, ids, amounts, data);
    }

    function mintBySystem(
        address[] memory accounts,
        uint256 id,
        uint256[] memory amounts,
        bytes memory data
    ) public onlyRole(MINTER_ROLE) {
        for (uint256 i = 0; i < accounts.length; i++) {
            mint(accounts[i], id, amounts[i], data);
        }
    }

    // The following functions are overrides required by Solidity.

    function _update(
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory values
    ) internal override(ERC1155, ERC1155Supply, ERC1155Pausable) {
        super._update(from, to, ids, values);
        for (uint256 i = 0; i < ids.length; i++) {
            require(
                hardCaps[ids[i]] >= totalSupply(ids[i]),
                "Hard cap reached"
            );
        }
    }

    function uri(
        uint256 id
    ) public view override(ERC1155) returns (string memory) {
        return nftURIs[id];
    }

    function supportsInterface(
        bytes4 interfaceId
    ) public view override(ERC1155, AccessControl) returns (bool) {
        return super.supportsInterface(interfaceId);
    }
}
