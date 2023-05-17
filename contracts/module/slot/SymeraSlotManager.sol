// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts-upgradeable/security/PausableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/interfaces/IERC1271.sol";
import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import "../../base/ISlot.sol";
import "./SymeraSlotManagerStorage.sol";
/**
 * @title Manage Symera Slot
 * @author Symera Lab
 */
contract SymeraSlotManager is Initializable, PausableUpgradeable, OwnableUpgradeable,SymeraSoltManagerStorage {
    using SafeERC20 for IERC20;
    event Deposit(
        address depositor, IERC20 token, ISlot slot, uint256 shares
    );

    uint256 private ORIGINAL_CHAIN_ID;

    // bytes4(keccak256("isValidSignature(bytes32,bytes)")
    bytes4 constant internal ERC1271_MAGICVALUE = 0x1626ba7e;


    function initialize() initializer public {
        __Pausable_init();
        __Ownable_init();
        ORIGINAL_CHAIN_ID = block.chainid;
    }

    function pause() public onlyOwner {
        _pause();
    }

    function unpause() public onlyOwner {
        _unpause();
    }

    /**
     * @notice This function adds `shares` for a given `slot` to the `depositor` and runs through the necessary update logic.
     * @dev In particular, this function calls `delegation.increaseDelegatedShares(depositor, slot, shares)` to ensure that all
     * delegated shares are tracked, increases the stored share amount in `stakerSlotShares[depositor][slot]`, and adds `slot`
     * to the `depositor`'s list of strategies, if it is not in the list already.
     */
    function _addShares(address depositor, ISlot slot, uint256 shares) internal {
        // sanity checks on inputs
        require(depositor != address(0), "SlotManager._addShares: depositor cannot be zero address");
        require(shares != 0, "SlotManager._addShares: shares should not be zero!");

        // if they dont have existing shares of this slot, add it to their strats
        if (stakerSlotShares[depositor][slot] == 0) {
            require(
                stakerSlotList[depositor].length < MAX_STAKER_SLOT_LIST_LENGTH,
                "SlotManager._addShares: deposit would exceed MAX_STAKER_SLOT_LIST_LENGTH"
            );
            stakerSlotList[depositor].push(slot);
        }

        // add the returned shares to their existing shares for this slot
        stakerSlotShares[depositor][slot] += shares;

        // if applicable, increase delegated shares accordingly
        delegation.increaseDelegatedShares(depositor, slot, shares);
    }

    function _depositIntoSlot(address depositor, ISlot slot, IERC20 token, uint256 amount)internal returns (uint256 shares){
        // transfer tokens from the sender to the slot
        token.safeTransferFrom(msg.sender, address(slot), amount);

        // deposit the assets into the specified slot and get the equivalent amount of shares in that slot
        shares = slot.deposit(token, amount);

        // add the returned shares to the msg.sender's existing shares for this slot
        _addShares(depositor, slot, shares);

        emit Deposit(depositor, token, slot, shares);

        return shares;
    }

    function depositIntoSlot(ISlot slot, IERC20 token, uint256 amount)
        external
        returns (uint256 shares){
        shares = _depositIntoSlot(msg.sender, slot, token, amount);
    }


    
    function depositBeaconChainETH(address staker, uint256 amount) external{
        _addShares(staker, beaconChainETHSlot, amount);
    }

    
    function recordOvercommittedBeaconChainETH(address overcommittedPodOwner, uint256 beaconChainETHSlotIndex, uint256 amount)
        external{

        }

    
    function depositIntoSlotWithSignature(
        ISlot slot,
        IERC20 token,
        uint256 amount,
        address staker,
        uint256 expiry,
        bytes memory signature
    )
        external
        returns (uint256 shares){
        require(
            expiry >= block.timestamp,
            "SlotManager.depositIntoSlotWithSignature: signature expired"
        );
        // calculate struct hash, then increment `staker`'s nonce
        uint256 nonce = nonces[staker];
        bytes32 structHash = keccak256(abi.encode(DEPOSIT_TYPEHASH, slot, token, amount, nonce, expiry));
        unchecked {
            nonces[staker] = nonce + 1;
        }

        bytes32 digestHash;
        //if chainid has changed, we must re-compute the domain separator
        if (block.chainid != ORIGINAL_CHAIN_ID) {
            bytes32 domain_separator = keccak256(abi.encode(DOMAIN_TYPEHASH, keccak256(bytes("EigenLayer")), block.chainid, address(this)));
            digestHash = keccak256(abi.encodePacked("\x19\x01", domain_separator, structHash));
        } else {
            digestHash = keccak256(abi.encodePacked("\x19\x01", DOMAIN_SEPARATOR, structHash));
        }
        /**
         * check validity of signature:
         * 1) if `staker` is an EOA, then `signature` must be a valid ECSDA signature from `staker`,
         * indicating their intention for this action
         * 2) if `staker` is a contract, then `signature` must will be checked according to EIP-1271
         */
        if (Address.isContract(staker)) {
            require(IERC1271(staker).isValidSignature(digestHash, signature) == ERC1271_MAGICVALUE,
                "SlotManager.depositIntoSlotWithSignature: ERC1271 signature verification failed");
        } else {
            require(ECDSA.recover(digestHash, signature) == staker,
                "SlotManager.depositIntoSlotWithSignature: signature not from staker");
        }

        shares = _depositIntoSlot(staker, slot, token, amount);
    }



    function getDeposits(address depositor) external view returns (ISlot[] memory, uint256[] memory){
        uint256 strategiesLength = stakerSlotList[depositor].length;
        uint256[] memory shares = new uint256[](strategiesLength);

        for (uint256 i = 0; i < strategiesLength;) {
            shares[i] = stakerSlotShares[depositor][stakerSlotList[depositor][i]];
            unchecked {
                ++i;
            }
        }
        return (stakerSlotList[depositor], shares);
    }

    function stakerSlotListLength(address staker) external view returns (uint256){

    }

    function queueWithdrawal(
        uint256[] calldata slotIndexes,
        ISlot[] calldata slots,
        uint256[] calldata shares,
        address withdrawer,
        bool undelegateIfPossible
    )
        external returns(bytes32){

        }
        

    function completeQueuedWithdrawal(
        QueuedWithdrawal calldata queuedWithdrawal,
        IERC20[] calldata tokens,
        uint256 middlewareTimesIndex,
        bool receiveAsTokens
    )
        external{}

    function completeQueuedWithdrawals(
        QueuedWithdrawal[] calldata queuedWithdrawals,
        IERC20[][] calldata tokens,
        uint256[] calldata middlewareTimesIndexes,
        bool[] calldata receiveAsTokens
    )
        external{}


    function slashShares(
        address slashedAddress,
        address recipient,
        ISlot[] calldata slots,
        IERC20[] calldata tokens,
        uint256[] calldata slotIndexes,
        uint256[] calldata shareAmounts
    )
        external{}


    function slashQueuedWithdrawal(address recipient, QueuedWithdrawal calldata queuedWithdrawal, IERC20[] calldata tokens, uint256[] calldata indicesToSkip)
        external{}

    /// @notice Returns the keccak256 hash of `queuedWithdrawal`.
    function calculateWithdrawalRoot(
        QueuedWithdrawal memory queuedWithdrawal
    )
        external
        pure
        returns (bytes32){}
}
