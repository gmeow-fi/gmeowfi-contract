// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

import "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";

contract StakingInitializable is Ownable, ReentrancyGuard {
    using SafeERC20 for IERC20Metadata;
    using EnumerableSet for EnumerableSet.UintSet;

    address public STAKING_FACTORY;

    // Whether a limit is set for users
    bool public hasUserLimit;

    // Whether it is initialized
    bool public isInitialized;

    // Accrued token per share
    uint256 public accTokenPerShare;

    // The timestamp when reward mining ends.
    uint256 public bonusEndTimestamp;

    // The timestamp when reward mining starts.
    uint256 public startTimestamp;

    // The timestamp of the last pool update
    uint256 public lastRewardTimestamp;

    // The pool limit (0 if none)
    uint256 public poolLimitPerUser;

    // reward tokens created per second.
    uint256 public rewardPerSecond;

    // The precision factor
    uint256 public PRECISION_FACTOR;
    uint256 public MULTIPLIER_FACTOR = 10000;

    // The reward token
    IERC20Metadata public rewardToken;

    // The staked token
    IERC20Metadata public stakedToken;

    uint256 public maxLockTime;
    uint256 public minLockTime;
    uint256 public maxBoostingMultiplier;

    uint256 public totalStaked;
    uint256 public virtualTotalStaked;

    // Info of each user that stakes tokens (stakedToken)
    DepositInfo[] public depositInfo;
    mapping(address => EnumerableSet.UintSet) private userStakes;

    mapping(address => UserInfo) public userInfo;

    struct DepositInfo {
        uint256 depositId;
        address owner;
        uint256 amount; // How many staked tokens the user has provided
        uint256 virtualAmount; // Boosted amount
        uint256 lockUntil; // Lock until timestamp
    }

    struct UserInfo {
        uint256 amount;
        uint256 virtualAmount;
        uint256 rewardDebt;
    }

    struct PoolInfo {
        address _poolAddress;
        IERC20Metadata _stakedToken;
        IERC20Metadata _rewardToken;
        uint256 _rewardPerSecond;
        uint256 _startTimestamp;
        uint256 _bonusEndTimestamp;
        uint256 _poolLimitPerUser;
        uint256 _maxLockTime;
        uint256 _minLockTime;
        uint256 _maxBoostingMultiplier;
        uint256 _totalStaked;
        uint256 _virtualTotalStake;
    }

    event AdminTokenRecovery(address tokenRecovered, uint256 amount);
    event Deposit(
        address indexed user,
        uint256 depositId,
        address indexed token,
        uint256 amount,
        uint256 lockDuration,
        uint256 virtualAmount
    );
    event AddDeposit(
        address indexed user,
        uint256 depositId,
        address indexed token,
        uint256 amount,
        uint256 virtualAmount
    );
    event ExtendDeposit(
        address indexed user,
        uint256 depositId,
        address indexed token,
        uint256 extendTime,
        uint256 oldVirtualAmount,
        uint256 newVirtualAmount
    );
    event EmergencyWithdraw(address indexed user, uint256 amount);
    event NewStartAndEndTimestamp(uint256 startTimestamp, uint256 endTimestamp);
    event NewRewardPerSecond(uint256 rewardPerSecond);
    event NewPoolLimit(uint256 poolLimitPerUser);
    event RewardsStop(uint256 timestamp);
    event Withdraw(
        address indexed user,
        uint256 depositId,
        address token,
        uint256 amount,
        uint256 virtualAmount
    );

    constructor() Ownable(msg.sender) {
        STAKING_FACTORY = msg.sender;
    }

    /*
     * @notice Initialize the contract
     * @param _stakedToken: staked token address
     * @param _rewardToken: reward token address
     * @param _rewardPerSecond: reward per second (in rewardToken)
     * @param _startTimestamp: start second
     * @param _bonusEndTimestamp: end second
     * @param _poolLimitPerUser: pool limit per user in stakedToken (if any, else 0)
     * @param _admin: admin address with ownership
     */
    function initialize(
        IERC20Metadata _stakedToken,
        IERC20Metadata _rewardToken,
        uint256 _rewardPerSecond,
        uint256 _startTimestamp,
        uint256 _bonusEndTimestamp,
        uint256 _poolLimitPerUser,
        uint256 _maxlockTime,
        uint256 _minlockTime,
        uint256 _maxBoostingMultiplier,
        address _admin
    ) external {
        require(!isInitialized, "Already initialized");
        require(msg.sender == STAKING_FACTORY, "Not factory");

        // Make this contract initialized
        isInitialized = true;

        stakedToken = _stakedToken;
        rewardToken = _rewardToken;
        rewardPerSecond = _rewardPerSecond;
        startTimestamp = _startTimestamp;
        bonusEndTimestamp = _bonusEndTimestamp;
        maxLockTime = _maxlockTime;
        minLockTime = _minlockTime;
        maxBoostingMultiplier = _maxBoostingMultiplier;

        if (_poolLimitPerUser > 0) {
            hasUserLimit = true;
            poolLimitPerUser = _poolLimitPerUser;
        }

        uint256 decimalsRewardToken = uint256(rewardToken.decimals());
        require(decimalsRewardToken < 30, "Must be inferior to 30");
        PRECISION_FACTOR = uint256(10 ** (uint256(30) - decimalsRewardToken));

        // Set the lastRewardTimestamp as the startTimestamp
        lastRewardTimestamp = startTimestamp;

        // Transfer ownership to the admin address who becomes owner of the contract
        transferOwnership(_admin);
    }

    function createDeposit(
        uint256 _amount,
        uint256 _duration
    ) external nonReentrant {
        require(_duration <= maxLockTime, "StakingPool: lock time too high");
        require(_duration >= minLockTime, "StakingPool: lock time too low");
        require(_amount > 0, "StakingPool: amount too low");
        require(
            block.timestamp < bonusEndTimestamp,
            "StakingPool: pool closed"
        );
        UserInfo storage _userInfo = userInfo[msg.sender];
        if (hasUserLimit) {
            require(
                _amount + _userInfo.amount <= poolLimitPerUser,
                "StakingPool: User amount above limit"
            );
        }
        _updatePool();

        // calculate pending rewards with all the staked tokens
        uint256 pending = ((_userInfo.amount + _userInfo.virtualAmount) *
            accTokenPerShare) /
            PRECISION_FACTOR -
            _userInfo.rewardDebt;
        if (pending > 0) {
            rewardToken.safeTransfer(address(msg.sender), pending);
        }

        uint256 _virtualAmount = getVirtualAmount(_amount, _duration);
        stakedToken.safeTransferFrom(
            address(msg.sender),
            address(this),
            _amount
        );

        totalStaked = totalStaked + _amount;
        virtualTotalStaked = virtualTotalStaked + _virtualAmount;

        uint256 depositId = depositInfo.length;
        depositInfo.push(
            DepositInfo({
                depositId: depositId,
                owner: msg.sender,
                amount: _amount,
                virtualAmount: _virtualAmount,
                lockUntil: block.timestamp + _duration
            })
        );
        userStakes[msg.sender].add(depositId);
        _userInfo.amount = _userInfo.amount + _amount;
        _userInfo.virtualAmount = _userInfo.virtualAmount + _virtualAmount;
        _userInfo.rewardDebt =
            ((_userInfo.amount + _userInfo.virtualAmount) * accTokenPerShare) /
            PRECISION_FACTOR;
        emit Deposit(
            msg.sender,
            depositId,
            address(stakedToken),
            _amount,
            _duration,
            _virtualAmount
        );
    }

    /*
     * @notice Deposit staked tokens and collect reward tokens (if any)
     * @param _amount: amount to withdraw (in rewardToken)
     */
    function addToDeposit(
        uint256 _depositId,
        uint256 _amount
    ) external nonReentrant {
        require(
            block.timestamp < bonusEndTimestamp,
            "StakingPool: pool closed"
        );
        require(_amount > 0, "StakingPool: amount too low");
        DepositInfo storage _deposit = depositInfo[_depositId];
        require(_deposit.owner == msg.sender, "StakingPool: not authorized");
        require(
            _deposit.lockUntil > block.timestamp + minLockTime,
            "StakingPool: lock time too low"
        );
        UserInfo storage _userInfo = userInfo[msg.sender];
        if (hasUserLimit) {
            require(
                _amount + _userInfo.amount <= poolLimitPerUser,
                "StakingPool: User amount above limit"
            );
        }

        _updatePool();
        // calculate pending rewards with all the staked tokens
        uint256 pending = ((_userInfo.amount + _userInfo.virtualAmount) *
            accTokenPerShare) /
            PRECISION_FACTOR -
            _userInfo.rewardDebt;
        if (pending > 0) {
            rewardToken.safeTransfer(address(msg.sender), pending);
        }

        // update deposit info
        uint256 _virtualAmount = getVirtualAmount(
            _amount,
            _deposit.lockUntil - block.timestamp
        );
        _deposit.amount = _deposit.amount + _amount;
        _deposit.virtualAmount = _deposit.virtualAmount + _virtualAmount;
        stakedToken.safeTransferFrom(
            address(msg.sender),
            address(this),
            _amount
        );

        totalStaked = totalStaked + _amount;
        virtualTotalStaked = virtualTotalStaked + _virtualAmount;

        _userInfo.amount = _userInfo.amount + _amount;
        _userInfo.virtualAmount = _userInfo.virtualAmount + _virtualAmount;
        _userInfo.rewardDebt =
            ((_userInfo.amount + _userInfo.virtualAmount) * accTokenPerShare) /
            PRECISION_FACTOR;

        emit AddDeposit(
            msg.sender,
            _depositId,
            address(stakedToken),
            _amount,
            _virtualAmount
        );
    }

    function extendDeposit(
        uint256 _depositId,
        uint256 _extendDuration
    ) external nonReentrant {
        require(
            block.timestamp < bonusEndTimestamp,
            "StakingPool: pool closed"
        );
        DepositInfo storage _deposit = depositInfo[_depositId];
        require(_deposit.owner == msg.sender, "StakingPool: not authorized");
        uint256 startLockTime = _deposit.lockUntil > block.timestamp
            ? _deposit.lockUntil
            : block.timestamp;
        require(
            startLockTime + _extendDuration <= block.timestamp + maxLockTime,
            "StakingPool: lock time too high"
        );
        require(
            startLockTime + _extendDuration >= block.timestamp + minLockTime,
            "StakingPool: lock time too low"
        );
        UserInfo storage _userInfo = userInfo[msg.sender];

        _updatePool();
        // calculate pending rewards with all the staked tokens
        uint256 pending = ((_userInfo.amount + _userInfo.virtualAmount) *
            accTokenPerShare) /
            PRECISION_FACTOR -
            _userInfo.rewardDebt;
        if (pending > 0) {
            rewardToken.safeTransfer(address(msg.sender), pending);
        }

        uint256 _virtualAmount = getVirtualAmount(
            _deposit.amount,
            startLockTime + _extendDuration - block.timestamp
        );
        virtualTotalStaked =
            virtualTotalStaked -
            _deposit.virtualAmount +
            _virtualAmount;

        _userInfo.virtualAmount =
            _userInfo.virtualAmount -
            _deposit.virtualAmount +
            _virtualAmount;
        uint256 oldVirtualAmount = _deposit.virtualAmount;
        _deposit.virtualAmount = _virtualAmount;
        _deposit.lockUntil = startLockTime + _extendDuration;
        _userInfo.rewardDebt =
            ((_userInfo.amount + _userInfo.virtualAmount) * accTokenPerShare) /
            PRECISION_FACTOR;
        emit ExtendDeposit(
            msg.sender,
            _depositId,
            address(stakedToken),
            _extendDuration,
            oldVirtualAmount,
            _virtualAmount
        );
    }

    /*
     * @notice Withdraw staked tokens and collect reward tokens
     * @param _amount: amount to withdraw (in rewardToken)
     */
    function withdraw(uint256 _depositId) external nonReentrant {
        DepositInfo storage _deposit = depositInfo[_depositId];
        require(_deposit.owner == msg.sender, "StakingPool: not authorized");
        require(
            _deposit.lockUntil < block.timestamp,
            "StakingPool: lock time not reached"
        );
        UserInfo storage _userInfo = userInfo[msg.sender];

        _updatePool();

        uint256 pending = ((_userInfo.amount + _userInfo.virtualAmount) *
            accTokenPerShare) /
            PRECISION_FACTOR -
            _userInfo.rewardDebt;
        if (pending > 0) {
            rewardToken.safeTransfer(address(msg.sender), pending);
        }

        _userInfo.amount = _userInfo.amount - _deposit.amount;
        _userInfo.virtualAmount =
            _userInfo.virtualAmount -
            _deposit.virtualAmount;
        stakedToken.safeTransfer(address(msg.sender), _deposit.amount);
        totalStaked = totalStaked - _deposit.amount;
        virtualTotalStaked = virtualTotalStaked - _deposit.virtualAmount;

        _userInfo.rewardDebt =
            ((_userInfo.amount + _userInfo.virtualAmount) * accTokenPerShare) /
            PRECISION_FACTOR;
        uint256 amount = _deposit.amount;
        uint256 virtualAmount = _deposit.virtualAmount;
        delete depositInfo[_depositId];
        userStakes[msg.sender].remove(_depositId);

        emit Withdraw(
            msg.sender,
            _depositId,
            address(stakedToken),
            amount,
            virtualAmount
        );
    }

    function claimReward() external nonReentrant {
        UserInfo storage _userInfo = userInfo[msg.sender];
        _updatePool();
        uint256 pending = ((_userInfo.amount + _userInfo.virtualAmount) *
            accTokenPerShare) /
            PRECISION_FACTOR -
            _userInfo.rewardDebt;
        if (pending > 0) {
            rewardToken.safeTransfer(address(msg.sender), pending);
        }
        _userInfo.rewardDebt =
            ((_userInfo.amount + _userInfo.virtualAmount) * accTokenPerShare) /
            PRECISION_FACTOR;
    }

    // /*
    //  * @notice Withdraw staked tokens without caring about rewards rewards
    //  * @dev Needs to be for emergency.
    //  */
    // function emergencyWithdraw() external nonReentrant {
    //     DepositInfo storage user = DepositInfo[msg.sender];
    //     uint256 amountToTransfer = user.amount;
    //     user.amount = 0;
    //     user.rewardDebt = 0;

    //     if (amountToTransfer > 0) {
    //         stakedToken.safeTransfer(address(msg.sender), amountToTransfer);
    //     }

    //     emit EmergencyWithdraw(msg.sender, user.amount);
    // }

    /*
     * @notice Stop rewards
     * @dev Only callable by owner. Needs to be for emergency.
     */
    function emergencyRewardWithdraw(uint256 _amount) external onlyOwner {
        rewardToken.safeTransfer(address(msg.sender), _amount);
    }

    /**
     * @notice It allows the admin to recover wrong tokens sent to the contract
     * @param _tokenAddress: the address of the token to withdraw
     * @param _tokenAmount: the number of tokens to withdraw
     * @dev This function is only callable by admin.
     */
    function recoverWrongTokens(
        address _tokenAddress,
        uint256 _tokenAmount
    ) external onlyOwner {
        require(
            _tokenAddress != address(stakedToken),
            "Cannot be staked token"
        );
        require(
            _tokenAddress != address(rewardToken),
            "Cannot be reward token"
        );

        IERC20Metadata(_tokenAddress).safeTransfer(
            address(msg.sender),
            _tokenAmount
        );

        emit AdminTokenRecovery(_tokenAddress, _tokenAmount);
    }

    /*
     * @notice Stop rewards
     * @dev Only callable by owner
     */
    function stopReward() external onlyOwner {
        bonusEndTimestamp = block.timestamp;
    }

    /*
     * @notice Update pool limit per user
     * @dev Only callable by owner.
     * @param _hasUserLimit: whether the limit remains forced
     * @param _poolLimitPerUser: new pool limit per user
     */
    function updatePoolLimitPerUser(
        bool _hasUserLimit,
        uint256 _poolLimitPerUser
    ) external onlyOwner {
        require(hasUserLimit, "Must be set");
        if (_hasUserLimit) {
            require(
                _poolLimitPerUser > poolLimitPerUser,
                "New limit must be higher"
            );
            poolLimitPerUser = _poolLimitPerUser;
        } else {
            hasUserLimit = _hasUserLimit;
            poolLimitPerUser = 0;
        }
        emit NewPoolLimit(poolLimitPerUser);
    }

    /*
     * @notice Update reward per block
     * @dev Only callable by owner.
     * @param _rewardPerSecond: the reward per block
     */
    function updateRewardPerSecond(
        uint256 _rewardPerSecond
    ) external onlyOwner {
        require(block.timestamp < startTimestamp, "Pool has started");
        rewardPerSecond = _rewardPerSecond;
        emit NewRewardPerSecond(_rewardPerSecond);
    }

    /**
     * @notice It allows the admin to update start and end blocks
     * @dev This function is only callable by owner.
     * @param _startTimestamp: the new start block
     * @param _bonusEndTimestamp: the new end block
     */
    function updateStartAndEndTimestamp(
        uint256 _startTimestamp,
        uint256 _bonusEndTimestamp
    ) external onlyOwner {
        require(block.timestamp < startTimestamp, "Pool has started");
        require(
            _startTimestamp < _bonusEndTimestamp,
            "New startTimestamp must be lower than new endBlock"
        );
        require(
            block.timestamp < _startTimestamp,
            "New startTimestamp must be higher than current block"
        );

        startTimestamp = _startTimestamp;
        bonusEndTimestamp = _bonusEndTimestamp;

        // Set the lastRewardTimestamp as the startTimestamp
        lastRewardTimestamp = startTimestamp;

        emit NewStartAndEndTimestamp(_startTimestamp, _bonusEndTimestamp);
    }

    /*
     * @notice View function to see pending reward on frontend.
     * @param _user: user address
     * @return Pending reward for a given user
     */
    function pendingReward(address _user) external view returns (uint256) {
        UserInfo storage user = userInfo[_user];
        uint256 stakedTokenSupply = totalStaked;
        if (block.timestamp > lastRewardTimestamp && stakedTokenSupply != 0) {
            uint256 multiplier = _getMultiplier(
                lastRewardTimestamp,
                block.timestamp
            );
            uint256 tokenReward = multiplier * rewardPerSecond;
            uint256 adjustedTokenPerShare = accTokenPerShare +
                ((tokenReward * PRECISION_FACTOR) /
                    (stakedTokenSupply + virtualTotalStaked));
            return
                ((user.amount + user.virtualAmount) * adjustedTokenPerShare) /
                PRECISION_FACTOR -
                user.rewardDebt;
        } else {
            return
                ((user.amount + user.virtualAmount) * accTokenPerShare) /
                PRECISION_FACTOR -
                user.rewardDebt;
        }
    }

    function getUserDeposits(
        address user
    ) external view returns (DepositInfo[] memory) {
        uint256 length = userStakes[user].length();
        DepositInfo[] memory deposits = new DepositInfo[](length);
        for (uint256 i = 0; i < length; i++) {
            deposits[i] = depositInfo[userStakes[user].at(i)];
        }
        return deposits;
    }
    /*
     * @notice Update reward variables of the given pool to be up-to-date.
     */
    function _updatePool() internal {
        if (block.timestamp <= lastRewardTimestamp) {
            return;
        }
        uint256 stakedTokenSupply = totalStaked;
        if (stakedTokenSupply == 0) {
            lastRewardTimestamp = block.timestamp;
            return;
        }
        uint256 multiplier = _getMultiplier(
            lastRewardTimestamp,
            block.timestamp
        );
        uint256 tokenReward = multiplier * rewardPerSecond;
        accTokenPerShare =
            accTokenPerShare +
            (tokenReward * PRECISION_FACTOR) /
            (stakedTokenSupply + virtualTotalStaked);
        lastRewardTimestamp = block.timestamp;
    }

    /*
     * @notice Return reward multiplier over the given _from to _to block.
     * @param _from: block to start
     * @param _to: block to finish
     */
    function _getMultiplier(
        uint256 _from,
        uint256 _to
    ) internal view returns (uint256) {
        if (_to <= bonusEndTimestamp) {
            return _to - _from;
        } else if (_from >= bonusEndTimestamp) {
            return 0;
        } else {
            return bonusEndTimestamp - _from;
        }
    }

    function getVirtualAmount(
        uint256 _amount,
        uint256 _duration
    ) public view returns (uint256) {
        return
            (_amount * (_duration - minLockTime) * maxBoostingMultiplier) /
            (maxLockTime - minLockTime) /
            MULTIPLIER_FACTOR;
    }

    function getPoolInfo() external view returns (PoolInfo memory) {
        return
            PoolInfo({
                _poolAddress: address(this),
                _stakedToken: stakedToken,
                _rewardToken: rewardToken,
                _rewardPerSecond: rewardPerSecond,
                _startTimestamp: startTimestamp,
                _bonusEndTimestamp: bonusEndTimestamp,
                _poolLimitPerUser: poolLimitPerUser,
                _maxLockTime: maxLockTime,
                _minLockTime: minLockTime,
                _maxBoostingMultiplier: maxBoostingMultiplier,
                _totalStaked: totalStaked,
                _virtualTotalStake: virtualTotalStaked
            });
    }
}
