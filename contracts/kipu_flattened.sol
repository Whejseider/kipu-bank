
// File: @openzeppelin/contracts/access/IAccessControl.sol


// OpenZeppelin Contracts (last updated v5.4.0) (access/IAccessControl.sol)

pragma solidity >=0.8.4;

/**
 * @dev External interface of AccessControl declared to support ERC-165 detection.
 */
interface IAccessControl {
    /**
     * @dev The `account` is missing a role.
     */
    error AccessControlUnauthorizedAccount(address account, bytes32 neededRole);

    /**
     * @dev The caller of a function is not the expected one.
     *
     * NOTE: Don't confuse with {AccessControlUnauthorizedAccount}.
     */
    error AccessControlBadConfirmation();

    /**
     * @dev Emitted when `newAdminRole` is set as ``role``'s admin role, replacing `previousAdminRole`
     *
     * `DEFAULT_ADMIN_ROLE` is the starting admin for all roles, despite
     * {RoleAdminChanged} not being emitted to signal this.
     */
    event RoleAdminChanged(bytes32 indexed role, bytes32 indexed previousAdminRole, bytes32 indexed newAdminRole);

    /**
     * @dev Emitted when `account` is granted `role`.
     *
     * `sender` is the account that originated the contract call. This account bears the admin role (for the granted role).
     * Expected in cases where the role was granted using the internal {AccessControl-_grantRole}.
     */
    event RoleGranted(bytes32 indexed role, address indexed account, address indexed sender);

    /**
     * @dev Emitted when `account` is revoked `role`.
     *
     * `sender` is the account that originated the contract call:
     *   - if using `revokeRole`, it is the admin role bearer
     *   - if using `renounceRole`, it is the role bearer (i.e. `account`)
     */
    event RoleRevoked(bytes32 indexed role, address indexed account, address indexed sender);

    /**
     * @dev Returns `true` if `account` has been granted `role`.
     */
    function hasRole(bytes32 role, address account) external view returns (bool);

    /**
     * @dev Returns the admin role that controls `role`. See {grantRole} and
     * {revokeRole}.
     *
     * To change a role's admin, use {AccessControl-_setRoleAdmin}.
     */
    function getRoleAdmin(bytes32 role) external view returns (bytes32);

    /**
     * @dev Grants `role` to `account`.
     *
     * If `account` had not been already granted `role`, emits a {RoleGranted}
     * event.
     *
     * Requirements:
     *
     * - the caller must have ``role``'s admin role.
     */
    function grantRole(bytes32 role, address account) external;

    /**
     * @dev Revokes `role` from `account`.
     *
     * If `account` had been granted `role`, emits a {RoleRevoked} event.
     *
     * Requirements:
     *
     * - the caller must have ``role``'s admin role.
     */
    function revokeRole(bytes32 role, address account) external;

    /**
     * @dev Revokes `role` from the calling account.
     *
     * Roles are often managed via {grantRole} and {revokeRole}: this function's
     * purpose is to provide a mechanism for accounts to lose their privileges
     * if they are compromised (such as when a trusted device is misplaced).
     *
     * If the calling account had been granted `role`, emits a {RoleRevoked}
     * event.
     *
     * Requirements:
     *
     * - the caller must be `callerConfirmation`.
     */
    function renounceRole(bytes32 role, address callerConfirmation) external;
}

// File: @openzeppelin/contracts/utils/Context.sol


// OpenZeppelin Contracts (last updated v5.0.1) (utils/Context.sol)

pragma solidity ^0.8.20;

/**
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }

    function _contextSuffixLength() internal view virtual returns (uint256) {
        return 0;
    }
}

// File: @openzeppelin/contracts/utils/introspection/IERC165.sol


// OpenZeppelin Contracts (last updated v5.4.0) (utils/introspection/IERC165.sol)

pragma solidity >=0.4.16;

/**
 * @dev Interface of the ERC-165 standard, as defined in the
 * https://eips.ethereum.org/EIPS/eip-165[ERC].
 *
 * Implementers can declare support of contract interfaces, which can then be
 * queried by others ({ERC165Checker}).
 *
 * For an implementation, see {ERC165}.
 */
