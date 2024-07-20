// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

interface IPAW is IERC20 {
    function getPrice() external view returns (uint256 price);
    function deposit(uint256 amount) external;
}
