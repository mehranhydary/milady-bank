// SPDX-License-Identifier: VPL-1.0
pragma solidity ^0.8.20;

interface IOracle {
    function getPrice(address token0, address token1) external view returns (uint256 price);
    function isStale(address token0, address token1) external view returns (bool);
}
