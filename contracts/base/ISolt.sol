// SPDX-License-Identifier: MIT
pragma solidity =0.8.12;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";


interface IStrategy {
    
    function deposit(IERC20 token, uint256 amount) external returns (uint256);

    
    function withdraw(address depositor, IERC20 token, uint256 amountShares) external;
}
