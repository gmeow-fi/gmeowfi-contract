// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";
import "../interfaces/IGmeowFiMultiNFT.sol";

contract GMeowFiMultiNFTSale is AccessControl {
    using EnumerableSet for EnumerableSet.AddressSet;

    uint256 public constant MEOW_CHRONICLES_ID = 0;

    EnumerableSet.AddressSet private _buyers;
    mapping(address => uint256) public buyerToAmount;

    address payable public devWallet;
    address public gmeowFiMultiNFT;
    uint256 public price;
    uint256 public totalSupply;
    uint256 public totalSold;

    struct Buyer {
        address buyer;
        uint256 amount;
    }

    event Buy(address indexed buyer, uint256 amount);

    constructor(
        address _gmeowFiMultiNFT,
        address payable _devWallet,
        uint256 _price,
        uint256 _totalSupply
    ) {
        _grantRole(DEFAULT_ADMIN_ROLE, _msgSender());
        gmeowFiMultiNFT = _gmeowFiMultiNFT;
        devWallet = _devWallet;
        price = _price;
        totalSupply = _totalSupply;
    }

    function buy(uint256 amount) public payable {
        require(
            totalSold + amount <= totalSupply,
            "GMeowFiMultiNFTSale: sold out"
        );
        require(
            msg.value == price * amount,
            "GMeowFiMultiNFTSale: invalid price"
        );
        devWallet.transfer(msg.value);

        buyerToAmount[msg.sender] += amount;
        totalSold += amount;
        _buyers.add(msg.sender);

        IGmeowFiMultiNFT(gmeowFiMultiNFT).mint(
            msg.sender,
            MEOW_CHRONICLES_ID,
            amount,
            ""
        );
        emit Buy(msg.sender, amount);
    }

    function getBuyers(
        uint256 offset,
        uint256 limit
    ) public view returns (Buyer[] memory) {
        uint256 length = _buyers.length();
        if (length == 0) {
            return new Buyer[](0);
        }
        uint256 end = offset + limit > length ? length : offset + limit;
        Buyer[] memory result = new Buyer[](end - offset);
        for (uint256 i = offset; i < end; i++) {
            address buyer = _buyers.at(i);
            result[i - offset] = Buyer(buyer, buyerToAmount[buyer]);
        }
        return result;
    }

    function buyersLength() public view returns (uint256) {
        return _buyers.length();
    }

    function setGmeowFiMultiNFT(
        address _gmeowFiMultiNFT
    ) public onlyRole(DEFAULT_ADMIN_ROLE) {
        gmeowFiMultiNFT = _gmeowFiMultiNFT;
    }

    function setTotalSupply(
        uint256 _totalSupply
    ) public onlyRole(DEFAULT_ADMIN_ROLE) {
        totalSupply = _totalSupply;
    }

    function setPrice(uint256 _price) public onlyRole(DEFAULT_ADMIN_ROLE) {
        price = _price;
    }

    function setDevWallet(
        address payable _devWallet
    ) public onlyRole(DEFAULT_ADMIN_ROLE) {
        devWallet = _devWallet;
    }
}
