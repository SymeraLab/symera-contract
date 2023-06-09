// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;
import "../../base/ISlotManager.sol";
import "../../base/ISlot.sol";
import "../../base/IDelegationManager.sol";
/**
 * @title Storage variables for the `SlotManager` contract.
 * @author Symera, Lab.
 * @notice This storage contract is separate from the logic to simplify the upgrade process.
 */
abstract contract SymeraSoltManagerStorage is ISlotManager {
    /// @notice The EIP-712 typehash for the contract's domain
    bytes32 public constant DOMAIN_TYPEHASH =
        keccak256("EIP712Domain(string name,uint256 chainId,address verifyingContract)");
    /// @notice The EIP-712 typehash for the deposit struct used by the contract
    bytes32 public constant DEPOSIT_TYPEHASH =
        keccak256("Deposit(address strategy,address token,uint256 amount,uint256 nonce,uint256 expiry)");
    /// @notice EIP-712 Domain separator
    bytes32 public DOMAIN_SEPARATOR;
    // staker => number of signed deposit nonce (used in depositIntoSlotWithSignature)
    mapping(address => uint256) public nonces;

    // maximum length of dynamic arrays in `stakerSlotList` mapping, for sanity's sake
    uint8 internal constant MAX_STAKER_SLOT_LIST_LENGTH = 32;

    IDelegationManager public delegation;

    mapping(address => mapping(ISlot => uint256)) public stakerSlotShares;

    mapping(address => ISlot[]) public stakerSlotList;

    ISlot public constant beaconChainETHSlot = ISlot(0xbeaC0eeEeeeeEEeEeEEEEeeEEeEeeeEeeEEBEaC0);
}