// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@pythnetwork/entropy-sdk-solidity/IEntropy.sol";
import "@pythnetwork/entropy-sdk-solidity/IEntropyConsumer.sol";
import "../interfaces/IRandomNumberGenerator.sol";
import "../interfaces/ILottery.sol";

contract PythRandomNumberGenerator is
    IEntropyConsumer,
    IRandomNumberGenerator,
    Ownable
{
    using SafeERC20 for IERC20;

    address public lottery;
    bytes32 public keyHash;
    uint64 public latestRequestId;
    uint32 public randomResult;
    uint256 public latestLotteryId;
    IEntropy public entropy;
    address public entropyProvider;

    constructor(
        address _entropy,
        address _entropyProvider
    ) Ownable(msg.sender) {
        entropy = IEntropy(_entropy);
        entropyProvider = _entropyProvider;
    }

    /**
     * @notice Request randomness
     */
    function getRandomNumber() external payable override {
        require(msg.sender == lottery, "Only Lottery");
        require(keyHash != bytes32(0), "Must have valid key hash");

        uint256 fee = getNativeFee();
        require(msg.value >= fee, "Insufficient fee");
        uint64 sequenceNumber = entropy.requestWithCallback{value: fee}(
            entropyProvider,
            keyHash
        );
        latestRequestId = sequenceNumber;
    }

    /**
     * @notice Change the keyHash
     * @param _keyHash: new keyHash
     */
    function setKeyHash(bytes32 _keyHash) external onlyOwner {
        keyHash = _keyHash;
    }

    /**
     * @notice Set the address for the Lottery
     * @param _lottery: address of the Lottery
     */
    function setLotteryAddress(address _lottery) external onlyOwner {
        lottery = _lottery;
    }

    /**
     * @notice It allows the admin to withdraw tokens sent to the contract
     * @param _tokenAddress: the address of the token to withdraw
     * @param _tokenAmount: the number of token amount to withdraw
     * @dev Only callable by owner.
     */
    function withdrawTokens(
        address _tokenAddress,
        uint256 _tokenAmount
    ) external onlyOwner {
        IERC20(_tokenAddress).safeTransfer(address(msg.sender), _tokenAmount);
    }

    /**
     * @notice View latestLotteryId
     */
    function viewLatestLotteryId() external view override returns (uint256) {
        return latestLotteryId;
    }

    /**
     * @notice View random result
     */
    function viewRandomResult() external view override returns (uint32) {
        return randomResult;
    }

    function entropyCallback(
        uint64 _latestRequestId,
        // If your app uses multiple providers, you can use this argument
        // to distinguish which one is calling the app back. This app only
        // uses one provider so this argument is not used.
        address,
        bytes32 randomNumber
    ) internal override {
        require(latestRequestId == _latestRequestId, "Wrong requestId");
        // Do something with the random number
        randomResult = uint32(1000000 + (uint256(randomNumber) % 1000000));
        latestLotteryId = ILottery(lottery).viewCurrentLotteryId();
    }

    // This method is required by the IEntropyConsumer interface.
    // It returns the address of the entropy contract which will call the callback.
    function getEntropy() internal view override returns (address) {
        return address(entropy);
    }

    function getNativeFee() public view returns (uint256 fee) {
        fee = entropy.getFee(entropyProvider);
    }
}
