// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;
import "../node_modules/solmate/src/tokens/ERC721.sol";
import "../node_modules/solmate/src/auth/Owned.sol";
import "./Canvas.sol";

import "hardhat/console.sol";

interface IERC721 {
    function ownerOf(uint256 id) external view returns (address owner);
}

contract CanvasMaker is ERC721, Owned {
    uint256 public constant MAX_SUPPLY = 2048;
    uint256 public constant PRICE = .02 ether;

    uint64 public currentMinted;

    mapping(uint256 => address) public canvases;

    constructor() ERC721("Canvas", "CANVAS") Owned(msg.sender) {}

    // ERRORS
    error AlreadyMinted();
    error CollectionMintsDepleted();

    // Minting
    function mintWithEth() external payable {
        require(msg.value == PRICE, "NOT_ENOUGH_ETH");
        cutCanvas();
    }

    // Removing address(0) checks from solmate ERC721
    function _mint(address to, uint256 id) internal override {
        // Counter overflow is incredibly unrealistic.
        unchecked {
            _balanceOf[to]++;
        }

        emit Transfer(address(0), to, id);
    }

    // Mint
    function cutCanvas() internal {
        uint id = ++currentMinted;
        require(id < MAX_SUPPLY, "OUT_OF_STOCK");
        address newCanvas = address(new Canvas(msg.sender, id));
        canvases[id] = newCanvas;
        _mint(msg.sender, id);
    }

    // ERC721 Functionality
    function tokenURI(uint256 id) public view override returns (string memory) {
        return Canvas(_ownerOf[id]).tokenURI();
    }

    function ownerOf(uint256 id) public view override returns (address owner) {
        // require((owner = _ownerOf[id]) != address(0), "DOES_NOT_EXIST");
        return Canvas(canvases[id]).ownerOf();
    }

    // Helpers
    function isContract(address addr) internal view returns (bool) {
        uint size;
        assembly {
            size := extcodesize(addr)
        }
        return size > 0;
    }
}
