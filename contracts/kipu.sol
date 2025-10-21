// SPDX-License-Identifier: MIT
pragma solidity 0.8.30;

/**
 * @title KipuBank
 * @author Whejseider - Franco Vallone
 * @notice This contract is part of the ETH KIPU course || Module 2 - Solidity Fundamentals
 * @custom:security This is an educational contract and should not be used in production
 */
contract KipuBank {
    /*///////////////////////////////////
          Type declarations
///////////////////////////////////*/

    /// @notice Mapping to store user address and their funds
    mapping(address user => uint256 balance) private vaults;

    /// @notice Struct to store deposit and withdrawal records
    struct Record {
        uint256 numberOfDeposits;
        uint256 numberOfWithdrawals;
    }

    /*///////////////////////////////////
           State variables
///////////////////////////////////*/

    /// @notice State variable to record deposits and withdrawals
    Record private record;

    /// @notice Withdrawal threshold from vault
    uint256 private immutable withdrawalThreshold;

    /// @notice Global deposit limit
    uint256 private immutable bankCap;

    /// @notice Total balance deposited by all users
    uint256 private totalDeposits;

    /*///////////////////////////////////
               Events
///////////////////////////////////*/

    /// @notice Event emitted when a deposit is successful
    event DepositSuccessful(address indexed depositor, uint256 amount);
    
    /// @notice Event emitted when a withdrawal is successful
    event WithdrawalSuccessful(address indexed withdrawer, uint256 amount);

    /*///////////////////////////////////
               Errors
///////////////////////////////////*/

    /// @notice Error when trying to withdraw more than the allowed limit
    error InvalidWithdrawal(uint256 amount, uint256 threshold);

    /// @notice Error when trying to withdraw more than the user has
    error InsufficientBalance(uint256 balance, uint256 amount);

    /// @notice Error if deposit exceeds the global bank limit
    error BankCapExceeded(uint256 amount, uint256 bankCap);

    /// @notice Error if ETH transfer fails
    error TransferFailed(address destination, uint256 amount);

    /// @notice Error when a value cannot be zero or negative
    error ValueCannotBeZeroOrNegative();

    /*///////////////////////////////////
            Modifiers
///////////////////////////////////*/

    /// @notice Verifies that only the vault owner can withdraw funds
    modifier onlyVaultOwner() {
        if (vaults[msg.sender] == 0) {
            revert InsufficientBalance(0, 0);
        }
        _;
    }

    /*///////////////////////////////////
            Functions
///////////////////////////////////*/

    /*/////////////////////////
        constructor
/////////////////////////*/

    constructor(uint256 _bankCap, uint256 _withdrawalThreshold) {
        bankCap = _bankCap;
        withdrawalThreshold = _withdrawalThreshold;
        record.numberOfDeposits = 0;
        record.numberOfWithdrawals = 0;
    }

    /*/////////////////////////
     Receive&Fallback
/////////////////////////*/

    /// @notice Function to receive ether directly and redirect to deposit
    receive() external payable {
        _processDeposit();
    }
    
    /// @notice Fallback function redirects to deposit if ETH is sent
    fallback() external payable {
        if (msg.value > 0) {
            _processDeposit();
        }
    }

    /*/////////////////////////
        external
/////////////////////////*/

    /**
     * @notice Function used to withdraw funds from a vault
     * @param amount - amount of funds to withdraw
     */
    function withdraw(uint256 amount) external onlyVaultOwner {
        if (amount <= 0) revert ValueCannotBeZeroOrNegative();
        if (amount > vaults[msg.sender])
            revert InsufficientBalance(vaults[msg.sender], amount);
        if (amount > withdrawalThreshold)
            revert InvalidWithdrawal(amount, withdrawalThreshold);

        vaults[msg.sender] -= amount;
        totalDeposits -= amount;
        record.numberOfWithdrawals++;

        _transferETH(amount);

        emit WithdrawalSuccessful(msg.sender, amount);
    }

    /**
     * @notice Function used to deposit funds to a vault
     */
    function deposit() external payable {
        _processDeposit();
    }

    /*/////////////////////////
         public
/////////////////////////*/

    /*/////////////////////////
        internal
/////////////////////////*/

    /**
     * @notice Internal function to process deposits
     */
    function _processDeposit() internal {
        if (msg.value <= 0) revert ValueCannotBeZeroOrNegative();
        if (msg.value + totalDeposits > bankCap)
            revert BankCapExceeded(msg.value, bankCap);

        vaults[msg.sender] += msg.value;
        totalDeposits += msg.value;
        record.numberOfDeposits++;

        emit DepositSuccessful(msg.sender, msg.value);
    }

    /*/////////////////////////
        private
/////////////////////////*/

    /**
     * @notice Function used to transfer ETH
     * @param amount - amount of funds to transfer
     */
    function _transferETH(uint256 amount) private {
        (bool success, ) = msg.sender.call{value: amount}("");
        if (!success) revert TransferFailed(msg.sender, amount);
    }

    /*/////////////////////////
      View & Pure
/////////////////////////*/

    /**
     * @notice Returns the user's balance or funds
     * @param user - user's address
     */
    function userBalance(address user) public view returns (uint256) {
        return vaults[user];
    }

    /**
     * @notice Returns the total value of deposits
     */
    function viewTotalDeposits() public view returns (uint256) {
        return totalDeposits;
    }

    /**
     * @notice Returns the bankCap
     */
    function viewBankCap() public view returns (uint256) {
        return bankCap;
    }

    /**
     * @notice Returns record of the number of deposits and withdrawals made
     */
    function viewRecords() public view returns (uint256, uint256) {
        return (record.numberOfDeposits, record.numberOfWithdrawals);
    }

    /**
     * @notice Returns the withdrawal threshold
     */
    function viewWithdrawalThreshold() public view returns (uint256) {
        return withdrawalThreshold;
    }
}