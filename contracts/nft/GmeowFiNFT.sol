// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Pausable.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Burnable.sol";
import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";

contract GmeowFiNFT is ERC721, ERC721Enumerable, ERC721Pausable, AccessControl {
    using EnumerableSet for EnumerableSet.AddressSet;
    using EnumerableSet for EnumerableSet.UintSet;
    bytes32 public constant PAUSER_ROLE = keccak256("PAUSER_ROLE");
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");
    uint256 private _nextTokenId;
    string private _baseTokenURI;
    uint256 private _maxSupply;

    EnumerableSet.AddressSet private holders;
    mapping(address => Holder) private holderTokens;

    error ExceedMaxSupply();

    struct Holder {
        address holder;
        EnumerableSet.UintSet tokens;
    }

    struct HolderRes {
        address holder;
        uint256[] tokens;
    }

    struct Snapshot {
        uint256 timestamp;
        uint256 blockNumber;
        HolderRes[] holders;
    }

    constructor(
        string memory baseTokenURI,
        uint256 maxSupply_
    ) ERC721("MC-NFT", "Meow Chronicles Non-Fungible Token") {
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _grantRole(PAUSER_ROLE, msg.sender);
        _grantRole(MINTER_ROLE, msg.sender);
        _baseTokenURI = baseTokenURI;
        _maxSupply = maxSupply_;
    }

    function _baseURI() internal view override returns (string memory) {
        return _baseTokenURI;
    }

    function pause() public onlyRole(PAUSER_ROLE) {
        _pause();
    }

    function unpause() public onlyRole(PAUSER_ROLE) {
        _unpause();
    }

    function safeMint(address to) public onlyRole(MINTER_ROLE) {
        uint256 tokenId = _nextTokenId++;
        if (totalSupply() >= _maxSupply) {
            revert ExceedMaxSupply();
        }
        _safeMint(to, tokenId);
    }

    function setUri(string memory uri) public onlyRole(DEFAULT_ADMIN_ROLE) {
        _baseTokenURI = uri;
    }

    function snapshot() public view returns (Snapshot memory) {
        return
            Snapshot({
                timestamp: block.timestamp,
                blockNumber: block.number,
                holders: getHolders(0, holders.length())
            });
    }

    function tokenURI(uint256) public view override returns (string memory) {
        return _baseURI();
    }

    // The following functions are overrides required by Solidity.

    function _update(
        address to,
        uint256 tokenId,
        address auth
    )
        internal
        override(ERC721, ERC721Enumerable, ERC721Pausable)
        returns (address)
    {
        address from = super._update(to, tokenId, auth);
        if (from != address(0)) {
            holderTokens[from].tokens.remove(tokenId);
            if (holderTokens[from].tokens.length() == 0) {
                holders.remove(from);
            }
        }
        holders.add(to);
        holderTokens[to].holder = to;
        holderTokens[to].tokens.add(tokenId);

        return from;
    }

    function maxSupply() public view returns (uint256) {
        return _maxSupply;
    }

    function getHolders(
        uint256 offset,
        uint256 limit
    ) public view returns (HolderRes[] memory) {
        uint256 length = limit;
        if (length > holders.length() - offset) {
            length = holders.length() - offset;
        }
        HolderRes[] memory result = new HolderRes[](length);
        for (uint256 i = 0; i < length; i++) {
            address holder = holders.at(offset + i);
            result[i].holder = holder;
            result[i].tokens = holderTokens[holder].tokens.values();
        }
        return result;
    }

    function getHolder(address holder) public view returns (HolderRes memory) {
        return
            HolderRes({
                holder: holder,
                tokens: holderTokens[holder].tokens.values()
            });
    }

    function getHoldersLength() public view returns (uint256) {
        return holders.length();
    }

    function _increaseBalance(
        address account,
        uint128 value
    ) internal override(ERC721, ERC721Enumerable) {
        super._increaseBalance(account, value);
    }

    function supportsInterface(
        bytes4 interfaceId
    )
        public
        view
        override(ERC721, ERC721Enumerable, AccessControl)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }
}
