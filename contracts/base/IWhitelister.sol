// SPDX-License-Identifier: BUSL-1.1
pragma solidity =0.8.12;

import "./ISoltManager.sol";
import "./ISolt.sol";
import "./IDelegationManager.sol";
import "./IBLSRegistry.sol";

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Create2.sol";


interface IWhitelister {

    function whitelist(address operator) external;

    function getStaker(address operator) external returns (address);

    function depositIntoSolt(
        address staker,
        ISolt solt,
        IERC20 token,
        uint256 amount
    ) external returns (bytes memory);

    function queueWithdrawal(
        address staker,
        uint256[] calldata soltIndexes,
        ISolt[] calldata solts,
        uint256[] calldata shares,
        address withdrawer,
        bool undelegateIfPossible
    ) external returns (bytes memory);

    function completeQueuedWithdrawal(
        address staker,
        ISoltManager.QueuedWithdrawal calldata queuedWithdrawal,
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
