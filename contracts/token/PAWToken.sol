// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Permit.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Votes.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract PAWToken is
    ERC20,
    ERC20Burnable,
    AccessControl,
    ERC20Permit,
    ERC20Votes
{
    bytes32 public constant FOUNDATION_ROLE = keccak256("FOUNDATION_ROLE");
    uint256 public constant PERCENT_DENOMINATOR = 10000;
    uint256 public constant MAX_FEE = 1000; // 10%

    uint8 private _decimals;

    uint256 private _usdReserve;

    uint256 public blockTimestampLast;
    uint256 public totalWithdrawedByFoundation;
    uint256 public protocolFee = 30; // 0.3%
    uint256 public burnFee = 20; // 0.2%
    address public burnFeeTo;
    IERC20 public usd;

    error InvalidFeeTo(address feeTo);
    error InvalidWithdrawFee(uint256 protocolFee, uint256 burnFee);
    error InvalidInputAmount(uint256 amount);

    event Deposited(address indexed user, uint256 amountUSD, uint256 amountPAW);
    event Withdrawed(
        address indexed user,
        uint256 amountUSD,
        uint256 amountPAW
    );
    event IncreasePrice(address indexed user, uint256 amount);
    event FoundationWithdraw(address indexed foundation, uint256 amount);
    event FoundationPayback(address indexed foundation, uint256 amount);
    event UpdateFeeTo(address indexed feeTo);
    event UpdateWithdrawFee(uint256 protocolFee, uint256 burnFee);

    constructor(
        IERC20 _usd,
        address _burnFeeTo,
        uint8 decimals_
    ) ERC20("PAW Token", "PAW") ERC20Permit("PAW") {
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _grantRole(FOUNDATION_ROLE, msg.sender);
        burnFeeTo = _burnFeeTo;
        usd = _usd;
        _decimals = decimals_;
    }

    function decimals() public view override returns (uint8) {
        return _decimals;
    }

    function deposit(uint256 amount) public {
        (uint256 usdReserve, uint256 pawReserve, ) = getReserves();
        uint256 amountPAW = amount;
        if (usdReserve != 0) {
            amountPAW = (amount * pawReserve) / usdReserve;
        }

        usd.transferFrom(msg.sender, address(this), amount);
        _usdReserve += amount;
        _mint(msg.sender, amountPAW);

        blockTimestampLast = block.timestamp;
        emit Deposited(msg.sender, amount, amountPAW);
    }

    function withdraw(uint256 amount) public {
        (uint256 usdReserve, uint256 pawReserve, ) = getReserves();
        if (amount == 0 || amount == pawReserve) {
            revert InvalidInputAmount(amount);
        }
        uint256 amountUSD = amount;
        if (usdReserve != 0) {
            amountUSD = (amount * usdReserve) / pawReserve;
        }
        uint256 protocolFeeAmount = (amountUSD * protocolFee) /
            PERCENT_DENOMINATOR;
        uint256 burnFeeAmount = (amountUSD * burnFee) / PERCENT_DENOMINATOR;
        amountUSD = amountUSD - protocolFeeAmount - burnFeeAmount;
        usd.transfer(burnFeeTo, burnFeeAmount);
        _burn(msg.sender, amount);
        usd.transfer(msg.sender, amountUSD);
        _usdReserve -= amountUSD;
        blockTimestampLast = block.timestamp;
        emit Withdrawed(msg.sender, amountUSD, amount);
    }

    function foundationWithdrawForInvest(
        address to,
        uint256 amount
    ) public onlyRole(FOUNDATION_ROLE) {
        usd.transfer(to, amount);
        totalWithdrawedByFoundation += amount;
        emit FoundationWithdraw(to, amount);
    }

    function foundationPayback(
        uint256 amount
    ) public onlyRole(FOUNDATION_ROLE) {
        usd.transferFrom(msg.sender, address(this), amount);
        totalWithdrawedByFoundation -= amount;
        emit FoundationPayback(msg.sender, amount);
    }

    function setFeeTo(address _burnFeeTo) public onlyRole(DEFAULT_ADMIN_ROLE) {
        if (_burnFeeTo == address(0)) {
            revert InvalidFeeTo(_burnFeeTo);
        }
        burnFeeTo = _burnFeeTo;
        emit UpdateFeeTo(_burnFeeTo);
    }

    function increasePrice(uint256 amount) public {
        usd.transferFrom(msg.sender, address(this), amount);
        _usdReserve += amount;
        emit IncreasePrice(msg.sender, amount);
    }

    function getReserves()
        public
        view
        returns (
            uint256 usdReserve,
            uint256 pawReserve,
            uint256 _blockTimestampLast
        )
    {
        usdReserve = _usdReserve;
        pawReserve = totalSupply();
        _blockTimestampLast = blockTimestampLast;
    }

    function setWithdrawFee(
        uint256 _protocolFee,
        uint256 _burnFee
    ) public onlyRole(DEFAULT_ADMIN_ROLE) {
        if (
            _protocolFee + _burnFee > MAX_FEE ||
            _protocolFee == 0 ||
            _burnFee == 0
        ) {
            revert InvalidWithdrawFee(_protocolFee, _burnFee);
        }
        protocolFee = _protocolFee;
        burnFee = _burnFee;
        emit UpdateWithdrawFee(_protocolFee, _burnFee);
    }

    function getAmountOut(
        uint256 amountIn,
        uint256 reserveIn,
        uint256 reserveOut
    ) public pure returns (uint256 amountOut) {
        if (amountIn == 0) {
            revert InvalidInputAmount(amountIn);
        }
        if (reserveIn == 0 || reserveOut == 0) {
            amountOut = amountIn;
        } else {
            amountOut = (amountIn * reserveOut) / reserveIn;
        }
    }

    function getPrice() public view returns (uint256 price) {
        (uint256 usdReserve, uint256 pawReserve, ) = getReserves();
        price = (usdReserve * 1e8) / pawReserve;
    }
    // The following functions are overrides required by Solidity.

    function _update(
        address from,
        address to,
        uint256 value
    ) internal override(ERC20, ERC20Votes) {
        super._update(from, to, value);
    }

    function nonces(
        address owner
    ) public view override(ERC20Permit, Nonces) returns (uint256) {
        return super.nonces(owner);
    }
}
