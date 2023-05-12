// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "./ISlot.sol";


interface ISlotManager {
    struct WithdrawerAndNonce {
        address withdrawer;
        uint96 nonce;
    }


    struct QueuedWithdrawal {
        ISlot[] strategies;
        uint256[] shares;
        address depositor;
        WithdrawerAndNonce withdrawerAndNonce;
        uint32 withdrawalStartBlock;
        address delegatedAddress;
    }

    
    function depositIntoSlot(ISlot slot, IERC20 token, uint256 amount)
        external
        returns (uint256);


    
    function depositBeaconChainETH(address staker, uint256 amount) external;

    
    function recordOvercommittedBeaconChainETH(address overcommittedPodOwner, uint256 beaconChainETHSlotIndex, uint256 amount)
        external;

    
    function depositIntoSlotWithSignature(
        ISlot slot,
        IERC20 token,
        uint256 amount,
        address staker,
        uint256 expiry,
        bytes memory signature
    )
        external
        returns (uint256 shares);

    function stakerSlotShares(address user, ISlot slot) external view returns (uint256 shares);


    function getDeposits(address depositor) external view returns (ISlot[] memory, uint256[] memory);

    function stakerSlotListLength(address staker) external view returns (uint256);

    function queueWithdrawal(
        uint256[] calldata slotIndexes,
        ISlot[] calldata slots,
        uint256[] calldata shares,
        address withdrawer,
        bool undelegateIfPossible
    )
        external returns(bytes32);
        

    function completeQueuedWithdrawal(
        QueuedWithdrawal calldata queuedWithdrawal,
        IERC20[] calldata tokens,
        uint256 middlewareTimesIndex,
        bool receiveAsTokens
    )
        external;

    function completeQueuedWithdrawals(
        QueuedWithdrawal[] calldata queuedWithdrawals,
        IERC20[][] calldata tokens,
        uint256[] calldata middlewareTimesIndexes,
        bool[] calldata receiveAsTokens
    )
        external;


    function slashShares(
        address slashedAddress,
        address recipient,
        ISlot[] calldata slots,
        IERC20[] calldata tokens,
        uint256[] calldata slotIndexes,
        uint256[] calldata shareAmounts
    )
        external;


    function slashQueuedWithdrawal(address recipient, QueuedWithdrawal calldata queuedWithdrawal, IERC20[] calldata tokens, uint256[] calldata indicesToSkip)
        external;

    /// @notice Returns the keccak256 hash of `queuedWithdrawal`.
    function calculateWithdrawalRoot(
        QueuedWithdrawal memory queuedWithdrawal
    )
        external
        pure
        returns (bytes32);

}
