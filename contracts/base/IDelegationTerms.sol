// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "./ISlot.sol";

/**
 * @title Abstract interface for a contract that helps structure the delegation relationship.
 * @author Symera, Inc.
 * @notice The gas budget provided to this contract in calls from Symera contracts is limited.
 */
interface IDelegationTerms {
    function payForService(IERC20 token, uint256 amount) external payable;

    function onDelegationWithdrawn(
        address delegator,
        ISlot[] memory stakerSlotList,
        uint256[] memory stakerShares
    ) external returns(bytes memory);

    function onDelegationReceived(
        address delegator,
        ISlot[] memory stakerSlotList,
        uint256[] memory stakerShares
    ) external returns(bytes memory);
}