interface IERC165 {
    /**
     * @dev Returns true if this contract implements the interface defined by
     * `interfaceId`. See the corresponding
     * https://eips.ethereum.org/EIPS/eip-165#how-interfaces-are-identified[ERC section]
     * to learn more about how these ids are created.
     *
     * This function call must use less than 30 000 gas.
     */
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
}

// File: @openzeppelin/contracts/utils/introspection/ERC165.sol


// OpenZeppelin Contracts (last updated v5.4.0) (utils/introspection/ERC165.sol)

pragma solidity ^0.8.20;


/**
 * @dev Implementation of the {IERC165} interface.
 *
 * Contracts that want to implement ERC-165 should inherit from this contract and override {supportsInterface} to check
 * for the additional interface id that will be supported. For example:
 *
 * ```solidity
 * function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
 *     return interfaceId == type(MyInterface).interfaceId || super.supportsInterface(interfaceId);
 * }
 * ```
 */
abstract contract ERC165 is IERC165 {
    /// @inheritdoc IERC165
    function supportsInterface(bytes4 interfaceId) public view virtual returns (bool) {
        return interfaceId == type(IERC165).interfaceId;
    }
}

// File: @openzeppelin/contracts/access/AccessControl.sol


// OpenZeppelin Contracts (last updated v5.4.0) (access/AccessControl.sol)

pragma solidity ^0.8.20;




/**
 * @dev Contract module that allows children to implement role-based access
 * control mechanisms. This is a lightweight version that doesn't allow enumerating role
 * members except through off-chain means by accessing the contract event logs. Some
 * applications may benefit from on-chain enumerability, for those cases see
 * {AccessControlEnumerable}.
 *
 * Roles are referred to by their `bytes32` identifier. These should be exposed
 * in the external API and be unique. The best way to achieve this is by
 * using `public constant` hash digests:
 *
 * ```solidity
 * bytes32 public constant MY_ROLE = keccak256("MY_ROLE");
 * ```
 *
 * Roles can be used to represent a set of permissions. To restrict access to a
 * function call, use {hasRole}:
 *
 * ```solidity
 * function foo() public {
 *     require(hasRole(MY_ROLE, msg.sender));
 *     ...
 * }
 * ```
 *
 * Roles can be granted and revoked dynamically via the {grantRole} and
 * {revokeRole} functions. Each role has an associated admin role, and only
 * accounts that have a role's admin role can call {grantRole} and {revokeRole}.
 *
 * By default, the admin role for all roles is `DEFAULT_ADMIN_ROLE`, which means
 * that only accounts with this role will be able to grant or revoke other
 * roles. More complex role relationships can be created by using
 * {_setRoleAdmin}.
 *
 * WARNING: The `DEFAULT_ADMIN_ROLE` is also its own admin: it has permission to
 * grant and revoke this role. Extra precautions should be taken to secure
 * accounts that have been granted it. We recommend using {AccessControlDefaultAdminRules}
 * to enforce additional security measures for this role.
 */
