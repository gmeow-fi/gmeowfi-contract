// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/utils/Pausable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@pythnetwork/entropy-sdk-solidity/IEntropy.sol";
import "@pythnetwork/entropy-sdk-solidity/IEntropyConsumer.sol";
import "@pythnetwork/pyth-sdk-solidity/IPyth.sol";
import "@pythnetwork/pyth-sdk-solidity/PythStructs.sol";

contract GMeowFiEntropy is Pausable, Ownable, IEntropy {
    IPyth pyth;
    bytes32 priceId;
    uint64 requestSequenceNumber;
    bytes32 lastRandomness = keccak256("GMeowFiEntropy");
    mapping(address => bool) whitelist;

    constructor(IPyth _pyth, bytes32 _priceId) Ownable(msg.sender) {
        pyth = _pyth;
        priceId = _priceId;
    }

    function requestWithCallback(
        address,
        bytes32
    ) external payable returns (uint64 assignedSequenceNumber) {
        require(
            whitelist[msg.sender],
            "GMeowFiEntropy: sender not whitelisted"
        );
        requestSequenceNumber++;
        return requestSequenceNumber;
    }

    function revealWithCallback(
        address provider,
        uint64 sequenceNumber,
        bytes32 userRandomNumber,
        bytes32 providerRevelation
    ) external {
        require(
            whitelist[msg.sender],
            "GMeowFiEntropy: sender not whitelisted"
        );
        PythStructs.Price memory price;
        if (address(pyth) != address(0)) {
            price = pyth.getPriceUnsafe(priceId);
        }
        bytes32 combinedRandomness = keccak256(
            abi.encode(
                lastRandomness,
                sequenceNumber,
                userRandomNumber,
                providerRevelation,
                price,
                blockhash(block.number - 1),
                gasleft()
            )
        );
        lastRandomness = combinedRandomness;
        IEntropyConsumer(msg.sender)._entropyCallback(
            sequenceNumber,
            provider,
            combinedRandomness
        );
    }

    function setPriceId(bytes32 _priceId) external onlyOwner {
        priceId = _priceId;
    }

    function setPyth(IPyth _pyth) external onlyOwner {
        pyth = _pyth;
    }

    function setWhitelist(address user, bool status) external onlyOwner {
        whitelist[user] = status;
    }

    // Register msg.sender as a randomness provider. The arguments are the provider's configuration parameters
    // and initial commitment. Re-registering the same provider rotates the provider's commitment (and updates
    // the feeInWei).
    //
    // chainLength is the number of values in the hash chain *including* the commitment, that is, chainLength >= 1.
    function register(
        uint128 feeInWei,
        bytes32 commitment,
        bytes calldata commitmentMetadata,
        uint64 chainLength,
        bytes calldata uri
    ) external {}

    function withdraw(uint128 amount) external {}

    function request(
        address provider,
        bytes32 userCommitment,
        bool useBlockHash
    ) external payable returns (uint64 assignedSequenceNumber) {}

    function reveal(
        address provider,
        uint64 sequenceNumber,
        bytes32 userRevelation,
        bytes32 providerRevelation
    ) external returns (bytes32 randomNumber) {}

    function getProviderInfo(
        address provider
    ) external view returns (EntropyStructs.ProviderInfo memory info) {}

    function getDefaultProvider() external view returns (address provider) {}

    function getRequest(
        address provider,
        uint64 sequenceNumber
    ) external view returns (EntropyStructs.Request memory req) {}

    function getFee(
        address provider
    ) external view returns (uint128 feeAmount) {}

    function getAccruedPythFees()
        external
        view
        returns (uint128 accruedPythFeesInWei)
    {}

    function setProviderFee(uint128 newFeeInWei) external {}

    function setProviderUri(bytes calldata newUri) external {}
    function setFeeManager(address manager) external {}
    function withdrawAsFeeManager(address provider, uint128 amount) external {}
    function setProviderFeeAsFeeManager(
        address provider,
        uint128 newFeeInWei
    ) external {}
    function constructUserCommitment(
        bytes32 userRandomness
    ) external pure returns (bytes32 userCommitment) {}

    function combineRandomValues(
        bytes32 userRandomness,
        bytes32 providerRandomness,
        bytes32 blockHash
    ) external pure returns (bytes32 combinedRandomness) {}

    function pause() public onlyOwner {
        _pause();
    }

    function unpause() public onlyOwner {
        _unpause();
    }
}
