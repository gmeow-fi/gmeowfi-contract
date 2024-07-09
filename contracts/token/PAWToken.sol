// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Pausable.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Permit.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Votes.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract PAWToken is
    ERC20,
    ERC20Burnable,
    ERC20Pausable,
    AccessControl,
    ERC20Permit,
    ERC20Votes
{
    bytes32 public constant PAUSER_ROLE = keccak256("PAUSER_ROLE");
    uint256 public constant PERCENT_DENOMINATOR = 10000;

    uint256 public blockTimestampLast;
    uint256 public protocolFee = 30; // 0.3%
    uint256 public burnFee = 20; // 0.2%
    address public protocolFeeTo;
    address public burnFeeTo;
    IERC20 public sUSDe;

    error InvalidFeeTo(address feeTo);
    error InvalidWithdrawFee(uint256 protocolFee, uint256 burnFee);
    error InvalidInputAmount(uint256 amount);

    event Deposited(
        address indexed user,
        uint256 amountSUSDe,
        uint256 amountPAW
    );
    event Withdrawed(
        address indexed user,
        uint256 amountSUSDe,
        uint256 amountPAW
    );
    event IncreasePrice(address indexed user, uint256 amount);

    constructor() ERC20("PAW Token", "PAW") ERC20Permit("PAW") {
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _grantRole(PAUSER_ROLE, msg.sender);
    }

    function pause() public onlyRole(PAUSER_ROLE) {
        _pause();
    }

    function unpause() public onlyRole(PAUSER_ROLE) {
        _unpause();
    }

    function deposit(uint256 amount) public {
        (uint256 usdeReserve, uint256 pawReserve, ) = getReserves();
        uint256 amountPAW = amount;
        if (usdeReserve != 0) {
            amountPAW = (amount * pawReserve) / usdeReserve;
        }

        sUSDe.transferFrom(msg.sender, address(this), amount);
        _mint(msg.sender, amountPAW);

        blockTimestampLast = block.timestamp;
        emit Deposited(msg.sender, amount, amountPAW);
    }

    function withdraw(uint256 amount) public {
        (uint256 usdeReserve, uint256 pawReserve, ) = getReserves();
        if (amount == 0 || amount == pawReserve) {
            revert InvalidInputAmount(amount);
        }
        uint256 amountSUSDe = amount;
        if (usdeReserve != 0) {
            amountSUSDe = (amount * usdeReserve) / pawReserve;
        }
        uint256 protocolFeeAmount = (amountSUSDe * protocolFee) /
            PERCENT_DENOMINATOR;
        sUSDe.transfer(protocolFeeTo, protocolFeeAmount);
        uint256 burnFeeAmount = (amountSUSDe * burnFee) / PERCENT_DENOMINATOR;
        amountSUSDe = amountSUSDe - protocolFeeAmount - burnFeeAmount;
        sUSDe.transfer(burnFeeTo, burnFeeAmount);
        _burn(msg.sender, amount);
        sUSDe.transfer(msg.sender, amountSUSDe);
        blockTimestampLast = block.timestamp;
        emit Withdrawed(msg.sender, amountSUSDe, amount);
    }

    function setFeeTo(
        address _protocolFeeTo,
        address _burnFeeTo
    ) public onlyRole(DEFAULT_ADMIN_ROLE) {
        if (_protocolFeeTo == address(0) || _burnFeeTo == address(0)) {
            revert InvalidFeeTo(_protocolFeeTo);
        }
        protocolFeeTo = _protocolFeeTo;
        burnFeeTo = _burnFeeTo;
    }

    function increasePrice(uint256 amount) public {
        sUSDe.transferFrom(msg.sender, address(this), amount);
        emit IncreasePrice(msg.sender, amount);
    }

    function getReserves()
        public
        view
        returns (
            uint256 usdeReserve,
            uint256 pawReserve,
            uint256 _blockTimestampLast
        )
    {
        usdeReserve = sUSDe.balanceOf(address(this));
        pawReserve = totalSupply();
        _blockTimestampLast = blockTimestampLast;
    }

    function setSUSDe(address _sUSDe) public onlyRole(DEFAULT_ADMIN_ROLE) {
        sUSDe = IERC20(_sUSDe);
    }

    function setWithdrawFee(
        uint256 _protocolFee,
        uint256 _burnFee
    ) public onlyRole(DEFAULT_ADMIN_ROLE) {
        if (
            _protocolFee + _burnFee >= PERCENT_DENOMINATOR ||
            _protocolFee == 0 ||
            _burnFee == 0
        ) {
            revert InvalidWithdrawFee(_protocolFee, _burnFee);
        }
        protocolFee = _protocolFee;
        burnFee = _burnFee;
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
        (uint256 usdeReserve, uint256 pawReserve, ) = getReserves();
        price = (usdeReserve * 1e8) / pawReserve;
    }
    // The following functions are overrides required by Solidity.

    function _update(
        address from,
        address to,
        uint256 value
    ) internal override(ERC20, ERC20Pausable, ERC20Votes) {
        super._update(from, to, value);
    }

    function nonces(
        address owner
    ) public view override(ERC20Permit, Nonces) returns (uint256) {
        return super.nonces(owner);
    }
}