abstract contract AccessControl is Context, IAccessControl, ERC165 {
    struct RoleData {
        mapping(address account => bool) hasRole;
        bytes32 adminRole;
    }

    mapping(bytes32 role => RoleData) private _roles;

    bytes32 public constant DEFAULT_ADMIN_ROLE = 0x00;

    /**
     * @dev Modifier that checks that an account has a specific role. Reverts
     * with an {AccessControlUnauthorizedAccount} error including the required role.
     */
    modifier onlyRole(bytes32 role) {
        _checkRole(role);
        _;
    }

    /// @inheritdoc IERC165
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IAccessControl).interfaceId || super.supportsInterface(interfaceId);
    }

    /**
     * @dev Returns `true` if `account` has been granted `role`.
     */
    function hasRole(bytes32 role, address account) public view virtual returns (bool) {
        return _roles[role].hasRole[account];
    }

    /**
     * @dev Reverts with an {AccessControlUnauthorizedAccount} error if `_msgSender()`
     * is missing `role`. Overriding this function changes the behavior of the {onlyRole} modifier.
     */
    function _checkRole(bytes32 role) internal view virtual {
        _checkRole(role, _msgSender());
    }

    /**
     * @dev Reverts with an {AccessControlUnauthorizedAccount} error if `account`
     * is missing `role`.
     */
    function _checkRole(bytes32 role, address account) internal view virtual {
        if (!hasRole(role, account)) {
            revert AccessControlUnauthorizedAccount(account, role);
        }
    }

    /**
     * @dev Returns the admin role that controls `role`. See {grantRole} and
     * {revokeRole}.
     *
     * To change a role's admin, use {_setRoleAdmin}.
     */
    function getRoleAdmin(bytes32 role) public view virtual returns (bytes32) {
        return _roles[role].adminRole;
    }

    /**
     * @dev Grants `role` to `account`.
     *
     * If `account` had not been already granted `role`, emits a {RoleGranted}
     * event.
     *
     * Requirements:
     *
     * - the caller must have ``role``'s admin role.
     *
     * May emit a {RoleGranted} event.
     */
    function grantRole(bytes32 role, address account) public virtual onlyRole(getRoleAdmin(role)) {
        _grantRole(role, account);
    }

    /**
     * @dev Revokes `role` from `account`.
     *
     * If `account` had been granted `role`, emits a {RoleRevoked} event.
     *
     * Requirements:
     *
     * - the caller must have ``role``'s admin role.
     *
     * May emit a {RoleRevoked} event.
     */
    function revokeRole(bytes32 role, address account) public virtual onlyRole(getRoleAdmin(role)) {
        _revokeRole(role, account);
    }

    /**
     * @dev Revokes `role` from the calling account.
     *
     * Roles are often managed via {grantRole} and {revokeRole}: this function's
     * purpose is to provide a mechanism for accounts to lose their privileges
     * if they are compromised (such as when a trusted device is misplaced).
     *
     * If the calling account had been revoked `role`, emits a {RoleRevoked}
     * event.
     *
     * Requirements:
     *
     * - the caller must be `callerConfirmation`.
     *
     * May emit a {RoleRevoked} event.
     */
    function renounceRole(bytes32 role, address callerConfirmation) public virtual {
        if (callerConfirmation != _msgSender()) {
            revert AccessControlBadConfirmation();
        }

        _revokeRole(role, callerConfirmation);
    }

    /**
     * @dev Sets `adminRole` as ``role``'s admin role.
     *
     * Emits a {RoleAdminChanged} event.
     */
    function _setRoleAdmin(bytes32 role, bytes32 adminRole) internal virtual {
        bytes32 previousAdminRole = getRoleAdmin(role);
        _roles[role].adminRole = adminRole;
        emit RoleAdminChanged(role, previousAdminRole, adminRole);
    }

    /**
     * @dev Attempts to grant `role` to `account` and returns a boolean indicating if `role` was granted.
     *
     * Internal function without access restriction.
     *
     * May emit a {RoleGranted} event.
     */
    function _grantRole(bytes32 role, address account) internal virtual returns (bool) {
        if (!hasRole(role, account)) {
            _roles[role].hasRole[account] = true;
            emit RoleGranted(role, account, _msgSender());
            return true;
        } else {
            return false;
        }
    }

    /**
     * @dev Attempts to revoke `role` from `account` and returns a boolean indicating if `role` was revoked.
     *
     * Internal function without access restriction.
     *
     * May emit a {RoleRevoked} event.
     */
    function _revokeRole(bytes32 role, address account) internal virtual returns (bool) {
        if (hasRole(role, account)) {
            _roles[role].hasRole[account] = false;
            emit RoleRevoked(role, account, _msgSender());
            return true;
        } else {
            return false;
        }
    }
}

// File: @openzeppelin/contracts/utils/ReentrancyGuard.sol


// OpenZeppelin Contracts (last updated v5.1.0) (utils/ReentrancyGuard.sol)

pragma solidity ^0.8.20;

/**
 * @dev Contract module that helps prevent reentrant calls to a function.
 *
 * Inheriting from `ReentrancyGuard` will make the {nonReentrant} modifier
 * available, which can be applied to functions to make sure there are no nested
 * (reentrant) calls to them.
 *
 * Note that because there is a single `nonReentrant` guard, functions marked as
 * `nonReentrant` may not call one another. This can be worked around by making
 * those functions `private`, and then adding `external` `nonReentrant` entry
 * points to them.
 *
 * TIP: If EIP-1153 (transient storage) is available on the chain you're deploying at,
 * consider using {ReentrancyGuardTransient} instead.
 *
 * TIP: If you would like to learn more about reentrancy and alternative ways
 * to protect against it, check out our blog post
 * https://blog.openzeppelin.com/reentrancy-after-istanbul/[Reentrancy After Istanbul].
 */
