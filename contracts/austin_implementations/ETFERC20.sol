// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity 0.8.17;

import "@solmate/src/tokens/ERC20.sol";
import "./Spoke.sol";
import { ICalculateNAV } from "./ICalculateNAV.sol";

contract ETFERC20 is ERC20, Spoke {
    address[] public trackedPriceFeeds;
    address[] public tokens;
    address public calcNav;

    constructor(
    string memory _name, 
    string memory _symbol, 
    uint8 _decimals,
    uint256 _amount,
    uint256 _tokenId,
    address _calcNav
    )
    ERC20 (_name, _symbol, _decimals) 
    Spoke (msg.sender, _tokenId)
    payable
    {
        require(msg.value > 0, "Required to send Eth");
        require(_amount > 0, "Required to mint tokens");
        calcNav =_calcNav;
        _mint(msg.sender, _amount);
    }

    function mintWithEth(uint256 amount) external payable {
        require(msg.value >= amount * uint256(ICalculateNAV(calcNav).calculateNAV(
            trackedPriceFeeds, 
            tokens, 
            address(this))));

        _mint(msg.sender, amount);
    }

    function mintWithRegisteredToken(uint256 amount, address token) external payable {
        //insert logic here
    }

    function burn(uint256 amount) external payable {
        require(balanceOf[msg.sender] >= amount);
        _burn(msg.sender, amount);
        //return locked eth/token to sender
    }

    function checkNAV() external view returns (int256) {
        return ICalculateNAV(calcNav).calculateNAV(
            trackedPriceFeeds, 
            tokens, 
            address(this));
    }

    /// @dev Sets index 0 to always be the ETH pricefeed
    function addETHPriceFeed(address priceFeed) external onlyOwner {
        //check if priceFeeds has values, if does, set index 0 instead of push
        trackedPriceFeeds.push(priceFeed);
    }

    function addTrackedPriceFeeds(address priceFeed, address feedToken) external onlyOwner {
        //require IsContract
        trackedPriceFeeds.push(priceFeed);
        tokens.push(feedToken);
    }

    function updateCalcNav(address _calcNav) external onlyOwner {
        calcNav = _calcNav;
    }
}