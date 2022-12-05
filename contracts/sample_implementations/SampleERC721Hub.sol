// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import "../ERC721Hub.sol";
import "./SampleSpoke.sol";

interface ISampleSpoke {
    function tokenURI(uint256 id) external view returns (string memory);
}

// Sample ERC721Hub implementation. This is a simple implementation that has
// basic mint logic and inherits from ERC721Hub. The spoke is a SampleSpoke
// with bare-bones tokenURI logic.
contract SampleERC721Hub is ERC721Hub {
    uint256 public constant MAX_SUPPLY = 2048;
    uint256 public constant PRICE = .02 ether;

    uint256 public totalSupply;

    constructor(
        string memory _name,
        string memory _symbol
    ) ERC721Hub(_name, symbol) {}

    /* Minting Logic */
    function mintWithEth() external payable {
        uint256 id = ++totalSupply;
        require(msg.value == PRICE, "NOT_ENOUGH_ETH");
        require(id < MAX_SUPPLY, "OUT_OF_STOCK");
        _mint(msg.sender, id);
    }

    // Create a new SampleSpoke contract and store the address in the spokes mapping
    function _mint(address to, uint256 id) internal virtual override {
        super._mint(to, id);
        spokes[id] = address(new SampleSpoke(to, id));
    }

    // In this implementation, we get the tokenURI from the spoke. Up to the dev
    // to determine how they want to handle this in their implementation.
    function tokenURI(uint256 id) public view override returns (string memory) {
        require(spokes[id] != address(0), "DOES_NOT_EXIST");
        return ISampleSpoke(spokes[id]).tokenURI(id);
    }
}
