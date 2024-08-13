// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Pausable.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Permit.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Votes.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";
import "../interfaces/IGMToken.sol";

contract XGM is
    ERC20,
    ERC20Burnable,
    ERC20Pausable,
    AccessControl,
    ERC20Permit,
    ERC20Votes
{
    using EnumerableSet for EnumerableSet.UintSet;
    bytes32 public constant PAUSER_ROLE = keccak256("PAUSER_ROLE");
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");
    uint256 public constant PERCENT_DENOMINATOR = 10000;
    address public constant DEAD_ADDRESS =
        0x000000000000000000000000000000000000dEaD;

    address public gmToken;
    mapping(address => bool) public whitelistTransfer;
    bool public pauseRedeem = true;

    uint256[] public timeThresholds;
    uint256 public minRedeemTime = 15 days;
    uint256 public minRedeemPercent = 5000; // 50%
    mapping(uint256 => uint256) public redeemPercentIncrease;
    GMTokenRedeem[] public gmTokenRedeems;
    mapping(address => EnumerableSet.UintSet) private gmTokenRedeemOwners;

    struct GMTokenRedeem {
        uint256 id;
        address owner;
        uint256 amount;
        uint256 amountBurn;
        uint256 timestamp;
    }

    event Deposited(address indexed account, uint256 amount);
    event RedeemCreated(
        address indexed account,
        uint256 amount,
        uint256 amountBurn,
        uint256 timestamp
    );
    event RedeemExecuted(
        address indexed account,
        uint256 amount,
        uint256 amountBurn,
        uint256 timestamp
    );
    event BatchDistributed(address[] accounts, uint256[] amounts);
    event Distributed(address account, uint256 amount);

    constructor() ERC20("x-GMeowFi", "xGM") ERC20Permit("xGM") {
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _grantRole(PAUSER_ROLE, msg.sender);
        _grantRole(MINTER_ROLE, msg.sender);

        timeThresholds.push(16 days);
        timeThresholds.push(30 days);
        timeThresholds.push(60 days);
        timeThresholds.push(90 days);
        timeThresholds.push(120 days);
        timeThresholds.push(150 days);
        timeThresholds.push(173 days);
        timeThresholds.push(180 days);
        timeThresholds.push(184 days);

        redeemPercentIncrease[16 days] = 10; // 0.1%
        redeemPercentIncrease[30 days] = 15; // 0.15%
        redeemPercentIncrease[60 days] = 20; // 0.2%
        redeemPercentIncrease[90 days] = 25; // 0.25%
        redeemPercentIncrease[120 days] = 30; // 0.3%
        redeemPercentIncrease[150 days] = 50; // 0.5%
        redeemPercentIncrease[173 days] = 70; // 0.7%
        redeemPercentIncrease[180 days] = 130; // 1.3%
        redeemPercentIncrease[184 days] = 0; // 0%
    }

    function pause() public onlyRole(PAUSER_ROLE) {
        _pause();
    }

    function unpause() public onlyRole(PAUSER_ROLE) {
        _unpause();
    }

    function mint(uint256 amount) public whenNotPaused {
        IGMToken(gmToken).transferFrom(msg.sender, address(this), amount);
        _mint(msg.sender, amount);
    }

    function redeem(uint256 amount, uint256 duration) public whenNotPaused {
        require(!pauseRedeem, "XGM: Redeem paused");
        require(balanceOf(msg.sender) >= amount, "XGM: Insufficient balance");
        require(duration >= minRedeemTime, "XGM: Duration too short");
        require(amount > 0, "XGM: Redeem nothing");

        uint256 redeemAmount = calculateRedeem(duration, amount);
        _burn(msg.sender, amount);

        gmTokenRedeems.push(
            GMTokenRedeem({
                id: gmTokenRedeems.length,
                owner: msg.sender,
                amount: redeemAmount,
                amountBurn: amount - redeemAmount,
                timestamp: block.timestamp + duration
            })
        );
        gmTokenRedeemOwners[msg.sender].add(gmTokenRedeems.length - 1);
        emit RedeemCreated(
            msg.sender,
            redeemAmount,
            amount - redeemAmount,
            block.timestamp + duration
        );
    }

    function executeRedeem(uint256 redeemId) public whenNotPaused {
        require(!pauseRedeem, "XGM: Redeem paused");
        GMTokenRedeem storage _redeem = gmTokenRedeems[redeemId];
        require(msg.sender == _redeem.owner, "XGM: Not redeem owner");
        require(_redeem.amount != 0, "XGM: Redeem nothing");
        require(
            _redeem.timestamp <= block.timestamp,
            "XGM: Not ready to redeem"
        );
        uint256 amount = _redeem.amount;
        uint256 amountBurn = _redeem.amountBurn;
        address owner = _redeem.owner;
        gmTokenRedeemOwners[_redeem.owner].remove(redeemId);
        delete gmTokenRedeems[redeemId];
        IGMToken(gmToken).transfer(owner, amount);
        IGMToken(gmToken).transfer(DEAD_ADDRESS, amountBurn);
        emit RedeemExecuted(owner, amount, amountBurn, block.timestamp);
    }

    function cancelRedeem(uint256 redeemId) public whenNotPaused {
        GMTokenRedeem storage _redeem = gmTokenRedeems[redeemId];
        require(msg.sender == _redeem.owner, "XGM: Not redeem owner");
        require(_redeem.amount != 0, "XGM: Redeem nothing");
        require(
            _redeem.timestamp > block.timestamp,
            "XGM: Cannot cancel redeem"
        );
        uint256 amount = _redeem.amount;
        address owner = _redeem.owner;
        gmTokenRedeemOwners[_redeem.owner].remove(redeemId);
        delete gmTokenRedeems[redeemId];
        _mint(owner, amount);
    }

    function calculateRedeem(
        uint256 amount,
        uint256 duration
    ) public view returns (uint256) {
        if (duration < minRedeemTime) {
            return 0;
        }
        if (duration >= timeThresholds[timeThresholds.length - 1]) {
            return amount;
        }
        uint256 percent = minRedeemPercent;
        if (duration == minRedeemTime) {
            return (amount * percent) / PERCENT_DENOMINATOR;
        }
        for (uint256 i = 1; i < timeThresholds.length; i++) {
            if (timeThresholds[i] < duration) {
                percent +=
                    redeemPercentIncrease[timeThresholds[i - 1]] *
                    ((timeThresholds[i] - timeThresholds[i - 1]) / 1 days);
            } else {
                percent +=
                    redeemPercentIncrease[timeThresholds[i - 1]] *
                    ((duration - timeThresholds[i - 1]) / 1 days + 1);
                break;
            }
        }
        return (amount * percent) / PERCENT_DENOMINATOR;
    }

    function distributeBatch(
        address[] memory accounts,
        uint256[] memory amounts
    ) external onlyRole(MINTER_ROLE) {
        require(accounts.length == amounts.length, "XGM: Invalid input");
        uint256 totalAmount = 0;
        for (uint256 i = 0; i < accounts.length; i++) {
            totalAmount += amounts[i];
            _mint(accounts[i], amounts[i]);
        }
        emit BatchDistributed(accounts, amounts);
    }

    function distribute(
        address account,
        uint256 amount
    ) external onlyRole(MINTER_ROLE) {
        _mint(account, amount);
        emit Distributed(account, amount);
    }

    function setWhitelistTransfer(
        address account,
        bool allow
    ) external onlyRole(DEFAULT_ADMIN_ROLE) {
        whitelistTransfer[account] = allow;
    }

    function setGMToken(
        address _gmToken
    ) external onlyRole(DEFAULT_ADMIN_ROLE) {
        gmToken = _gmToken;
    }

    function getRedeems(
        address owner,
        uint256 offset,
        uint256 limit
    ) public view returns (GMTokenRedeem[] memory) {
        uint256 length = gmTokenRedeemOwners[owner].length();
        if (length == 0) {
            return new GMTokenRedeem[](0);
        }
        uint256 end = offset + limit > length ? length : offset + limit;
        GMTokenRedeem[] memory result = new GMTokenRedeem[](end - offset);
        for (uint256 i = offset; i < end; i++) {
            result[i - offset] = gmTokenRedeems[
                gmTokenRedeemOwners[owner].at(i)
            ];
        }
        return result;
    }

    function setPauseRedeem(bool _pauseRedeem) external onlyRole(PAUSER_ROLE) {
        pauseRedeem = _pauseRedeem;
    }

    // The following functions are overrides required by Solidity.

    function _update(
        address from,
        address to,
        uint256 value
    ) internal override(ERC20, ERC20Pausable, ERC20Votes) {
        require(
            from == address(0) ||
                to == address(0) ||
                whitelistTransfer[from] ||
                whitelistTransfer[to],
            "XGM: Not allowed to transfer"
        );
        super._update(from, to, value);
    }

    function nonces(
        address owner
    ) public view override(ERC20Permit, Nonces) returns (uint256) {
        return super.nonces(owner);
    }

    function emergencyWithdraw(
        address token,
        address to,
        uint256 amount
    ) external onlyRole(DEFAULT_ADMIN_ROLE) {
        if (token == address(0)) {
            payable(to).transfer(amount);
        } else {
            IERC20(token).transfer(to, amount);
        }
    }
}