abstract contract ReentrancyGuard {
    // Booleans are more expensive than uint256 or any type that takes up a full
    // word because each write operation emits an extra SLOAD to first read the
    // slot's contents, replace the bits taken up by the boolean, and then write
    // back. This is the compiler's defense against contract upgrades and
    // pointer aliasing, and it cannot be disabled.

    // The values being non-zero value makes deployment a bit more expensive,
    // but in exchange the refund on every call to nonReentrant will be lower in
    // amount. Since refunds are capped to a percentage of the total
    // transaction's gas, it is best to keep them low in cases like this one, to
    // increase the likelihood of the full refund coming into effect.
    uint256 private constant NOT_ENTERED = 1;
    uint256 private constant ENTERED = 2;

    uint256 private _status;

    /**
     * @dev Unauthorized reentrant call.
     */
    error ReentrancyGuardReentrantCall();

    constructor() {
        _status = NOT_ENTERED;
    }

    /**
     * @dev Prevents a contract from calling itself, directly or indirectly.
     * Calling a `nonReentrant` function from another `nonReentrant`
     * function is not supported. It is possible to prevent this from happening
     * by making the `nonReentrant` function external, and making it call a
     * `private` function that does the actual work.
     */
    modifier nonReentrant() {
        _nonReentrantBefore();
        _;
        _nonReentrantAfter();
    }

    function _nonReentrantBefore() private {
        // On the first call to nonReentrant, _status will be NOT_ENTERED
        if (_status == ENTERED) {
            revert ReentrancyGuardReentrantCall();
        }

        // Any calls to nonReentrant after this point will fail
        _status = ENTERED;
    }

    function _nonReentrantAfter() private {
        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        _status = NOT_ENTERED;
    }

    /**
     * @dev Returns true if the reentrancy guard is currently set to "entered", which indicates there is a
     * `nonReentrant` function in the call stack.
     */
    function _reentrancyGuardEntered() internal view returns (bool) {
        return _status == ENTERED;
    }
}

// File: @openzeppelin/contracts/token/ERC20/IERC20.sol


// OpenZeppelin Contracts (last updated v5.4.0) (token/ERC20/IERC20.sol)

pragma solidity >=0.4.16;

/**
 * @dev Interface of the ERC-20 standard as defined in the ERC.
 */
interface IERC20 {
    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to {approve}. `value` is the new allowance.
     */
    event Approval(address indexed owner, address indexed spender, uint256 value);

    /**
     * @dev Returns the value of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the value of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves a `value` amount of tokens from the caller's account to `to`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address to, uint256 value) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

    /**
     * @dev Sets a `value` amount of tokens as the allowance of `spender` over the
     * caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * IMPORTANT: Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an {Approval} event.
     */
    function approve(address spender, uint256 value) external returns (bool);

    /**
     * @dev Moves a `value` amount of tokens from `from` to `to` using the
     * allowance mechanism. `value` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(address from, address to, uint256 value) external returns (bool);
}

// File: @openzeppelin/contracts/interfaces/IERC20.sol


// OpenZeppelin Contracts (last updated v5.4.0) (interfaces/IERC20.sol)

pragma solidity >=0.4.16;


// File: @openzeppelin/contracts/interfaces/IERC165.sol


// OpenZeppelin Contracts (last updated v5.4.0) (interfaces/IERC165.sol)

pragma solidity >=0.4.16;


// File: @openzeppelin/contracts/interfaces/IERC1363.sol


// OpenZeppelin Contracts (last updated v5.4.0) (interfaces/IERC1363.sol)

pragma solidity >=0.6.2;



/**
 * @title IERC1363
 * @dev Interface of the ERC-1363 standard as defined in the https://eips.ethereum.org/EIPS/eip-1363[ERC-1363].
 *
 * Defines an extension interface for ERC-20 tokens that supports executing code on a recipient contract
 * after `transfer` or `transferFrom`, or code on a spender contract after `approve`, in a single transaction.
 */
interface IERC1363 is IERC20, IERC165 {
    /*
     * Note: the ERC-165 identifier for this interface is 0xb0202a11.
     * 0xb0202a11 ===
     *   bytes4(keccak256('transferAndCall(address,uint256)')) ^
     *   bytes4(keccak256('transferAndCall(address,uint256,bytes)')) ^
     *   bytes4(keccak256('transferFromAndCall(address,address,uint256)')) ^
     *   bytes4(keccak256('transferFromAndCall(address,address,uint256,bytes)')) ^
     *   bytes4(keccak256('approveAndCall(address,uint256)')) ^
     *   bytes4(keccak256('approveAndCall(address,uint256,bytes)'))
     */

