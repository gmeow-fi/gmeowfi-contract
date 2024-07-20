// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/utils/Pausable.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import "@openzeppelin/contracts/utils/cryptography/MessageHashUtils.sol";
import "@openzeppelin/contracts/utils/cryptography/SignatureChecker.sol";
import "../interfaces/IGmeowFiNFT.sol";

contract GMeowFiNFTMinter is Pausable, AccessControl {
    using ECDSA for bytes32;
    using MessageHashUtils for bytes32;

    bytes32 public constant PAUSER_ROLE = keccak256("PAUSER_ROLE");

    mapping(address => bool) public signers;
    address public gmeowFiNFT;

    mapping(uint256 => bool) public usedNonces;
    mapping(address => uint256) public mintedCount;

    error SignatureExpired();
    error NonceAlreadyUsed();
    error InvalidSignature();

    event MintWithSignature(
        address indexed to,
        uint256 nonce,
        uint256 expiredAt
    );

    constructor(address _signer, address _gmeowFiNFT) {
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _grantRole(PAUSER_ROLE, msg.sender);
        gmeowFiNFT = _gmeowFiNFT;
        signers[_signer] = true;
    }

    function mintWithSignature(
        address to,
        uint256 nonce,
        uint256 expiredAt,
        bytes memory signature
    ) public whenNotPaused {
        if (block.timestamp > expiredAt) {
            revert SignatureExpired();
        }
        if (usedNonces[nonce]) {
            revert NonceAlreadyUsed();
        }
        usedNonces[nonce] = true;

        bytes32 message = keccak256(
            abi.encodePacked(address(this), to, nonce, expiredAt)
        );
        bytes32 hash = message.toEthSignedMessageHash();
        address recoveredAddress = hash.recover(signature);

        if (!signers[recoveredAddress]) {
            revert InvalidSignature();
        }
        mintedCount[to] += 1;
        IGmeowFiNFT(gmeowFiNFT).safeMint(to);
    }

    function batchMintBySignature(
        address to,
        uint256 nonce,
        uint256 amount,
        uint256 expiredAt,
        bytes memory signature
    ) public whenNotPaused {
        if (block.timestamp > expiredAt) {
            revert SignatureExpired();
        }
        if (usedNonces[nonce]) {
            revert NonceAlreadyUsed();
        }
        usedNonces[nonce] = true;

        bytes32 message = keccak256(
            abi.encodePacked(address(this), to, nonce, amount, expiredAt)
        );
        bytes32 hash = message.toEthSignedMessageHash();
        address recoveredAddress = hash.recover(signature);

        if (!signers[recoveredAddress]) {
            revert InvalidSignature();
        }
        mintedCount[to] += amount;
        for (uint256 i = 0; i < amount; i++) {
            IGmeowFiNFT(gmeowFiNFT).safeMint(to);
        }
    }

    function airdrop(
        address[] memory tos,
        uint256[] memory amounts
    ) external onlyRole(DEFAULT_ADMIN_ROLE) {
        require(tos.length == amounts.length, "Invalid input");
        for (uint256 i = 0; i < tos.length; i++) {
            mintedCount[tos[i]] += amounts[i];
            for (uint256 j = 0; j < amounts[i]; j++) {
                IGmeowFiNFT(gmeowFiNFT).safeMint(tos[i]);
            }
        }
    }

    function setSigner(
        address _signer,
        bool _isSigner
    ) public onlyRole(DEFAULT_ADMIN_ROLE) {
        signers[_signer] = _isSigner;
    }

    function setGmeowFiNFT(
        address _gmeowFiNFT
    ) public onlyRole(DEFAULT_ADMIN_ROLE) {
        gmeowFiNFT = _gmeowFiNFT;
    }

    function pause() public onlyRole(PAUSER_ROLE) {
        _pause();
    }

    function unpause() public onlyRole(PAUSER_ROLE) {
        _unpause();
    }
}
