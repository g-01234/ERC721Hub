// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity 0.8.17;

import "../../ERC721Hub.sol";
import "./CanvasSpoke.sol";

/// @notice ERC721Hub implementation that mints CanvasSpoke contracts.
/// @author @popular_12345 / popular#1234
interface ICanvasSpoke {
    function renderSVG() external view returns (string memory);

    function tokenURI(uint256 id) external view returns (string memory);
}

contract CanvasHub is ERC721Hub {
    uint256 public constant MAX_SUPPLY = 150;
    uint256 public constant PRICE = .02 ether;

    uint256 public totalSupply;

    address public immutable defaultRenderer;

    constructor(
        string memory _name,
        string memory _symbol,
        address _defaultRenderer
    ) ERC721Hub(_name, _symbol) {
        defaultRenderer = _defaultRenderer;
    }

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
        spokes[id] = address(new CanvasSpoke(to, id, defaultRenderer));
    }

    // In this implementation, we get the tokenURI from the spoke. Up to the dev
    // to determine how they want to handle this in their implementation.
    function tokenURI(uint256 id) public view override returns (string memory) {
        require(spokes[id] != address(0), "DOES_NOT_EXIST");

        string memory svg = ICanvasSpoke(spokes[id]).tokenURI(id);
        return svg;
    }
}
