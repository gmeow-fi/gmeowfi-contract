// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";

import "./StakingInitializable.sol";

contract StakingFactory is Ownable {
    event NewStakingContract(address indexed stakingPool);

    address[] public allPools;

    constructor() Ownable(msg.sender) {
        //
    }

    /*
     * @notice Deploy the pool
     * @param _stakedToken: staked token address
     * @param _rewardToken: reward token address
     * @param _rewardPerBlock: reward per block (in rewardToken)
     * @param _startBlock: start block
     * @param _endBlock: end block
     * @param _poolLimitPerUser: pool limit per user in stakedToken (if any, else 0)
     * @param _admin: admin address with ownership
     * @return address of new staking pool contract
     */
    function deployPool(
        IERC20Metadata _stakedToken,
        IERC20Metadata _rewardToken,
        uint256 _rewardPerSecond,
        uint256 _startSecond,
        uint256 _bonusEndSecond,
        uint256 _poolLimitPerUser,
        uint256 _maxlockTime,
        uint256 _minlockTime,
        uint256 _maxBoostingMultiplier,
        address _admin
    ) external onlyOwner {
        require(_stakedToken.totalSupply() >= 0);
        require(_rewardToken.totalSupply() >= 0);
        require(_stakedToken != _rewardToken, "Tokens must be be different");
        require(
            _startSecond > block.timestamp,
            "start time must be in the future"
        );
        require(
            _startSecond < _bonusEndSecond,
            "bonus end block must be after start block"
        );

        bytes memory bytecode = type(StakingInitializable).creationCode;
        bytes32 salt = keccak256(
            abi.encodePacked(
                _stakedToken,
                _rewardToken,
                _rewardPerSecond,
                _startSecond,
                _bonusEndSecond,
                _poolLimitPerUser,
                _maxlockTime,
                _minlockTime,
                _maxBoostingMultiplier,
                _admin
            )
        );
        address stakingPool;

        assembly {
            stakingPool := create2(0, add(bytecode, 32), mload(bytecode), salt)
        }

        StakingInitializable(stakingPool).initialize(
            _stakedToken,
            _rewardToken,
            _rewardPerSecond,
            _startSecond,
            _bonusEndSecond,
            _poolLimitPerUser,
            _maxlockTime,
            _minlockTime,
            _maxBoostingMultiplier,
            _admin
        );
        allPools.push(stakingPool);
        uint256 totalReward = _rewardPerSecond *
            (_bonusEndSecond - _startSecond + 1);
        IERC20Metadata(_rewardToken).transferFrom(
            msg.sender,
            stakingPool,
            totalReward
        );
        emit NewStakingContract(stakingPool);
    }

    function calculatePoolAddress(
        IERC20Metadata _stakedToken,
        IERC20Metadata _rewardToken,
        uint256 _rewardPerSecond,
        uint256 _startSecond,
        uint256 _bonusEndSecond,
        uint256 _poolLimitPerUser,
        uint256 _maxlockTime,
        uint256 _minlockTime,
        uint256 _maxBoostingMultiplier,
        address _admin
    ) external view returns (address) {
        bytes32 salt = keccak256(
            abi.encodePacked(
                _stakedToken,
                _rewardToken,
                _rewardPerSecond,
                _startSecond,
                _bonusEndSecond,
                _poolLimitPerUser,
                _maxlockTime,
                _minlockTime,
                _maxBoostingMultiplier,
                _admin
            )
        );
        bytes32 hash = keccak256(
            abi.encodePacked(
                bytes1(0xff),
                address(this),
                salt,
                keccak256(type(StakingInitializable).creationCode)
            )
        );
        return address(uint160(uint256(hash)));
    }

    function allPoolsLength() external view returns (uint256) {
        return allPools.length;
    }

    function getPoolInfo(
        uint256 _index
    ) external view returns (StakingInitializable.PoolInfo memory) {
        return StakingInitializable(allPools[_index]).getPoolInfo();
    }

    function getPools(
        uint256 _offset,
        uint256 _limit
    ) external view returns (StakingInitializable.PoolInfo[] memory) {
        if (_offset >= allPools.length) {
            return new StakingInitializable.PoolInfo[](0);
        }
        uint256 length;
        if (_offset + _limit > allPools.length) {
            length = allPools.length;
        } else {
            length = _offset + _limit;
        }
        StakingInitializable.PoolInfo[]
            memory result = new StakingInitializable.PoolInfo[](
                length - _offset
            );
        for (uint256 i = _offset; i < length; i++) {
            result[i - _offset] = StakingInitializable(allPools[i])
                .getPoolInfo();
        }
        return result;
    }
}
