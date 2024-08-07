// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import "@openzeppelin/contracts/utils/Address.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";
import "@pythnetwork/entropy-sdk-solidity/IEntropy.sol";
import "@pythnetwork/entropy-sdk-solidity/IEntropyConsumer.sol";
import "../../interfaces/IGmeowFiMultiNFT.sol";
import "../../interfaces/IXGM.sol";
import "../../interfaces/IGmeowFiNFT.sol";
import "../../interfaces/IWETH.sol";
import "./GMeowfiBoxTypeV1.sol";

contract GMeowFiBoxV1 is
    Ownable,
    ReentrancyGuard,
    IEntropyConsumer,
    IERC721Receiver
{
    using EnumerableSet for EnumerableSet.AddressSet;
    using Address for address;

    uint256 public constant TICKET_ID = 1;
    uint256 public constant FUN_CLAW_ID = 2;
    uint256 public constant JOY_CLAW_ID = 3;
    uint256 public constant SIP_CLAW_ID = 4;
    uint256 public constant SWEAT_CLAW_ID = 5;
    uint256 public constant TREASURE_CLAW_ID = 6;

    uint256 public boxRefillPercent = 80;

    IGmeowFiMultiNFT public gmeowFiMultiNFT;
    IGmeowFiNFT public gmeowFiNFT;
    IGMeowFiBoxStorageV1 public gmeowFiBoxStorage;
    IXGM public xGM;
    IWETH public weth;

    IEntropy private entropy;
    address private entropyProvider;
    address public devWallet;
    mapping(BoxType => uint256) public boxPrice;
    mapping(BoxType => uint256) public boxClaw;

    mapping(uint64 => RequestRandom) public requestRandoms;

    mapping(BoxType => uint256) public ticketRewards;
    mapping(BoxType => uint256) public totalBoxOpened;
    uint256 public totalParticipant;
    mapping(address => bool) public isParticipant;
    mapping(address => mapping(BoxType => uint256)) public totalBoxOpenedByUser;
    TotalReward public totalRewardEarned;
    mapping(BoxType => uint256) public txFees;

    event RandomNumberRequested(
        address indexed user,
        BoxType boxType,
        uint256 amount,
        uint64 indexed sequenceNumber
    );
    event BoxOpened(
        address indexed user,
        uint256 amountTicket,
        uint256 amountXGM,
        uint256 amountETH,
        bool availableNFT
    );
    event TransferReward(
        address indexed user,
        uint256 amountTicket,
        uint256 amountXGM,
        uint256 amountETH,
        uint256 amountNFT
    );
    event RandomBox(uint64 indexed sequenceNumber, uint256 randomNumber);

    constructor(
        IGmeowFiMultiNFT _gmeowFiMultiNFT,
        IGmeowFiNFT _gmeowFiNFT,
        IGMeowFiBoxStorageV1 _gmeowFiBoxStorage,
        IXGM _xGM,
        IWETH _weth,
        address _entropy,
        address _entropyProvider,
        address _devWallet
    ) Ownable(msg.sender) {
        gmeowFiMultiNFT = _gmeowFiMultiNFT;
        gmeowFiNFT = _gmeowFiNFT;
        gmeowFiBoxStorage = _gmeowFiBoxStorage;
        xGM = _xGM;
        weth = _weth;
        txFees[BoxType.Fun] = 0.000025 ether;
        txFees[BoxType.Joy] = 0.00005 ether;
        txFees[BoxType.Sip] = 0.000075 ether;
        txFees[BoxType.Sweat] = 0.0001 ether;
        txFees[BoxType.Treasure] = 0.00012 ether;
        entropy = IEntropy(_entropy);
        entropyProvider = _entropyProvider;
        devWallet = _devWallet;
        // Set up ticket rewards for each box type
        ticketRewards[BoxType.Fun] = 1;
        ticketRewards[BoxType.Joy] = 2;
        ticketRewards[BoxType.Sip] = 3;
        ticketRewards[BoxType.Sweat] = 4;
        ticketRewards[BoxType.Treasure] = 5;
        // Set up box price for each box type
        boxPrice[BoxType.Fun] = 0.0005 ether;
        boxPrice[BoxType.Joy] = 0.001 ether;
        boxPrice[BoxType.Sip] = 0.0015 ether;
        boxPrice[BoxType.Sweat] = 0.002 ether;
        boxPrice[BoxType.Treasure] = 0.0025 ether;
        // Set up box type for each ticket
        boxClaw[BoxType.Fun] = FUN_CLAW_ID;
        boxClaw[BoxType.Joy] = JOY_CLAW_ID;
        boxClaw[BoxType.Sip] = SIP_CLAW_ID;
        boxClaw[BoxType.Sweat] = SWEAT_CLAW_ID;
        boxClaw[BoxType.Treasure] = TREASURE_CLAW_ID;
    }

    function openBox(
        uint256 amount,
        BoxType boxType,
        PaymentToken paymentToken,
        bool pythFlag
    ) external payable {
        payable(devWallet).transfer(txFees[boxType]);
        require(!isContract(msg.sender), "Contract not allowed");
        require(amount > 0, "Amount must be greater than 0");
        if (!isParticipant[msg.sender]) {
            isParticipant[msg.sender] = true;
            totalParticipant += 1;
        }
        _pay(amount, boxType, paymentToken);
        uint64 sequenceNumber = entropy.requestWithCallback{value: getFee()}(
            entropyProvider,
            bytes32("GMeowFiBox")
        );
        requestRandoms[sequenceNumber] = RequestRandom(
            msg.sender,
            boxType,
            amount,
            sequenceNumber
        );
        totalBoxOpened[boxType] += amount;
        totalBoxOpenedByUser[msg.sender][boxType] += amount;
        emit RandomNumberRequested(msg.sender, boxType, amount, sequenceNumber);
        if (!pythFlag) {
            entropy.revealWithCallback(
                entropyProvider,
                sequenceNumber,
                bytes32("GMeowFiBox"),
                bytes32("GMeowFiBoxProviderRevelation")
            );
        }
    }

    function _pay(
        uint256 amountBox,
        BoxType boxType,
        PaymentToken paymentToken
    ) internal {
        if (paymentToken == PaymentToken.ETH) {
            require(
                msg.value >=
                    (getFee() +
                        txFees[boxType] +
                        amountBox *
                        boxPrice[boxType]),
                "Insufficient fee"
            );
            uint256 totalPay = amountBox * boxPrice[boxType];
            uint256 refillAmount = (totalPay * boxRefillPercent) / 100;
            weth.deposit{value: refillAmount}();
            payable(devWallet).transfer(address(this).balance);
        } else if (paymentToken == PaymentToken.CLAW) {
            require(
                msg.value >= (getFee() + txFees[boxType]),
                "Insufficient fee"
            );
            gmeowFiMultiNFT.burn(msg.sender, boxClaw[boxType], amountBox);
        } else {
            revert("Invalid payment token");
        }
    }

    function getFee() public view returns (uint256 fee) {
        fee = entropy.getFee(entropyProvider);
    }

    function entropyCallback(
        uint64 sequenceNumber,
        // If your app uses multiple providers, you can use this argument
        // to distinguish which one is calling the app back. This app only
        // uses one provider so this argument is not used.
        address,
        bytes32 randomNumber
    ) internal override nonReentrant {
        RequestRandom storage requestRandom = requestRandoms[sequenceNumber];
        require(
            requestRandom.user != address(0),
            "GMeowFiBox: Invalid sequence number"
        );
        require(
            sequenceNumber == requestRandom.sequenceNumber,
            "GMeowFiBox: Invalid sequence number"
        );
        uint256 xGMAmount;
        uint256 ethAmount;
        uint256 passAmount;
        // Do something with the random number
        for (uint256 i = 0; i < requestRandom.amount; i++) {
            (
                uint256 rewardXGM,
                uint256 rewardETH,
                uint256 rewardPass
            ) = _openBox(
                    requestRandom,
                    randomNumber,
                    i,
                    passAmount >= gmeowFiNFT.balanceOf(address(this))
                );
            xGMAmount += rewardXGM;
            ethAmount += rewardETH;
            passAmount += rewardPass;
        }
        _transferReward(requestRandom.user, xGMAmount, ethAmount, passAmount);
        gmeowFiMultiNFT.mint(
            requestRandom.user,
            TICKET_ID,
            requestRandom.amount * ticketRewards[requestRandom.boxType],
            ""
        );
        emit TransferReward(
            requestRandom.user,
            requestRandom.amount * ticketRewards[requestRandom.boxType],
            xGMAmount,
            ethAmount,
            passAmount
        );
    }

    function _openBox(
        RequestRandom storage requestRandom,
        bytes32 randomNumber,
        uint256 seed,
        bool isExceedPass
    )
        internal
        returns (uint256 xGMAmount, uint256 ethAmount, uint256 passAmount)
    {
        randomNumber = keccak256(
            abi.encodePacked(
                randomNumber,
                blockhash(block.number - seed),
                gasleft(),
                seed
            )
        );
        uint256 random = uint256(randomNumber) %
            gmeowFiBoxStorage.getRandomThreshold(requestRandom.boxType);
        emit RandomBox(requestRandom.sequenceNumber, random);
        BoxReward memory reward = gmeowFiBoxStorage.getRewardByRandomNumber(
            requestRandom.boxType,
            random
        );
        if (isExceedPass && reward.availableNFT) {
            reward = gmeowFiBoxStorage.getBoxReward(requestRandom.boxType, 1);
        }
        emit BoxOpened(
            requestRandom.user,
            reward.xGMAmount,
            reward.ethAmount,
            ticketRewards[requestRandom.boxType],
            reward.availableNFT
        );
        return (
            reward.xGMAmount,
            reward.ethAmount,
            reward.availableNFT ? 1 : 0
        );
    }

    function _transferReward(
        address to,
        uint256 xGMAmount,
        uint256 ethAmount,
        uint256 passAmount
    ) internal {
        if (passAmount > 0) {
            for (uint256 i = 0; i < passAmount; i++) {
                gmeowFiNFT.safeTransferFrom(
                    address(this),
                    to,
                    gmeowFiNFT.tokenOfOwnerByIndex(address(this), 0),
                    ""
                );
                totalRewardEarned.totalNFT += 1;
            }
        }
        if (xGMAmount > 0) {
            xGM.transfer(to, xGMAmount);
            totalRewardEarned.totalXGM += xGMAmount;
        }
        if (ethAmount > 0) {
            weth.transfer(to, ethAmount);
            totalRewardEarned.totalETH += ethAmount;
        }
    }

    function setPaymentToken(IXGM _xGM) external onlyOwner {
        xGM = _xGM;
    }

    function setTxFee(BoxType boxType, uint256 fee) external onlyOwner {
        txFees[boxType] = fee;
    }

    function setLotteryInjectAndRefillPercent(
        uint256 _refillPercent
    ) external onlyOwner {
        require(_refillPercent < 100, "Invalid percent");
        boxRefillPercent = _refillPercent;
    }

    function withdrawToken(address token, uint256 amount) external onlyOwner {
        if (token == address(0)) {
            payable(msg.sender).transfer(amount);
        } else {
            IERC20Metadata(token).transfer(msg.sender, amount);
        }
    }

    function withdrawNFT(address nft, uint256 tokenId) external onlyOwner {
        IERC721(nft).transferFrom(address(this), msg.sender, tokenId);
    }

    function withdrawPass(uint256 amount) external onlyOwner {
        require(
            gmeowFiNFT.balanceOf(address(this)) >= amount,
            "Insufficient pass"
        );
        for (uint256 i = 0; i < amount; i++) {
            gmeowFiNFT.safeTransferFrom(
                address(this),
                msg.sender,
                gmeowFiNFT.tokenOfOwnerByIndex(address(this), 0),
                ""
            );
        }
    }

    function setGmeowFiMultiNFT(
        IGmeowFiMultiNFT _gmeowFiMultiNFT
    ) external onlyOwner {
        gmeowFiMultiNFT = _gmeowFiMultiNFT;
    }

    function setGmeowFiNFT(IGmeowFiNFT _gmeowFiNFT) external onlyOwner {
        gmeowFiNFT = _gmeowFiNFT;
    }

    function setEntropy(
        address _entropy,
        address _entropyProvider
    ) external onlyOwner {
        entropy = IEntropy(_entropy);
        entropyProvider = _entropyProvider;
    }

    function setDevWallet(address _devWallet) external onlyOwner {
        devWallet = _devWallet;
    }

    function setPrice(BoxType boxType, uint256 price) external onlyOwner {
        boxPrice[boxType] = price;
    }

    function setGMeowFiBoxStorage(
        address _gmeowFiBoxStorage
    ) external onlyOwner {
        gmeowFiBoxStorage = IGMeowFiBoxStorageV1(_gmeowFiBoxStorage);
    }

    // This method is required by the IEntropyConsumer interface.
    // It returns the address of the entropy contract which will call the callback.
    function getEntropy() internal view override returns (address) {
        return address(entropy);
    }

    function isContract(address _addr) private view returns (bool) {
        uint32 size;
        assembly {
            size := extcodesize(_addr)
        }
        return (size > 0);
    }

    function onERC721Received(
        address,
        address,
        uint256,
        bytes calldata
    ) external pure returns (bytes4) {
        return this.onERC721Received.selector;
    }

    function supportsInterface(
        bytes4 interfaceId
    ) external pure returns (bool) {
        return
            interfaceId == type(IERC165).interfaceId ||
            interfaceId == type(IERC721Receiver).interfaceId;
    }
}
