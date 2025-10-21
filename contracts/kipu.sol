// SPDX-License-Identifier: MIT
pragma solidity 0.8.30;

/*///////////////////////////////////
        Imports
///////////////////////////////////*/
import {AccessControl} from "@openzeppelin/contracts/access/AccessControl.sol";
import {ReentrancyGuard} from "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

/*///////////////////////////////////
        Libraries
///////////////////////////////////*/
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

/*///////////////////////////////////
        Interfaces
///////////////////////////////////*/
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";

/**
 * @title KipuBank
 * @author Whejseider - Franco Vallone
 * @notice Production-ready multi-token bank with Chainlink price feeds and role-based access control
 * @dev Implements AccessControl, ReentrancyGuard, and supports native ETH and ERC20 tokens
 * @custom:security Follows checks-effects-interactions pattern and uses SafeERC20
 */
contract KipuBank is AccessControl, ReentrancyGuard {
    /*///////////////////////////////////
          Type Declarations
///////////////////////////////////*/

    using SafeERC20 for IERC20;

    /// @notice Struct to store deposit and withdrawal statistics
    struct Statistics {
        uint256 totalDeposits;
        uint256 totalWithdrawals;
    }

    /// @notice Struct to store token configuration
    struct TokenConfig {
        bool isSupported;
        uint8 decimals;
        AggregatorV3Interface priceFeed;
    }

    /*///////////////////////////////////
          Role Definitions
///////////////////////////////////*/

    /// @notice Role identifier for administrators
    bytes32 public constant ADMIN_ROLE = keccak256("ADMIN_ROLE");
    
    /// @notice Role identifier for operators who can manage tokens
    bytes32 public constant OPERATOR_ROLE = keccak256("OPERATOR_ROLE");

    /*///////////////////////////////////
          Chainlink Oracle
///////////////////////////////////*/

    /// @notice Chainlink price feed for ETH/USD
    AggregatorV3Interface public immutable ethUsdPriceFeed;

    /*///////////////////////////////////
          Constants
///////////////////////////////////*/

    /// @notice Native token address representation (address(0) represents ETH)
    address public constant NATIVE_TOKEN = address(0);
    
    /// @notice USDC decimals used for internal accounting
    uint8 public constant USDC_DECIMALS = 6;
    
    /// @notice Precision multiplier for price calculations
    uint256 private constant PRICE_PRECISION = 1e18;

    /*///////////////////////////////////
          State Variables
///////////////////////////////////*/

    /// @notice Nested mapping: user => token => balance (in USDC decimals)
    mapping(address user => mapping(address token => uint256 balance)) private vaults;

    /// @notice Mapping to track supported tokens and their configurations
    mapping(address token => TokenConfig config) private tokenConfigs;

    /// @notice Global statistics tracker
    Statistics private statistics;

    /// @notice Withdrawal limit per transaction in USD (6 decimals)
    uint256 public withdrawalThresholdUSD;

    /// @notice Global bank capacity limit in USD (6 decimals)
    uint256 public bankCapUSD;

    /// @notice Total value deposited across all tokens in USD (6 decimals)
    uint256 public totalValueLockedUSD;

    /// @notice Emergency pause flag
    bool public paused;

    /*///////////////////////////////////
          Events
///////////////////////////////////*/

    /// @notice Emitted when a deposit is successful
    event DepositSuccessful(
        address indexed user,
        address indexed token,
        uint256 amount,
        uint256 valueUSD
    );

    /// @notice Emitted when a withdrawal is successful
    event WithdrawalSuccessful(
        address indexed user,
        address indexed token,
        uint256 amount,
        uint256 valueUSD
    );

    /// @notice Emitted when a new token is added
    event TokenAdded(
        address indexed token,
        uint8 decimals,
        address priceFeed
    );

    /// @notice Emitted when a token is removed
    event TokenRemoved(address indexed token);

    /// @notice Emitted when bank cap is updated
    event BankCapUpdated(uint256 oldCap, uint256 newCap);

    /// @notice Emitted when withdrawal threshold is updated
    event WithdrawalThresholdUpdated(uint256 oldThreshold, uint256 newThreshold);

    /// @notice Emitted when contract is paused/unpaused
    event PauseToggled(bool isPaused);

    /*///////////////////////////////////
          Errors
///////////////////////////////////*/

    /// @notice Error when trying to withdraw more than allowed
    error WithdrawalExceedsThreshold(uint256 amountUSD, uint256 thresholdUSD);

    /// @notice Error when user has insufficient balance
    error InsufficientBalance(uint256 balance, uint256 requested);

    /// @notice Error when deposit exceeds bank capacity
    error BankCapExceeded(uint256 newTotal, uint256 cap);

    /// @notice Error when transfer fails
    error TransferFailed(address token, address to, uint256 amount);

    /// @notice Error when amount is zero
    error ZeroAmount();

    /// @notice Error when token is not supported
    error TokenNotSupported(address token);

    /// @notice Error when token is already supported
    error TokenAlreadySupported(address token);

    /// @notice Error when price feed returns invalid data
    error InvalidPriceData();

    /// @notice Error when contract is paused
    error ContractPaused();

    /// @notice Error when trying to remove native token
    error CannotRemoveNativeToken();

    /*///////////////////////////////////
          Modifiers
///////////////////////////////////*/

    /// @notice Ensures contract is not paused
    modifier whenNotPaused() {
        if (paused) revert ContractPaused();
        _;
    }

    /// @notice Ensures token is supported
    modifier onlySupportedToken(address token) {
        if (!tokenConfigs[token].isSupported) revert TokenNotSupported(token);
        _;
    }

    /*///////////////////////////////////
          Constructor
///////////////////////////////////*/

    /**
     * @notice Initializes the KipuBank contract
     * @param _bankCapUSD Bank capacity in USD (6 decimals)
     * @param _withdrawalThresholdUSD Withdrawal threshold in USD (6 decimals)
     * @param _ethUsdPriceFeed Chainlink ETH/USD price feed address
     */
    constructor(
        uint256 _bankCapUSD,
        uint256 _withdrawalThresholdUSD,
        address _ethUsdPriceFeed
    ) {
        if (_ethUsdPriceFeed == address(0)) revert InvalidPriceData();

        bankCapUSD = _bankCapUSD;
        withdrawalThresholdUSD = _withdrawalThresholdUSD;
        ethUsdPriceFeed = AggregatorV3Interface(_ethUsdPriceFeed);

        // Setup roles
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _grantRole(ADMIN_ROLE, msg.sender);
        _grantRole(OPERATOR_ROLE, msg.sender);

        // Add native ETH support by default
        tokenConfigs[NATIVE_TOKEN] = TokenConfig({
            isSupported: true,
            decimals: 18,
            priceFeed: ethUsdPriceFeed
        });

        emit TokenAdded(NATIVE_TOKEN, 18, _ethUsdPriceFeed);
    }

    /*///////////////////////////////////
          Receive & Fallback
///////////////////////////////////*/

    /// @notice Receives ETH and processes as deposit
    receive() external payable whenNotPaused {
        _processDeposit(NATIVE_TOKEN, msg.value);
    }

    /// @notice Fallback function for ETH deposits
    fallback() external payable whenNotPaused {
        if (msg.value > 0) {
            _processDeposit(NATIVE_TOKEN, msg.value);
        }
    }

    /*///////////////////////////////////
          External Functions
///////////////////////////////////*/

    /**
     * @notice Deposits native ETH into the bank
     */
    function depositETH() 
        external 
        payable 
        whenNotPaused 
        nonReentrant 
    {
        if (msg.value == 0) revert ZeroAmount();
        _processDeposit(NATIVE_TOKEN, msg.value);
    }

    /**
     * @notice Deposits ERC20 tokens into the bank
     * @param token Address of the ERC20 token
     * @param amount Amount of tokens to deposit
     */
    function depositToken(address token, uint256 amount)
        external
        whenNotPaused
        nonReentrant
        onlySupportedToken(token)
    {
        if (amount == 0) revert ZeroAmount();
        if (token == NATIVE_TOKEN) revert TokenNotSupported(token);

        // Transfer tokens from user to contract
        IERC20(token).safeTransferFrom(msg.sender, address(this), amount);

        _processDeposit(token, amount);
    }

    /**
     * @notice Withdraws native ETH from the bank
     * @param amount Amount of ETH to withdraw (in wei)
     */
    function withdrawETH(uint256 amount)
        external
        whenNotPaused
        nonReentrant
    {
        if (amount == 0) revert ZeroAmount();
        _processWithdrawal(NATIVE_TOKEN, amount);
    }

    /**
     * @notice Withdraws ERC20 tokens from the bank
     * @param token Address of the ERC20 token
     * @param amount Amount of tokens to withdraw
     */
    function withdrawToken(address token, uint256 amount)
        external
        whenNotPaused
        nonReentrant
        onlySupportedToken(token)
    {
        if (amount == 0) revert ZeroAmount();
        if (token == NATIVE_TOKEN) revert TokenNotSupported(token);

        _processWithdrawal(token, amount);
    }

    /*///////////////////////////////////
          Admin Functions
///////////////////////////////////*/

    /**
     * @notice Adds support for a new ERC20 token
     * @param token Address of the token
     * @param decimals Token decimals
     * @param priceFeed Chainlink price feed for token/USD
     */
    function addToken(
        address token,
        uint8 decimals,
        address priceFeed
    ) external onlyRole(OPERATOR_ROLE) {
        if (token == NATIVE_TOKEN) revert TokenAlreadySupported(token);
        if (tokenConfigs[token].isSupported) revert TokenAlreadySupported(token);
        if (priceFeed == address(0)) revert InvalidPriceData();

        tokenConfigs[token] = TokenConfig({
            isSupported: true,
            decimals: decimals,
            priceFeed: AggregatorV3Interface(priceFeed)
        });

        emit TokenAdded(token, decimals, priceFeed);
    }

    /**
     * @notice Removes support for a token
     * @param token Address of the token to remove
     */
    function removeToken(address token) external onlyRole(OPERATOR_ROLE) {
        if (token == NATIVE_TOKEN) revert CannotRemoveNativeToken();
        if (!tokenConfigs[token].isSupported) revert TokenNotSupported(token);

        delete tokenConfigs[token];

        emit TokenRemoved(token);
    }

    /**
     * @notice Updates the bank capacity
     * @param newBankCapUSD New bank cap in USD (6 decimals)
     */
    function updateBankCap(uint256 newBankCapUSD) 
        external 
        onlyRole(ADMIN_ROLE) 
    {
        uint256 oldCap = bankCapUSD;
        bankCapUSD = newBankCapUSD;
        emit BankCapUpdated(oldCap, newBankCapUSD);
    }

    /**
     * @notice Updates the withdrawal threshold
     * @param newThresholdUSD New threshold in USD (6 decimals)
     */
    function updateWithdrawalThreshold(uint256 newThresholdUSD)
        external
        onlyRole(ADMIN_ROLE)
    {
        uint256 oldThreshold = withdrawalThresholdUSD;
        withdrawalThresholdUSD = newThresholdUSD;
        emit WithdrawalThresholdUpdated(oldThreshold, newThresholdUSD);
    }

    /**
     * @notice Toggles contract pause state
     */
    function togglePause() external onlyRole(ADMIN_ROLE) {
        paused = !paused;
        emit PauseToggled(paused);
    }

    /*///////////////////////////////////
          Internal Functions
///////////////////////////////////*/

    /**
     * @notice Internal function to process deposits
     * @param token Token address (NATIVE_TOKEN for ETH)
     * @param amount Amount to deposit in token's native decimals
     */
    function _processDeposit(address token, uint256 amount) internal {
        // Get USD value of deposit
        uint256 valueUSD = _convertToUSD(token, amount);

        // Check bank cap
        uint256 newTotalUSD = totalValueLockedUSD + valueUSD;
        if (newTotalUSD > bankCapUSD) {
            revert BankCapExceeded(newTotalUSD, bankCapUSD);
        }

        // Update state (effects)
        vaults[msg.sender][token] += valueUSD;
        totalValueLockedUSD = newTotalUSD;
        statistics.totalDeposits++;

        // Emit event
        emit DepositSuccessful(msg.sender, token, amount, valueUSD);
    }

    /**
     * @notice Internal function to process withdrawals
     * @param token Token address (NATIVE_TOKEN for ETH)
     * @param amount Amount to withdraw in token's native decimals
     */
    function _processWithdrawal(address token, uint256 amount) internal {
        // Get USD value of withdrawal
        uint256 valueUSD = _convertToUSD(token, amount);

        // Check withdrawal threshold
        if (valueUSD > withdrawalThresholdUSD) {
            revert WithdrawalExceedsThreshold(valueUSD, withdrawalThresholdUSD);
        }

        // Check user balance
        uint256 userBalance = vaults[msg.sender][token];
        if (valueUSD > userBalance) {
            revert InsufficientBalance(userBalance, valueUSD);
        }

        // Update state (effects)
        vaults[msg.sender][token] = userBalance - valueUSD;
        totalValueLockedUSD -= valueUSD;
        statistics.totalWithdrawals++;

        // Transfer tokens (interactions)
        _transferAsset(token, msg.sender, amount);

        // Emit event
        emit WithdrawalSuccessful(msg.sender, token, amount, valueUSD);
    }

    /**
     * @notice Transfers assets to user
     * @param token Token address (NATIVE_TOKEN for ETH)
     * @param to Recipient address
     * @param amount Amount to transfer
     */
    function _transferAsset(
        address token,
        address to,
        uint256 amount
    ) private {
        if (token == NATIVE_TOKEN) {
            (bool success, ) = to.call{value: amount}("");
            if (!success) revert TransferFailed(token, to, amount);
        } else {
            IERC20(token).safeTransfer(to, amount);
        }
    }

    /**
     * @notice Converts token amount to USD value (6 decimals)
     * @param token Token address
     * @param amount Amount in token's native decimals
     * @return valueUSD Value in USD with 6 decimals
     */
    function _convertToUSD(address token, uint256 amount)
        internal
        view
        returns (uint256 valueUSD)
    {
        TokenConfig memory config = tokenConfigs[token];

        // Get latest price from Chainlink
        (, int256 price, , , ) = config.priceFeed.latestRoundData();
        if (price <= 0) revert InvalidPriceData();

        uint8 priceFeedDecimals = config.priceFeed.decimals();

        // Convert to USD with proper decimal handling
        // Formula: (amount * price) / (10^tokenDecimals * 10^priceFeedDecimals) * 10^USDC_DECIMALS
        valueUSD = (amount * uint256(price) * (10 ** USDC_DECIMALS)) /
            (10 ** config.decimals * 10 ** priceFeedDecimals);
    }

    /*///////////////////////////////////
          View Functions
///////////////////////////////////*/

    /**
     * @notice Returns user's balance for a specific token in USD
     * @param user User address
     * @param token Token address
     * @return balance Balance in USD (6 decimals)
     */
    function getUserBalance(address user, address token)
        external
        view
        returns (uint256 balance)
    {
        return vaults[user][token];
    }

    /**
     * @notice Returns user's balance in token's native decimals
     * @param user User address
     * @param token Token address
     * @return amount Amount in token's native decimals
     */
    function getUserBalanceInTokens(address user, address token)
        external
        view
        returns (uint256 amount)
    {
        uint256 balanceUSD = vaults[user][token];
        if (balanceUSD == 0) return 0;

        TokenConfig memory config = tokenConfigs[token];
        (, int256 price, , , ) = config.priceFeed.latestRoundData();
        if (price <= 0) revert InvalidPriceData();

        uint8 priceFeedDecimals = config.priceFeed.decimals();

        // Convert USD back to token amount
        // Formula: (balanceUSD * 10^tokenDecimals * 10^priceFeedDecimals) / (price * 10^USDC_DECIMALS)
        amount = (balanceUSD * (10 ** config.decimals) * (10 ** priceFeedDecimals)) /
            (uint256(price) * (10 ** USDC_DECIMALS));
    }

    /**
     * @notice Returns token configuration
     * @param token Token address
     */
    function getTokenConfig(address token)
        external
        view
        returns (bool isSupported, uint8 decimals, address priceFeed)
    {
        TokenConfig memory config = tokenConfigs[token];
        return (
            config.isSupported,
            config.decimals,
            address(config.priceFeed)
        );
    }

    /**
     * @notice Returns current statistics
     */
    function getStatistics()
        external
        view
        returns (uint256 totalDeposits, uint256 totalWithdrawals)
    {
        return (statistics.totalDeposits, statistics.totalWithdrawals);
    }

    /**
     * @notice Returns current ETH price in USD
     */
    function getETHPrice() external view returns (int256 price, uint8 decimals) {
        (, price, , , ) = ethUsdPriceFeed.latestRoundData();
        decimals = ethUsdPriceFeed.decimals();
    }

    /**
     * @notice Returns total value locked in USD
     */
    function getTotalValueLocked() external view returns (uint256) {
        return totalValueLockedUSD;
    }
}