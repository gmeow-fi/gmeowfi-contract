// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/utils/Pausable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";

contract Faucet is Pausable, Ownable {
    using EnumerableSet for EnumerableSet.AddressSet;

    struct TokenConfig {
        address token;
        uint256 faucetAmount;
    }

    mapping(address => TokenConfig) public tokenConfigs;
    EnumerableSet.AddressSet private tokens;
    mapping(address => uint256) public lastClaimed;
    uint256 public claimInterval = 1 days;

    event Claimed(address indexed user, TokenConfig[] tokens);

    constructor(
        TokenConfig[] memory _tokenConfigs,
        uint256 _claimInterval
    ) Ownable(msg.sender) {
        for (uint256 i = 0; i < _tokenConfigs.length; i++) {
            TokenConfig memory tokenConfig = _tokenConfigs[i];
            tokens.add(tokenConfig.token);
            tokenConfigs[tokenConfig.token] = tokenConfig;
        }
        claimInterval = _claimInterval;
    }

    function claim() public whenNotPaused {
        require(!_isContract(msg.sender), "Faucet: contract not allowed");
        require(
            lastClaimed[msg.sender] + claimInterval < block.timestamp,
            "Faucet: claim interval not passed"
        );

        for (uint256 i = 0; i < tokens.length(); i++) {
            address token = tokens.at(i);
            TokenConfig memory tokenConfig = tokenConfigs[token];
            IERC20(token).transfer(msg.sender, tokenConfig.faucetAmount);
        }
        emit Claimed(msg.sender, getTokens());
    }

    function setClaimInterval(uint256 _claimInterval) public onlyOwner {
        claimInterval = _claimInterval;
    }

    function addToken(TokenConfig memory tokenConfig) public onlyOwner {
        tokens.add(tokenConfig.token);
        tokenConfigs[tokenConfig.token] = tokenConfig;
    }

    function removeToken(address token) public onlyOwner {
        tokens.remove(token);
        delete tokenConfigs[token];
    }

    function emergencyWithdraw(address token, address to) public onlyOwner {
        IERC20(token).transfer(to, IERC20(token).balanceOf(address(this)));
    }

    function getTokens() public view returns (TokenConfig[] memory) {
        TokenConfig[] memory _tokens = new TokenConfig[](tokens.length());
        for (uint256 i = 0; i < tokens.length(); i++) {
            address token = tokens.at(i);
            _tokens[i] = tokenConfigs[token];
        }
        return _tokens;
    }

    function pause() public onlyOwner {
        _pause();
    }

    function unpause() public onlyOwner {
        _unpause();
    }

    function _isContract(address _addr) private view returns (bool) {
        uint32 size;
        assembly {
            size := extcodesize(_addr)
        }
        return (size > 0);
    }
}
