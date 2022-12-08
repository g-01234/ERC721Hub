// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

/// @author PizzaHi5#8447
interface ICalculateNAV {
    function calculateNAV(
        address[] calldata priceFeeds,
        address[] calldata tokens,
        address _baseToken
    ) external view returns (int256 nav);
}
