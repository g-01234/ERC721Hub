// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity 0.8.17;

import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

import "./ICalculateNAV.sol";

interface IERC20 {
    function balanceOf(address account) external view returns (uint256);

    function totalSupply() external view returns (uint256);
}

/// @notice This contract returns the NAV value based on tracked underlying assets
/// @author PizzaHi5#8447
contract CalculateNAV is ICalculateNAV {
    /** 
        @param priceFeeds should all have the same denomination (I.E ETH/USD and BTC/USD), index 0 is ETH
        @param tokens should contain 1 less index than priceFeeds due to ETH balance call
        @param baseToken should be the underlying mintable ETF security
        @return nav returns the total price relative to the denominated asset and total baseToken supply

        @notice If the owner of the ETFERC20 withdraws assets, the NAV will fall accordingly
    */
    function calculateNAV(
        address[] calldata priceFeeds,
        address[] calldata tokens,
        address baseToken
    ) external view returns (int256 nav) {
        int256 holdingValue;

        for (uint i = 0; i < priceFeeds.length; i++) {
            // value += price * token amount
            if (i == 0) {
                // index 0 will be ETH since its called differently
                holdingValue +=
                    formatPriceFeedDecimals(getV3Price(priceFeeds[i])) *
                    int256(msg.sender.balance);
            } else {
                // ERC20 compliant tokens
                holdingValue +=
                    formatPriceFeedDecimals(getV3Price(priceFeeds[i])) *
                    int256(IERC20(tokens[i - 1]).balanceOf(msg.sender));
            }
        }
        nav = holdingValue / int256(IERC20(baseToken).totalSupply());
    }

    /// @dev Formatted getters for price
    function getV3Price(address priceFeed) public view returns (int256 price) {
        (, price, , , ) = AggregatorV3Interface(priceFeed).latestRoundData();
    }

    /// @dev read off ERC20 decimals later, openzeppelin IERC20 doesnt have it
    ///      should need token decimals, baseToken decimals, and priceFeed decimals?
    function formatPriceFeedDecimals(
        int256 feedPrice
    ) private pure returns (int256) {
        return feedPrice * 10 ** (18 - 8);
    }
}
