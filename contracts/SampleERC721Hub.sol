// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import "solmate/src/auth/Owned.sol";
import "./ERC721Hub.sol";

// import "./IERC721.sol";

// import "hardhat/console.sol";

contract SampleERC721Hub is ERC721Hub, Owned {
    uint256 public constant MAX_SUPPLY = 2048;
    uint256 public constant PRICE = .02 ether;

    uint256 public totalSupply;

    constructor() ERC721Hub("SERC721Hub", "721H") Owned(msg.sender) {}

    // ERC721 Functionality
    // Most non-view functions will have two cases - one where the caller is an EOA, and another
    // where the caller is the standalone spoke.

    // Events: Transfer, Approval, ApprovalForAll - emitted from hub contract
    // ERC721 Functions:
    // balanceOf(address _owner) external view returns (uint256);
    // ownerOf(uint256 _tokenId) external view returns (address);
    // safeTransferFrom(address _from, address _to, uint256 _tokenId, bytes data) external payable;
    // safeTransferFrom(address _from, address _to, uint256 _tokenId) external payable;
    // transferFrom(address _from, address _to, uint256 _tokenId) external payable;
    // approve(address _approved, uint256 _tokenId) external payable;
    // setApprovalForAll(address _operator, bool _approved) external;
    // getApproved(uint256 _tokenId) external view returns (address);
    // isApprovedForAll(address _owner, address _operator) external view returns (bool);

    // ERC721Metadata functions: tokenURI, name, symbol

    /* Minting Logic */
    function mintWithEth() external payable {
        require(msg.value == PRICE, "NOT_ENOUGH_ETH");
        _mint(msg.sender, ++totalSupply);
    }

    function _mint(address to, uint256 id) internal virtual override {
        require(id < MAX_SUPPLY, "OUT_OF_STOCK");
        super._mint(to, id);
    }
}