    /**
     * @dev Moves a `value` amount of tokens from the caller's account to `to`
     * and then calls {IERC1363Receiver-onTransferReceived} on `to`.
     * @param to The address which you want to transfer to.
     * @param value The amount of tokens to be transferred.
     * @return A boolean value indicating whether the operation succeeded unless throwing.
     */
    function transferAndCall(address to, uint256 value) external returns (bool);

    /**
     * @dev Moves a `value` amount of tokens from the caller's account to `to`
     * and then calls {IERC1363Receiver-onTransferReceived} on `to`.
     * @param to The address which you want to transfer to.
     * @param value The amount of tokens to be transferred.
     * @param data Additional data with no specified format, sent in call to `to`.
     * @return A boolean value indicating whether the operation succeeded unless throwing.
     */
    function transferAndCall(address to, uint256 value, bytes calldata data) external returns (bool);

    /**
     * @dev Moves a `value` amount of tokens from `from` to `to` using the allowance mechanism
     * and then calls {IERC1363Receiver-onTransferReceived} on `to`.
     * @param from The address which you want to send tokens from.
     * @param to The address which you want to transfer to.
     * @param value The amount of tokens to be transferred.
     * @return A boolean value indicating whether the operation succeeded unless throwing.
     */
    function transferFromAndCall(address from, address to, uint256 value) external returns (bool);

    /**
     * @dev Moves a `value` amount of tokens from `from` to `to` using the allowance mechanism
     * and then calls {IERC1363Receiver-onTransferReceived} on `to`.
     * @param from The address which you want to send tokens from.
     * @param to The address which you want to transfer to.
     * @param value The amount of tokens to be transferred.
     * @param data Additional data with no specified format, sent in call to `to`.
     * @return A boolean value indicating whether the operation succeeded unless throwing.
     */
    function transferFromAndCall(address from, address to, uint256 value, bytes calldata data) external returns (bool);

    /**
     * @dev Sets a `value` amount of tokens as the allowance of `spender` over the
     * caller's tokens and then calls {IERC1363Spender-onApprovalReceived} on `spender`.
     * @param spender The address which will spend the funds.
     * @param value The amount of tokens to be spent.
     * @return A boolean value indicating whether the operation succeeded unless throwing.
     */
    function approveAndCall(address spender, uint256 value) external returns (bool);

