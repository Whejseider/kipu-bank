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

/**
 * @title IUniswapV2Router02
 * @notice Interface for Uniswap V2 Router
 */
interface IUniswapV2Router02 {
    function swapExactTokensForTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);

    function swapExactETHForTokens(
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external payable returns (uint[] memory amounts);

    function getAmountsOut(uint amountIn, address[] calldata path)
        external
        view
        returns (uint[] memory amounts);

    function WETH() external pure returns (address);
}

/**
 * @title KipuBankV3
 * @author Whejseider - Franco Vallone
 * @notice DeFi bank with Uniswap V2 integration for multi-token deposits
 * @dev Implements AccessControl, ReentrancyGuard, and automatic token swapping to USDC
 * @custom:security Follows checks-effects-interactions pattern and uses SafeERC20
 */
contract KipuBankV3 is AccessControl, ReentrancyGuard {
    /*///////////////////////////////////
          Type Declarations
    ///////////////////////////////////*/

    using SafeERC20 for IERC20;

    /// @notice Struct to store deposit and withdrawal statistics
    struct Statistics {
        uint256 totalDeposits;
        uint256 totalWithdrawals;
    }

    /*///////////////////////////////////
          Role Definitions
    ///////////////////////////////////*/

    /// @notice Role identifier for administrators
    bytes32 public constant ADMIN_ROLE = keccak256("ADMIN_ROLE");
    
    /// @notice Role identifier for operators who can manage settings
    bytes32 public constant OPERATOR_ROLE = keccak256("OPERATOR_ROLE");

    /*///////////////////////////////////
          Uniswap Integration
    ///////////////////////////////////*/

    /// @notice Uniswap V2 Router for token swaps
    IUniswapV2Router02 public immutable uniswapRouter;

    /// @notice WETH address from Uniswap Router
    address public immutable WETH;

    /*///////////////////////////////////
          Constants
    ///////////////////////////////////*/

    /// @notice Native token address representation (address(0) represents ETH)
    address public constant NATIVE_TOKEN = address(0);
    
    /// @notice USDC token address
    IERC20 public immutable usdc;
    
    /// @notice USDC decimals
    uint8 public constant USDC_DECIMALS = 6;
    
    /// @notice Slippage tolerance in basis points (50 = 0.5%)
    uint256 public constant SLIPPAGE_TOLERANCE = 50;

    /// @notice Swap deadline buffer in seconds
    uint256 public constant DEADLINE_BUFFER = 300; // 5 minutes

    /*///////////////////////////////////
          State Variables
    ///////////////////////////////////*/

    /// @notice Mapping: user => balance in USDC (6 decimals)
    mapping(address user => uint256 balance) private vaults;

    /// @notice Global statistics tracker
    Statistics private statistics;

    /// @notice Withdrawal limit per transaction in USDC (6 decimals)
    uint256 public withdrawalThresholdUSD;

    /// @notice Global bank capacity limit in USDC (6 decimals)
    uint256 public bankCapUSD;

    /// @notice Total value deposited in USDC (6 decimals)
    uint256 public totalValueLockedUSD;

    /// @notice Emergency pause flag
    bool public paused;

    /*///////////////////////////////////
          Events
    ///////////////////////////////////*/

    /// @notice Emitted when a deposit is successful
    event DepositSuccessful(
        address indexed user,
        address indexed tokenIn,
        uint256 amountIn,
        uint256 usdcReceived
    );

    /// @notice Emitted when a withdrawal is successful
    event WithdrawalSuccessful(
        address indexed user,
        uint256 amount
    );

    /// @notice Emitted when a token swap occurs
    event TokenSwapped(
        address indexed user,
        address indexed tokenIn,
        uint256 amountIn,
        uint256 usdcOut
    );

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
    error WithdrawalExceedsThreshold(uint256 amount, uint256 threshold);

    /// @notice Error when user has insufficient balance
    error InsufficientBalance(uint256 balance, uint256 requested);

    /// @notice Error when deposit exceeds bank capacity
    error BankCapExceeded(uint256 newTotal, uint256 cap);

    /// @notice Error when transfer fails
    error TransferFailed(address token, address to, uint256 amount);

    /// @notice Error when amount is zero
    error ZeroAmount();

    /// @notice Error when contract is paused
    error ContractPaused();

    /// @notice Error when swap fails
    error SwapFailed();

    /// @notice Error when token address is invalid
    error InvalidTokenAddress();

    /// @notice Error when no liquidity path exists
    error NoLiquidityPath();

    /*///////////////////////////////////
          Modifiers
    ///////////////////////////////////*/

    /// @notice Ensures contract is not paused
    modifier whenNotPaused() {
        if (paused) revert ContractPaused();
        _;
    }

    /*///////////////////////////////////
          Constructor
    ///////////////////////////////////*/

    /**
     * @notice Initializes the KipuBankV3 contract
     * @param _bankCapUSD Bank capacity in USDC (6 decimals)
     * @param _withdrawalThresholdUSD Withdrawal threshold in USDC (6 decimals)
     * @param _uniswapRouter Uniswap V2 Router address
     * @param _usdc USDC token address
     */
    constructor(
        uint256 _bankCapUSD,
        uint256 _withdrawalThresholdUSD,
        address _uniswapRouter,
        address _usdc
    ) {
        if (_uniswapRouter == address(0) || _usdc == address(0)) {
            revert InvalidTokenAddress();
        }

        bankCapUSD = _bankCapUSD;
        withdrawalThresholdUSD = _withdrawalThresholdUSD;
        uniswapRouter = IUniswapV2Router02(_uniswapRouter);
        usdc = IERC20(_usdc);
        WETH = uniswapRouter.WETH();

        // Setup roles
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _grantRole(ADMIN_ROLE, msg.sender);
        _grantRole(OPERATOR_ROLE, msg.sender);
    }

    /*///////////////////////////////////
          Receive & Fallback
    ///////////////////////////////////*/

    /// @notice Receives ETH and processes as deposit
    receive() external payable whenNotPaused {
        _depositETH();
    }

    /// @notice Fallback function for ETH deposits
    fallback() external payable whenNotPaused {
        if (msg.value > 0) {
            _depositETH();
        }
    }

    /*///////////////////////////////////
          External Functions
    ///////////////////////////////////*/

    /**
     * @notice Deposits native ETH and swaps to USDC
     */
    function depositETH() 
        external 
        payable 
        whenNotPaused 
        nonReentrant 
    {
        if (msg.value == 0) revert ZeroAmount();
        _depositETH();
    }

    /**
     * @notice Deposits USDC directly without swap
     * @param amount Amount of USDC to deposit (6 decimals)
     */
    function depositUSDC(uint256 amount)
        external
        whenNotPaused
        nonReentrant
    {
        if (amount == 0) revert ZeroAmount();

        // Transfer USDC from user to contract
        usdc.safeTransferFrom(msg.sender, address(this), amount);

        // Check bank cap
        uint256 newTotalUSD = totalValueLockedUSD + amount;
        if (newTotalUSD > bankCapUSD) {
            revert BankCapExceeded(newTotalUSD, bankCapUSD);
        }

        // Update state
        vaults[msg.sender] += amount;
        totalValueLockedUSD = newTotalUSD;
        statistics.totalDeposits++;

        emit DepositSuccessful(msg.sender, address(usdc), amount, amount);
    }

    /**
     * @notice Deposits any ERC20 token and swaps to USDC via Uniswap V2
     * @param token Address of the ERC20 token
     * @param amount Amount of tokens to deposit
     */
    function depositToken(address token, uint256 amount)
        external
        whenNotPaused
        nonReentrant
    {
        if (amount == 0) revert ZeroAmount();
        if (token == address(0)) revert InvalidTokenAddress();
        uint256 newTotalUSD;
        
        // If token is USDC, use direct deposit
        if (token == address(usdc)) {
            usdc.safeTransferFrom(msg.sender, address(this), amount);

            newTotalUSD = totalValueLockedUSD + amount; 
            if (newTotalUSD > bankCapUSD) {
                revert BankCapExceeded(newTotalUSD, bankCapUSD);
            }

            vaults[msg.sender] += amount;
            totalValueLockedUSD = newTotalUSD;
            statistics.totalDeposits++;

            emit DepositSuccessful(msg.sender, address(usdc), amount, amount);
            return;
        }

        // Transfer tokens from user to contract
        IERC20(token).safeTransferFrom(msg.sender, address(this), amount);

        // Swap to USDC
        uint256 usdcReceived = _swapTokenToUSDC(token, amount);

        // Check bank cap after swap
        newTotalUSD = totalValueLockedUSD + usdcReceived; 
        if (newTotalUSD > bankCapUSD) {
            revert BankCapExceeded(newTotalUSD, bankCapUSD);
        }

        // Update state
        vaults[msg.sender] += usdcReceived;
        totalValueLockedUSD = newTotalUSD;
        statistics.totalDeposits++;

        emit DepositSuccessful(msg.sender, token, amount, usdcReceived);
    }

    /**
     * @notice Withdraws USDC from the bank
     * @param amount Amount of USDC to withdraw (6 decimals)
     */
    function withdraw(uint256 amount)
        external
        whenNotPaused
        nonReentrant
    {
        if (amount == 0) revert ZeroAmount();

        // Check withdrawal threshold
        if (amount > withdrawalThresholdUSD) {
            revert WithdrawalExceedsThreshold(amount, withdrawalThresholdUSD);
        }

        // Check user balance
        uint256 userBalance = vaults[msg.sender];
        if (amount > userBalance) {
            revert InsufficientBalance(userBalance, amount);
        }

        // Update state (effects)
        vaults[msg.sender] = userBalance - amount;
        totalValueLockedUSD -= amount;
        statistics.totalWithdrawals++;

        // Transfer USDC (interactions)
        usdc.safeTransfer(msg.sender, amount);

        emit WithdrawalSuccessful(msg.sender, amount);
    }

    /*///////////////////////////////////
          Admin Functions
    ///////////////////////////////////*/

    /**
     * @notice Updates the bank capacity
     * @param newBankCapUSD New bank cap in USDC (6 decimals)
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
     * @param newThresholdUSD New threshold in USDC (6 decimals)
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

    /**
     * @notice Emergency function to recover stuck tokens
     * @param token Address of token to recover (address(0) for ETH)
     * @param amount Amount to recover
     */
    function emergencyWithdraw(address token, uint256 amount) 
        external 
        onlyRole(ADMIN_ROLE) 
    {
        if (token == address(0)) {
            // Recover ETH
            (bool success, ) = msg.sender.call{value: amount}("");
            if (!success) revert TransferFailed(token, msg.sender, amount);
        } else {
            // Recover ERC20
            IERC20(token).safeTransfer(msg.sender, amount);
        }
    }

    /*///////////////////////////////////
          Internal Functions
    ///////////////////////////////////*/

    /**
     * @notice Internal function to process ETH deposits
     */
    function _depositETH() internal {
        // Swap ETH to USDC
        uint256 usdcReceived = _swapETHToUSDC(msg.value);

        // Check bank cap after swap
        uint256 newTotalUSD = totalValueLockedUSD + usdcReceived;
        if (newTotalUSD > bankCapUSD) {
            revert BankCapExceeded(newTotalUSD, bankCapUSD);
        }

        // Update state
        vaults[msg.sender] += usdcReceived;
        totalValueLockedUSD = newTotalUSD;
        statistics.totalDeposits++;

        emit DepositSuccessful(msg.sender, NATIVE_TOKEN, msg.value, usdcReceived);
    }

    /**
     * @notice Swaps ETH to USDC via Uniswap V2
     * @param ethAmount Amount of ETH to swap
     * @return usdcAmount Amount of USDC received
     */
    function _swapETHToUSDC(uint256 ethAmount) 
        internal 
        returns (uint256 usdcAmount) 
    {
        // Create path: WETH -> USDC
        address[] memory path = new address[](2);
        path[0] = WETH;
        path[1] = address(usdc);

        // Get expected output and verify liquidity exists
        uint[] memory amountsOut = uniswapRouter.getAmountsOut(ethAmount, path);
        uint256 expectedUSDC = amountsOut[1];
        
        if (expectedUSDC == 0) revert NoLiquidityPath();

        // Calculate minimum output with slippage
        uint256 minUSDC = (expectedUSDC * (10000 - SLIPPAGE_TOLERANCE)) / 10000;

        // Execute swap
        uint[] memory amounts = uniswapRouter.swapExactETHForTokens{value: ethAmount}(
            minUSDC,
            path,
            address(this),
            block.timestamp + DEADLINE_BUFFER
        );

        usdcAmount = amounts[1];
        if (usdcAmount == 0) revert SwapFailed();

        emit TokenSwapped(msg.sender, NATIVE_TOKEN, ethAmount, usdcAmount);
    }

    /**
     * @notice Swaps any token to USDC via Uniswap V2
     * @dev Tries direct path first (Token->USDC), then via WETH (Token->WETH->USDC)
     * @param token Address of token to swap
     * @param amount Amount of tokens to swap
     * @return usdcAmount Amount of USDC received
     */
    function _swapTokenToUSDC(address token, uint256 amount) 
        internal 
        returns (uint256 usdcAmount) 
    {
        // Approve Uniswap router
        IERC20(token).forceApprove(address(uniswapRouter), amount);

        // Try to find best path
        address[] memory path;
        uint256 expectedUSDC;
        
        // Try direct path first: Token -> USDC
        address[] memory directPath = new address[](2);
        directPath[0] = token;
        directPath[1] = address(usdc);
        
        try uniswapRouter.getAmountsOut(amount, directPath) returns (uint[] memory amountsOut) {
            if (amountsOut[1] > 0) {
                path = directPath;
                expectedUSDC = amountsOut[1];
            }
        } catch {
            // Direct path failed, try via WETH
        }
        
        // If direct path didn't work or gave 0, try via WETH: Token -> WETH -> USDC
        if (expectedUSDC == 0 && token != WETH) {
            address[] memory wethPath = new address[](3);
            wethPath[0] = token;
            wethPath[1] = WETH;
            wethPath[2] = address(usdc);
            
            try uniswapRouter.getAmountsOut(amount, wethPath) returns (uint[] memory amountsOut) {
                if (amountsOut[2] > 0) {
                    path = wethPath;
                    expectedUSDC = amountsOut[2];
                }
            } catch {
                // Both paths failed
            }
        }
        
        // If no valid path found, revert
        if (expectedUSDC == 0) revert NoLiquidityPath();

        // Calculate minimum output with slippage
        uint256 minUSDC = (expectedUSDC * (10000 - SLIPPAGE_TOLERANCE)) / 10000;

        // Execute swap
        uint[] memory amounts = uniswapRouter.swapExactTokensForTokens(
            amount,
            minUSDC,
            path,
            address(this),
            block.timestamp + DEADLINE_BUFFER
        );

        // Get final USDC amount (last element in amounts array)
        usdcAmount = amounts[amounts.length - 1];
        if (usdcAmount == 0) revert SwapFailed();

        emit TokenSwapped(msg.sender, token, amount, usdcAmount);
    }

    /*///////////////////////////////////
          View Functions
    ///////////////////////////////////*/

    /**
     * @notice Returns user's USDC balance
     * @param user User address
     * @return balance Balance in USDC (6 decimals)
     */
    function getUserBalance(address user)
        external
        view
        returns (uint256 balance)
    {
        return vaults[user];
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
     * @notice Returns total value locked in USDC
     */
    function getTotalValueLocked() external view returns (uint256) {
        return totalValueLockedUSD;
    }

    /**
     * @notice Preview how much USDC you would get for ETH
     * @param ethAmount Amount of ETH (18 decimals)
     * @return usdcAmount Expected USDC amount (6 decimals)
     */
    function previewETHToUSDC(uint256 ethAmount) 
        external 
        view 
        returns (uint256 usdcAmount) 
    {
        address[] memory path = new address[](2);
        path[0] = WETH;
        path[1] = address(usdc);
        
        uint[] memory amountsOut = uniswapRouter.getAmountsOut(ethAmount, path);
        return amountsOut[1];
    }

    /**
     * @notice Preview how much USDC you would get for a token
     * @dev Tries direct path first, then via WETH
     * @param token Token address
     * @param amount Token amount
     * @return usdcAmount Expected USDC amount (6 decimals)
     */
    function previewTokenToUSDC(address token, uint256 amount) 
        external 
        view 
        returns (uint256 usdcAmount) 
    {
        if (token == address(usdc)) return amount;
        
        // Try direct path
        address[] memory directPath = new address[](2);
        directPath[0] = token;
        directPath[1] = address(usdc);
        
        try uniswapRouter.getAmountsOut(amount, directPath) returns (uint[] memory amountsOut) {
            if (amountsOut[1] > 0) {
                return amountsOut[1];
            }
        } catch {}
        
        // Try via WETH
        if (token != WETH) {
            address[] memory wethPath = new address[](3);
            wethPath[0] = token;
            wethPath[1] = WETH;
            wethPath[2] = address(usdc);
            
            try uniswapRouter.getAmountsOut(amount, wethPath) returns (uint[] memory amountsOut) {
                return amountsOut[2];
            } catch {}
        }
        
        return 0; // No path found
    }
}