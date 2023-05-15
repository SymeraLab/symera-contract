// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "./ISlotManager.sol";
import "./ISlot.sol";
import "./IDelegationManager.sol";
import "./IBLSRegistry.sol";

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Create2.sol";


interface IWhitelister {

    function whitelist(address operator) external;

    function getStaker(address operator) external returns (address);

    function depositIntoSlot(
        address staker,
        ISlot slot,
        IERC20 token,
        uint256 amount
    ) external returns (bytes memory);

    function queueWithdrawal(
        address staker,
        uint256[] calldata slotIndexes,
        ISlot[] calldata slots,
        uint256[] calldata shares,
        address withdrawer,
        bool undelegateIfPossible
    ) external returns (bytes memory);

    function completeQueuedWithdrawal(
        address staker,
        ISlotManager.QueuedWithdrawal calldata queuedWithdrawal,
        IERC20[] calldata tokens,
        uint256 middlewareTimesIndex,
        bool receiveAsTokens
    ) external returns (bytes memory);

    function transfer(
        address staker,
        address token,
        address to,
        uint256 amount
    ) external returns (bytes memory) ; 
    
    function callAddress(
        address to,
        bytes memory data
    ) external payable returns (bytes memory);
}
