// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "../../base/ISlotManager.sol";
import "../../base/IDelegationTerms.sol";
import "../../base/IDelegationManager.sol";
import "../../base/ISlasher.sol";

/**
 * @title Storage variables for the `DelegationManager` contract.
 * @author Symera, Inc.
 * @notice This storage contract is separate from the logic to simplify the upgrade process.
 */
abstract contract DelegationManagerStorage is IDelegationManager {
    /// @notice Gas budget provided in calls to DelegationTerms contracts
    uint256 internal constant LOW_LEVEL_GAS_BUDGET = 1e5;

    /// @notice The EIP-712 typehash for the contract's domain
    bytes32 public constant DOMAIN_TYPEHASH =
        keccak256("EIP712Domain(string name,uint256 chainId,address verifyingContract)");

    /// @notice The EIP-712 typehash for the delegation struct used by the contract
    bytes32 public constant DELEGATION_TYPEHASH =
        keccak256("Delegation(address delegator,address operator,uint256 nonce,uint256 expiry)");

    /// @notice EIP-712 Domain separator
    bytes32 public DOMAIN_SEPARATOR;

    /// @notice The SlotManager contract for Symera
    ISlotManager public immutable slotManager;

    /// @notice The Slasher contract for Symera
    ISlasher public immutable slasher;

    /// @notice Mapping: operator => slot => total number of shares in the slot delegated to the operator
    mapping(address => mapping(ISlot => uint256)) public operatorShares;

    /// @notice Mapping: operator => delegation terms contract
    mapping(address => IDelegationTerms) public delegationTerms;

    /// @notice Mapping: staker => operator whom the staker has delegated to
    mapping(address => address) public delegatedTo;

    /// @notice Mapping: delegator => number of signed delegation nonce (used in delegateToBySignature)
    mapping(address => uint256) public nonces;

    constructor(ISlotManager _slotManager, ISlasher _slasher) {
        slotManager = _slotManager;
        slasher = _slasher;
    }

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[46] private __gap;
}