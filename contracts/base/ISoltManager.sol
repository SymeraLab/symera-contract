// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "./ISolt.sol";


interface ISoltManager {
    struct WithdrawerAndNonce {
        address withdrawer;
        uint96 nonce;
    }


    struct QueuedWithdrawal {
        ISolt[] strategies;
        uint256[] shares;
        address depositor;
        WithdrawerAndNonce withdrawerAndNonce;
        uint32 withdrawalStartBlock;
        address delegatedAddress;
    }

    
    function depositIntoSolt(ISolt solt, IERC20 token, uint256 amount)
        external
        returns (uint256);


    
    function depositBeaconChainETH(address staker, uint256 amount) external;

    
    function recordOvercommittedBeaconChainETH(address overcommittedPodOwner, uint256 beaconChainETHStrategyIndex, uint256 amount)
        external;

    
    function depositIntoSlotWithSignature(
        ISolt slot,
        IERC20 token,
        uint256 amount,
        address staker,
        uint256 expiry,
        bytes memory signature
    )
        external
        returns (uint256 shares);

    function stakerSlotShares(address user, ISolt slot) external view returns (uint256 shares);


    function getDeposits(address depositor) external view returns (ISolt[] memory, uint256[] memory);

    function stakerSlotListLength(address staker) external view returns (uint256);

    function queueWithdrawal(
        uint256[] calldata slotIndexes,
        ISolt[] calldata slots,
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
        ISolt[] calldata slots,
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