    /**
     * @dev Sets a `value` amount of tokens as the allowance of `spender` over the
     * caller's tokens and then calls {IERC1363Spender-onApprovalReceived} on `spender`.
     * @param spender The address which will spend the funds.
     * @param value The amount of tokens to be spent.
     * @param data Additional data with no specified format, sent in call to `spender`.
     * @return A boolean value indicating whether the operation succeeded unless throwing.
     */
    function approveAndCall(address spender, uint256 value, bytes calldata data) external returns (bool);
}

// File: @openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol


// OpenZeppelin Contracts (last updated v5.3.0) (token/ERC20/utils/SafeERC20.sol)

pragma solidity ^0.8.20;



/**
 * @title SafeERC20
 * @dev Wrappers around ERC-20 operations that throw on failure (when the token
 * contract returns false). Tokens that return no value (and instead revert or
 * throw on failure) are also supported, non-reverting calls are assumed to be
 * successful.
 * To use this library you can add a `using SafeERC20 for IERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */
library SafeERC20 {
    /**
     * @dev An operation with an ERC-20 token failed.
     */
    error SafeERC20FailedOperation(address token);

    /**
     * @dev Indicates a failed `decreaseAllowance` request.
     */
    error SafeERC20FailedDecreaseAllowance(address spender, uint256 currentAllowance, uint256 requestedDecrease);

    /**
     * @dev Transfer `value` amount of `token` from the calling contract to `to`. If `token` returns no value,
     * non-reverting calls are assumed to be successful.
     */
    function safeTransfer(IERC20 token, address to, uint256 value) internal {
        _callOptionalReturn(token, abi.encodeCall(token.transfer, (to, value)));
    }

    /**
     * @dev Transfer `value` amount of `token` from `from` to `to`, spending the approval given by `from` to the
     * calling contract. If `token` returns no value, non-reverting calls are assumed to be successful.
     */
    function safeTransferFrom(IERC20 token, address from, address to, uint256 value) internal {
        _callOptionalReturn(token, abi.encodeCall(token.transferFrom, (from, to, value)));
    }

    /**
     * @dev Variant of {safeTransfer} that returns a bool instead of reverting if the operation is not successful.
     */
    function trySafeTransfer(IERC20 token, address to, uint256 value) internal returns (bool) {
        return _callOptionalReturnBool(token, abi.encodeCall(token.transfer, (to, value)));
    }

    /**
     * @dev Variant of {safeTransferFrom} that returns a bool instead of reverting if the operation is not successful.
     */
    function trySafeTransferFrom(IERC20 token, address from, address to, uint256 value) internal returns (bool) {
        return _callOptionalReturnBool(token, abi.encodeCall(token.transferFrom, (from, to, value)));
    }

    /**
     * @dev Increase the calling contract's allowance toward `spender` by `value`. If `token` returns no value,
     * non-reverting calls are assumed to be successful.
     *
     * IMPORTANT: If the token implements ERC-7674 (ERC-20 with temporary allowance), and if the "client"
     * smart contract uses ERC-7674 to set temporary allowances, then the "client" smart contract should avoid using
     * this function. Performing a {safeIncreaseAllowance} or {safeDecreaseAllowance} operation on a token contract
     * that has a non-zero temporary allowance (for that particular owner-spender) will result in unexpected behavior.
     */
    function safeIncreaseAllowance(IERC20 token, address spender, uint256 value) internal {
        uint256 oldAllowance = token.allowance(address(this), spender);
        forceApprove(token, spender, oldAllowance + value);
    }

    /**
     * @dev Decrease the calling contract's allowance toward `spender` by `requestedDecrease`. If `token` returns no
     * value, non-reverting calls are assumed to be successful.
     *
     * IMPORTANT: If the token implements ERC-7674 (ERC-20 with temporary allowance), and if the "client"
     * smart contract uses ERC-7674 to set temporary allowances, then the "client" smart contract should avoid using
     * this function. Performing a {safeIncreaseAllowance} or {safeDecreaseAllowance} operation on a token contract
     * that has a non-zero temporary allowance (for that particular owner-spender) will result in unexpected behavior.
     */
    function safeDecreaseAllowance(IERC20 token, address spender, uint256 requestedDecrease) internal {
        unchecked {
            uint256 currentAllowance = token.allowance(address(this), spender);
            if (currentAllowance < requestedDecrease) {
                revert SafeERC20FailedDecreaseAllowance(spender, currentAllowance, requestedDecrease);
            }
            forceApprove(token, spender, currentAllowance - requestedDecrease);
        }
    }

    /**
     * @dev Set the calling contract's allowance toward `spender` to `value`. If `token` returns no value,
     * non-reverting calls are assumed to be successful. Meant to be used with tokens that require the approval
     * to be set to zero before setting it to a non-zero value, such as USDT.
     *
     * NOTE: If the token implements ERC-7674, this function will not modify any temporary allowance. This function
     * only sets the "standard" allowance. Any temporary allowance will remain active, in addition to the value being
     * set here.
     */
    function forceApprove(IERC20 token, address spender, uint256 value) internal {
        bytes memory approvalCall = abi.encodeCall(token.approve, (spender, value));

        if (!_callOptionalReturnBool(token, approvalCall)) {
            _callOptionalReturn(token, abi.encodeCall(token.approve, (spender, 0)));
            _callOptionalReturn(token, approvalCall);
        }
    }

    /**
     * @dev Performs an {ERC1363} transferAndCall, with a fallback to the simple {ERC20} transfer if the target has no
     * code. This can be used to implement an {ERC721}-like safe transfer that rely on {ERC1363} checks when
     * targeting contracts.
     *
     * Reverts if the returned value is other than `true`.
     */
    function transferAndCallRelaxed(IERC1363 token, address to, uint256 value, bytes memory data) internal {
        if (to.code.length == 0) {
            safeTransfer(token, to, value);
        } else if (!token.transferAndCall(to, value, data)) {
            revert SafeERC20FailedOperation(address(token));
        }
    }

    /**
     * @dev Performs an {ERC1363} transferFromAndCall, with a fallback to the simple {ERC20} transferFrom if the target
     * has no code. This can be used to implement an {ERC721}-like safe transfer that rely on {ERC1363} checks when
     * targeting contracts.
     *
     * Reverts if the returned value is other than `true`.
     */
    function transferFromAndCallRelaxed(
        IERC1363 token,
        address from,
        address to,
        uint256 value,
        bytes memory data
    ) internal {
        if (to.code.length == 0) {
            safeTransferFrom(token, from, to, value);
        } else if (!token.transferFromAndCall(from, to, value, data)) {
            revert SafeERC20FailedOperation(address(token));
        }
    }

    /**
     * @dev Performs an {ERC1363} approveAndCall, with a fallback to the simple {ERC20} approve if the target has no
     * code. This can be used to implement an {ERC721}-like safe transfer that rely on {ERC1363} checks when
     * targeting contracts.
     *
     * NOTE: When the recipient address (`to`) has no code (i.e. is an EOA), this function behaves as {forceApprove}.
     * Opposedly, when the recipient address (`to`) has code, this function only attempts to call {ERC1363-approveAndCall}
     * once without retrying, and relies on the returned value to be true.
     *
     * Reverts if the returned value is other than `true`.
     */
    function approveAndCallRelaxed(IERC1363 token, address to, uint256 value, bytes memory data) internal {
        if (to.code.length == 0) {
            forceApprove(token, to, value);
        } else if (!token.approveAndCall(to, value, data)) {
            revert SafeERC20FailedOperation(address(token));
        }
    }

    /**
     * @dev Imitates a Solidity high-level call (i.e. a regular function call to a contract), relaxing the requirement
     * on the return value: the return value is optional (but if data is returned, it must not be false).
     * @param token The token targeted by the call.
     * @param data The call data (encoded using abi.encode or one of its variants).
     *
     * This is a variant of {_callOptionalReturnBool} that reverts if call fails to meet the requirements.
     */
    function _callOptionalReturn(IERC20 token, bytes memory data) private {
        uint256 returnSize;
        uint256 returnValue;
        assembly ("memory-safe") {
            let success := call(gas(), token, 0, add(data, 0x20), mload(data), 0, 0x20)
            // bubble errors
            if iszero(success) {
                let ptr := mload(0x40)
                returndatacopy(ptr, 0, returndatasize())
                revert(ptr, returndatasize())
            }
            returnSize := returndatasize()
            returnValue := mload(0)
        }

        if (returnSize == 0 ? address(token).code.length == 0 : returnValue != 1) {
            revert SafeERC20FailedOperation(address(token));
        }
    }

    /**
     * @dev Imitates a Solidity high-level call (i.e. a regular function call to a contract), relaxing the requirement
     * on the return value: the return value is optional (but if data is returned, it must not be false).
     * @param token The token targeted by the call.
     * @param data The call data (encoded using abi.encode or one of its variants).
     *
     * This is a variant of {_callOptionalReturn} that silently catches all reverts and returns a bool instead.
     */
    function _callOptionalReturnBool(IERC20 token, bytes memory data) private returns (bool) {
        bool success;
        uint256 returnSize;
        uint256 returnValue;
        assembly ("memory-safe") {
            success := call(gas(), token, 0, add(data, 0x20), mload(data), 0, 0x20)
            returnSize := returndatasize()
            returnValue := mload(0)
        }
        return success && (returnSize == 0 ? address(token).code.length > 0 : returnValue == 1);
    }
}

// File: contracts/kipu.sol


pragma solidity 0.8.30;

/*///////////////////////////////////
        Imports
///////////////////////////////////*/



/*///////////////////////////////////
        Libraries
///////////////////////////////////*/


/*///////////////////////////////////
        Interfaces
///////////////////////////////////*/


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