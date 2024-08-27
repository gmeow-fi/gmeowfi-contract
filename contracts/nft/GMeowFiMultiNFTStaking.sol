// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/utils/Pausable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";
import "@openzeppelin/contracts/utils/structs/EnumerableMap.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC1155/IERC1155Receiver.sol";
import "@openzeppelin/contracts/utils/Multicall.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC1155/IERC1155.sol";

contract GMeowFiMultiNFTStaking is
    Pausable,
    Ownable,
    ReentrancyGuard,
    IERC1155Receiver,
    Multicall
{
    using EnumerableSet for EnumerableSet.UintSet;
    using EnumerableMap for EnumerableMap.UintToAddressMap;

    uint256 public constant REWARD_CLAW_ID = 2;
    uint256 public constant REWARD_CLAW_AMOUNT = 1;
    uint256 public rewardClawPeriod;
    uint256 public rewardClawDivisor;
    mapping(address => uint256) public rewardClawLastClaimed;
    bool public isPausedClaimClaw;

    IERC1155 public stakedNFT;
    IERC20 public rewardToken;
    IERC1155 public rewardClawNFT;
    EnumerableSet.UintSet private nftIds;

    // Accrued token per share
    uint256 public accTokenPerShare;

    uint256 public endTime;
    uint256 public startTime;
    uint256 public lastRewardTime;
    uint256 public rewardPerSecond;
    uint256 public totalReward;
    uint256 public lockDuration;

    // The precision factor
    uint256 public PRECISION_FACTOR = 10 ** 12;
    uint256 public totalStaked;
    UserDeposit[] public deposits;
    mapping(address => EnumerableSet.UintSet) private userDeposits;

    mapping(address => uint256) public claimed;

    // Info of each user that stakes tokens (stakedToken)
    mapping(address => UserInfo) private userInfo;

    event Deposit(
        address indexed user,
        uint256 depostiId,
        uint256 nftId,
        uint256 amount
    );
    event Withdraw(
        address indexed user,
        uint256 depositId,
        uint256 nftId,
        uint256 amount
    );
    event Claim(address indexed user, uint256 amount);
    event ClaimClaw(address indexed user, uint256 amount);

    struct UserInfo {
        uint256 amount; // How many staked tokens the user has provided
        uint256 rewardDebt; // Reward debt
        mapping(uint256 => uint256) nftStaked;
    }

    struct UserDeposit {
        uint256 depositId;
        uint256 nftId;
        uint256 amount;
        uint256 timestamp;
    }

    struct NFTInfo {
        uint256 id;
        uint256 amount;
    }

    struct UserInfoResponse {
        uint256 amount;
        uint256 rewardDebt;
        NFTInfo[] nftStaked;
    }

    constructor(
        address _stakedNFT,
        address _rewardToken,
        address _rewardClawNFT,
        uint256 _totalReward,
        uint256 _startTime,
        uint256 _endTime,
        uint256 _lockDuration,
        uint256 _rewardClawDivisor,
        uint256 _rewardClawPeriod
    ) Ownable(msg.sender) {
        stakedNFT = IERC1155(_stakedNFT);
        rewardToken = IERC20(_rewardToken);
        rewardClawNFT = IERC1155(_rewardClawNFT);
        rewardPerSecond = _totalReward / (_endTime - _startTime + 1);
        startTime = _startTime;
        endTime = _endTime;
        lastRewardTime = startTime;
        totalReward = _totalReward;
        lockDuration = _lockDuration;
        rewardClawDivisor = _rewardClawDivisor;
        rewardClawPeriod = _rewardClawPeriod;
    }

    function deposit(uint256 _nftId, uint256 _amount) external whenNotPaused {
        require(
            nftIds.contains(_nftId),
            "GMeowFiMultiNFTStaking: invalid NFT id"
        );
        UserInfo storage user = userInfo[msg.sender];
        _updatePool();
        if (user.amount > 0) {
            uint256 pending = (user.amount * accTokenPerShare) /
                PRECISION_FACTOR -
                user.rewardDebt;
            if (pending > 0) {
                rewardToken.transfer(address(msg.sender), pending);
                claimed[msg.sender] = claimed[msg.sender] + pending;
                emit Claim(msg.sender, pending);
            }
        }
        user.amount = user.amount + _amount;
        stakedNFT.safeTransferFrom(
            address(msg.sender),
            address(this),
            _nftId,
            _amount,
            ""
        );
        totalStaked = totalStaked + _amount;
        user.nftStaked[_nftId] = user.nftStaked[_nftId] + _amount;
        user.rewardDebt = (user.amount * accTokenPerShare) / PRECISION_FACTOR;

        UserDeposit memory userDeposit = UserDeposit({
            depositId: deposits.length,
            nftId: _nftId,
            amount: _amount,
            timestamp: block.timestamp
        });
        deposits.push(userDeposit);
        userDeposits[msg.sender].add(deposits.length - 1);
        emit Deposit(msg.sender, deposits.length - 1, _nftId, _amount);
    }

    function withdraw(uint256 _depositId) external whenNotPaused {
        require(
            userDeposits[msg.sender].contains(_depositId),
            "GMeowFiMultiNFTStaking: invalid deposit id"
        );
        require(
            block.timestamp - deposits[_depositId].timestamp >= lockDuration,
            "GMeowFiMultiNFTStaking: still locked"
        );
        uint256 _amount = deposits[_depositId].amount;
        uint256 _nftId = deposits[_depositId].nftId;
        require(
            userInfo[msg.sender].nftStaked[_nftId] >= _amount,
            "GMeowFiMultiNFTStaking: not enough staked"
        );
        UserInfo storage user = userInfo[msg.sender];
        _updatePool();
        uint256 pending = (user.amount * accTokenPerShare) /
            PRECISION_FACTOR -
            user.rewardDebt;
        stakedNFT.safeTransferFrom(
            (address(this)),
            msg.sender,
            _nftId,
            _amount,
            ""
        );
        totalStaked = totalStaked - _amount;
        user.nftStaked[_nftId] = user.nftStaked[_nftId] - _amount;
        user.amount = user.amount - _amount;

        if (pending > 0) {
            rewardToken.transfer(address(msg.sender), pending);
            claimed[msg.sender] = claimed[msg.sender] + pending;
            emit Claim(msg.sender, pending);
        }

        user.rewardDebt = (user.amount * accTokenPerShare) / PRECISION_FACTOR;

        userDeposits[msg.sender].remove(_depositId);
        delete deposits[_depositId];
        emit Withdraw(msg.sender, _depositId, _nftId, _amount);
    }

    function claim() external whenNotPaused {
        UserInfo storage user = userInfo[msg.sender];

        _updatePool();

        uint256 pending = (user.amount * accTokenPerShare) /
            PRECISION_FACTOR -
            user.rewardDebt;

        if (pending > 0) {
            rewardToken.transfer(address(msg.sender), pending);
            claimed[msg.sender] = claimed[msg.sender] + pending;
            emit Claim(msg.sender, pending);
        }

        user.rewardDebt = (user.amount * accTokenPerShare) / PRECISION_FACTOR;
    }

    function claimClawReward() external whenNotPaused {
        require(
            !isPausedClaimClaw,
            "GMeowFiMultiNFTStaking: claim claw is paused"
        );
        require(
            block.timestamp - rewardClawLastClaimed[msg.sender] >=
                rewardClawPeriod,
            "GMeowFiMultiNFTStaking: not ready to claim"
        );
        uint256 amount = (userInfo[msg.sender].amount / rewardClawDivisor) *
            REWARD_CLAW_AMOUNT;
        require(amount > 0, "GMeowFiMultiNFTStaking: not enough staked");
        rewardClawNFT.safeTransferFrom(
            address(this),
            msg.sender,
            REWARD_CLAW_ID,
            amount,
            ""
        );
        rewardClawLastClaimed[msg.sender] = block.timestamp;
        emit ClaimClaw(msg.sender, amount);
    }

    function _updatePool() internal {
        if (block.timestamp <= lastRewardTime) {
            return;
        }

        if (totalStaked == 0) {
            lastRewardTime = block.timestamp;
            return;
        }

        uint256 multiplier = _getMultiplier(lastRewardTime, block.timestamp);
        uint256 reward = multiplier * rewardPerSecond;
        accTokenPerShare =
            accTokenPerShare +
            (reward * PRECISION_FACTOR) /
            totalStaked;
        lastRewardTime = block.timestamp;
    }

    function stopReward() external onlyOwner {
        endTime = block.timestamp;
    }

    function updaterewardPerSecond(
        uint256 _rewardPerSecond
    ) external onlyOwner {
        require(block.timestamp < startTime, "Pool has started");
        rewardPerSecond = _rewardPerSecond;
        // emit NewrewardPerSecond(_rewardPerSecond);
    }

    function updateStartAndEnd(
        uint256 _startTime,
        uint256 _endTime
    ) external onlyOwner {
        require(block.timestamp < startTime, "Pool has started");
        require(
            _startTime < _endTime,
            "New startTime must be lower than new endTime"
        );
        require(
            block.timestamp < _startTime,
            "New startTime must be higher than current time"
        );

        startTime = _startTime;
        endTime = _endTime;

        // Set the lastRewardTime as the startTime
        lastRewardTime = startTime;
    }

    function pendingReward(address _user) external view returns (uint256) {
        UserInfo storage user = userInfo[_user];
        if (block.timestamp > lastRewardTime && totalStaked != 0) {
            uint256 multiplier = _getMultiplier(
                lastRewardTime,
                block.timestamp
            );
            uint256 reward = multiplier * rewardPerSecond;
            uint256 adjustedTokenPerShare = accTokenPerShare +
                (reward * PRECISION_FACTOR) /
                totalStaked;
            return
                (user.amount * adjustedTokenPerShare) /
                PRECISION_FACTOR -
                user.rewardDebt;
        } else {
            return
                (user.amount * accTokenPerShare) /
                PRECISION_FACTOR -
                user.rewardDebt;
        }
    }

    /*
     * @notice Return reward multiplier over the given _from to _to timestamp.
     * @param _from: time to start
     * @param _to: time to finish
     */
    function _getMultiplier(
        uint256 _from,
        uint256 _to
    ) internal view returns (uint256) {
        if (_to <= endTime) {
            return _to - _from;
        } else if (_from >= endTime) {
            return 0;
        } else {
            return endTime - _from;
        }
    }

    function setStakedNFT(address _stakedNFT) external onlyOwner {
        stakedNFT = IERC1155(_stakedNFT);
    }

    function setRewardToken(address _rewardToken) external onlyOwner {
        rewardToken = IERC20(_rewardToken);
    }

    function setNFTIds(
        uint256[] calldata _nftIds,
        bool _isSet
    ) external onlyOwner {
        if (_isSet) {
            for (uint256 i = 0; i < _nftIds.length; i++) {
                nftIds.add(_nftIds[i]);
            }
        } else {
            for (uint256 i = 0; i < _nftIds.length; i++) {
                nftIds.remove(_nftIds[i]);
            }
        }
    }

    function removeNFTId(uint256[] memory _nftIds) external onlyOwner {
        for (uint256 i = 0; i < _nftIds.length; i++) {
            nftIds.remove(_nftIds[i]);
        }
    }

    function getUserInfo(
        address user
    ) external view returns (UserInfoResponse memory) {
        UserInfo storage _userInfo = userInfo[user];
        NFTInfo[] memory nftStaked = new NFTInfo[](nftIds.length());
        for (uint256 i = 0; i < nftIds.length(); i++) {
            uint256 nftId = nftIds.at(i);
            nftStaked[i] = NFTInfo({
                id: nftId,
                amount: _userInfo.nftStaked[nftId]
            });
        }
        return
            UserInfoResponse({
                amount: _userInfo.amount,
                rewardDebt: _userInfo.rewardDebt,
                nftStaked: nftStaked
            });
    }

    function getUserDeposits(
        address _user
    ) external view returns (UserDeposit[] memory) {
        UserDeposit[] memory _userDeposits = new UserDeposit[](
            userDeposits[_user].length()
        );
        for (uint256 i = 0; i < userDeposits[_user].length(); i++) {
            _userDeposits[i] = deposits[userDeposits[_user].at(i)];
        }
        return _userDeposits;
    }

    function pause() public onlyOwner {
        _pause();
    }

    function unpause() public onlyOwner {
        _unpause();
    }

    function pauseClaimClaw() external onlyOwner {
        isPausedClaimClaw = true;
    }

    function unpauseClaimClaw() external onlyOwner {
        isPausedClaimClaw = false;
    }

    function emergencyWithdraw(address token) external onlyOwner {
        if (token == address(0)) {
            payable(msg.sender).transfer(address(this).balance);
        } else {
            IERC20(token).transfer(
                msg.sender,
                IERC20(token).balanceOf(address(this))
            );
        }
    }

    function emergencyWithdrawNFT(
        address account,
        uint256 id,
        uint256 amount
    ) external onlyOwner {
        stakedNFT.safeTransferFrom(address(this), account, id, amount, "");
    }

    function supportsInterface(
        bytes4 interfaceId
    ) external pure override returns (bool) {
        return
            interfaceId == this.onERC1155Received.selector ||
            interfaceId == this.onERC1155BatchReceived.selector;
    }

    function onERC1155Received(
        address,
        address,
        uint256,
        uint256,
        bytes calldata
    ) external pure returns (bytes4) {
        return this.onERC1155Received.selector;
    }

    function onERC1155BatchReceived(
        address,
        address,
        uint256[] calldata,
        uint256[] calldata,
        bytes calldata
    ) external pure returns (bytes4) {
        return this.onERC1155BatchReceived.selector;
    }
}
