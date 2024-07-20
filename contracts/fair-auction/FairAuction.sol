// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import "../interfaces/IWETH.sol";

contract FairAuction is Ownable, ReentrancyGuard {
    using SafeERC20 for IERC20;
    using Address for address;

    struct UserInfo {
        uint256 allocation; // amount taken into account to obtain TOKEN (amount spent + discount)
        uint256 contribution; // amount spent to buy TOKEN
        uint256 discount; // discount % for this user
        uint256 discountEligibleAmount; // max contribution amount eligible for a discount
        address ref; // referral for this account
        uint256 refEarnings; // referral earnings made by this account
        uint256 claimedRefEarnings; // amount of claimed referral earnings
        bool hasClaimed; // has already claimed its allocation
    }

    IERC20 public immutable PROJECT_TOKEN; // Project token contract
    IERC20 public immutable SALE_TOKEN; // token used to participate
    IERC20 public immutable LP_TOKEN; // Project LP address

    uint256 public immutable START_TIME; // sale start time
    uint256 public immutable END_TIME; // sale end time
    uint256 public immutable CLAIM_TIME; // claim time

    uint256 public constant REFERRAL_SHARE = 3; // 3%

    mapping(address => UserInfo) public userInfo; // buyers and referrers info
    uint256 public totalRaised; // raised amount, does not take into account referral shares
    uint256 public totalAllocation; // takes into account discounts

    uint256 public immutable MAX_PROJECT_TOKENS_TO_DISTRIBUTE; // max PROJECT_TOKEN amount to distribute during the sale
    uint256 public immutable MIN_TOTAL_RAISED_FOR_MAX_PROJECT_TOKEN; // amount to reach to distribute max PROJECT_TOKEN amount

    uint256 public immutable MAX_RAISE_AMOUNT;
    uint256 public immutable CAP_PER_WALLET;

    address public immutable treasury; // treasury multisig, will receive raised amount

    bool public unsoldTokensBurnt;

    bool public forceClaimable; // safety measure to ensure that we can force claimable to true in case awaited LP token address plan change during the sale

    address public weth;

    constructor(
        IERC20 projectToken,
        IERC20 saleToken,
        IERC20 lpToken,
        address _weth,
        uint256 startTime,
        uint256 endTime,
        uint256 claimTime,
        address treasury_,
        uint256 maxToDistribute,
        uint256 minToRaise,
        uint256 maxToRaise,
        uint256 capPerWallet
    ) Ownable(msg.sender) {
        require(startTime < endTime, "invalid dates");
        require(treasury_ != address(0), "invalid treasury");

        PROJECT_TOKEN = projectToken;
        SALE_TOKEN = saleToken;
        LP_TOKEN = lpToken;
        weth = _weth;
        START_TIME = startTime;
        END_TIME = endTime;
        CLAIM_TIME = claimTime;
        treasury = treasury_;
        MAX_PROJECT_TOKENS_TO_DISTRIBUTE = maxToDistribute;
        MIN_TOTAL_RAISED_FOR_MAX_PROJECT_TOKEN = minToRaise;
        if (maxToRaise == 0) {
            maxToRaise = type(uint256).max;
        }
        MAX_RAISE_AMOUNT = maxToRaise;
        if (capPerWallet == 0) {
            capPerWallet = type(uint256).max;
        }
        CAP_PER_WALLET = capPerWallet;
    }

    /********************************************/
    /****************** EVENTS ******************/
    /********************************************/

    event Buy(address indexed user, uint256 amount);
    event ClaimRefEarnings(address indexed user, uint256 amount);
    event Claim(address indexed user, uint256 amount);
    event NewRefEarning(address referrer, uint256 amount);
    event DiscountUpdated();
    event EmergencyWithdraw(address token, uint256 amount);

    /***********************************************/
    /****************** MODIFIERS ******************/
    /***********************************************/

    //  receive() external payable() {
    //    require(address(saleToken) == weth, "non ETH sale");
    //  }

    /**
     * @dev Check whether the sale is currently active
     *
     * Will be marked as inactive if PROJECT_TOKEN has not been deposited into the contract
     */
    modifier isSaleActive() {
        require(
            hasStarted() &&
                !hasEnded() &&
                PROJECT_TOKEN.balanceOf(address(this)) >=
                MAX_PROJECT_TOKENS_TO_DISTRIBUTE,
            "isActive: sale is not active"
        );
        _;
    }

    /**
     * @dev Check whether users can claim their purchased PROJECT_TOKEN
     *
     * Sale must have ended, and LP tokens must have been formed
     */
    modifier isClaimable() {
        require(hasEnded(), "isClaimable: sale has not ended");
        require(
            _currentBlockTimestamp() >= CLAIM_TIME,
            "isClaimable: claim time not reached"
        );
        if (LP_TOKEN == IERC20(address(0))) {
            require(forceClaimable, "isClaimable: no LP tokens");
        }
        require(
            LP_TOKEN.totalSupply() > 0 || forceClaimable,
            "isClaimable: no LP tokens"
        );
        _;
    }

    /**************************************************/
    /****************** PUBLIC VIEWS ******************/
    /**************************************************/

    /**
     * @dev Get remaining duration before the end of the sale
     */
    function getRemainingTime() external view returns (uint256) {
        if (hasEnded()) return 0;
        return END_TIME - _currentBlockTimestamp();
    }

    /**
     * @dev Returns whether the sale has already started
     */
    function hasStarted() public view returns (bool) {
        return _currentBlockTimestamp() >= START_TIME;
    }

    /**
     * @dev Returns whether the sale has already ended
     */
    function hasEnded() public view returns (bool) {
        return END_TIME <= _currentBlockTimestamp();
    }

    /**
     * @dev Returns the amount of PROJECT_TOKEN to be distributed based on the current total raised
     */
    function tokensToDistribute() public view returns (uint256) {
        if (MIN_TOTAL_RAISED_FOR_MAX_PROJECT_TOKEN > totalRaised) {
            return
                (MAX_PROJECT_TOKENS_TO_DISTRIBUTE * totalRaised) /
                MIN_TOTAL_RAISED_FOR_MAX_PROJECT_TOKEN;
        }
        return MAX_PROJECT_TOKENS_TO_DISTRIBUTE;
    }

    /**
     * @dev Get user share times 1e5
     */
    function getExpectedClaimAmount(
        address account
    ) public view returns (uint256) {
        if (totalAllocation == 0) return 0;

        UserInfo memory user = userInfo[account];
        return (user.allocation * tokensToDistribute()) / totalAllocation;
    }

    /****************************************************************/
    /****************** EXTERNAL PUBLIC FUNCTIONS  ******************/
    /****************************************************************/

    function buyETH(
        address referralAddress
    ) external payable isSaleActive nonReentrant {
        require(address(SALE_TOKEN) == weth, "non ETH sale");
        uint256 amount = msg.value;
        IWETH(weth).deposit{value: amount}();
        _buy(amount, referralAddress);
    }

    /**
     * @dev Purchase an allocation for the sale for a value of "amount" SALE_TOKEN, referred by "referralAddress"
     */
    function buy(
        uint256 amount,
        address referralAddress
    ) external isSaleActive nonReentrant {
        SALE_TOKEN.safeTransferFrom(msg.sender, address(this), amount);
        _buy(amount, referralAddress);
    }

    function _buy(uint256 amount, address referralAddress) internal {
        require(amount > 0, "buy: zero amount");
        require(
            totalRaised + amount <= MAX_RAISE_AMOUNT,
            "buy: hardcap reached"
        );
        require(msg.sender == tx.origin, "FORBIDDEN");

        uint256 participationAmount = amount;
        UserInfo storage user = userInfo[msg.sender];
        require(
            user.contribution + amount <= CAP_PER_WALLET,
            "buy: wallet cap reached"
        );

        // handle user's referral
        if (
            user.allocation == 0 &&
            user.ref == address(0) &&
            referralAddress != address(0) &&
            referralAddress != msg.sender
        ) {
            // If first buy, and does not have any ref already set
            user.ref = referralAddress;
        }
        referralAddress = user.ref;

        if (referralAddress != address(0)) {
            UserInfo storage referrer = userInfo[referralAddress];

            // compute and send referrer share
            uint256 refShareAmount = (REFERRAL_SHARE * amount) / 100;

            referrer.refEarnings = referrer.refEarnings + refShareAmount;
            participationAmount = participationAmount - refShareAmount;

            emit NewRefEarning(referralAddress, refShareAmount);
        }

        uint256 allocation = amount;
        if (
            user.discount > 0 && user.contribution < user.discountEligibleAmount
        ) {
            // Get eligible amount for the active user's discount
            uint256 discountEligibleAmount = user.discountEligibleAmount -
                user.contribution;
            if (discountEligibleAmount > amount) {
                discountEligibleAmount = amount;
            }
            // Readjust user new allocation
            allocation =
                allocation +
                (discountEligibleAmount * user.discount) /
                100;
        }

        // update raised amounts
        user.contribution = user.contribution + amount;
        totalRaised = totalRaised + amount;

        // update allocations
        user.allocation = user.allocation + allocation;
        totalAllocation = totalAllocation + allocation;

        emit Buy(msg.sender, amount);
        // transfer contribution to treasury
        SALE_TOKEN.safeTransfer(treasury, participationAmount);
    }

    /**
     * @dev Claim referral earnings
     */
    function claimRefEarnings() public {
        UserInfo storage user = userInfo[msg.sender];
        uint256 toClaim = user.refEarnings - user.claimedRefEarnings;

        if (toClaim > 0) {
            user.claimedRefEarnings = user.claimedRefEarnings + toClaim;

            emit ClaimRefEarnings(msg.sender, toClaim);
            SALE_TOKEN.safeTransfer(msg.sender, toClaim);
        }
    }

    /**
     * @dev Claim purchased PROJECT_TOKEN during the sale
     */
    function claim() external isClaimable {
        UserInfo storage user = userInfo[msg.sender];

        require(
            totalAllocation > 0 && user.allocation > 0,
            "claim: zero allocation"
        );
        require(!user.hasClaimed, "claim: already claimed");
        user.hasClaimed = true;

        uint256 amount = getExpectedClaimAmount(msg.sender);

        emit Claim(msg.sender, amount);

        // send PROJECT_TOKEN allocation
        _safeClaimTransfer(msg.sender, amount);
    }

    /****************************************************************/
    /********************** OWNABLE FUNCTIONS  **********************/
    /****************************************************************/

    struct DiscountSettings {
        address account;
        uint256 discount;
        uint256 eligibleAmount;
    }

    /**
     * @dev Assign custom discounts, used for v1 users
     *
     * Based on saved v1 tokens amounts in our snapshot
     */
    function setUsersDiscount(
        DiscountSettings[] calldata users
    ) public onlyOwner {
        for (uint256 i = 0; i < users.length; ++i) {
            DiscountSettings memory userDiscount = users[i];
            UserInfo storage user = userInfo[userDiscount.account];
            require(userDiscount.discount <= 35, "discount too high");
            user.discount = userDiscount.discount;
            user.discountEligibleAmount = userDiscount.eligibleAmount;
        }

        emit DiscountUpdated();
    }

    /********************************************************/
    /****************** /!\ EMERGENCY ONLY ******************/
    /********************************************************/

    /**
     * @dev Failsafe
     */
    function emergencyWithdrawFunds(
        address token,
        uint256 amount
    ) external onlyOwner {
        IERC20(token).safeTransfer(msg.sender, amount);

        emit EmergencyWithdraw(token, amount);
    }

    function setForceClaimable() external onlyOwner {
        forceClaimable = true;
    }

    /**
     * @dev Burn unsold PROJECT_TOKEN if MIN_TOTAL_RAISED_FOR_MAX_PROJECT_TOKEN has not been reached
     *
     * Must only be called by the owner
     */
    function burnUnsoldTokens() external onlyOwner {
        require(hasEnded(), "burnUnsoldTokens: presale has not ended");
        require(!unsoldTokensBurnt, "burnUnsoldTokens: already burnt");

        uint256 totalSold = tokensToDistribute();
        require(
            totalSold < MAX_PROJECT_TOKENS_TO_DISTRIBUTE,
            "burnUnsoldTokens: no token to burn"
        );

        unsoldTokensBurnt = true;
        PROJECT_TOKEN.transfer(
            0x000000000000000000000000000000000000dEaD,
            MAX_PROJECT_TOKENS_TO_DISTRIBUTE - totalSold
        );
    }

    /********************************************************/
    /****************** INTERNAL FUNCTIONS ******************/
    /********************************************************/

    /**
     * @dev Safe token transfer function, in case rounding error causes contract to not have enough tokens
     */
    function _safeClaimTransfer(address to, uint256 amount) internal {
        uint256 balance = PROJECT_TOKEN.balanceOf(address(this));
        bool transferSuccess = false;

        if (amount > balance) {
            transferSuccess = PROJECT_TOKEN.transfer(to, balance);
        } else {
            transferSuccess = PROJECT_TOKEN.transfer(to, amount);
        }

        require(transferSuccess, "safeClaimTransfer: Transfer failed");
    }

    /**
     * @dev Utility function to get the current block timestamp
     */
    function _currentBlockTimestamp() internal view virtual returns (uint256) {
        return block.timestamp;
    }
}
