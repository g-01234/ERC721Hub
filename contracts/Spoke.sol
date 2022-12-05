pragma solidity 0.8.17;

import "./ERC721Hub.sol";
import "solmate/src/utils/LibString.sol";

contract Spoke {
    address public hub;
    address public owner;
    uint256 public immutable tokenId;

    string public name;

    constructor(address _owner, uint256 _tokenId) {
        owner = _owner;
        tokenId = _tokenId;
        hub = msg.sender;
        name = string(
            abi.encodePacked("Spoke #", LibString.toString(_tokenId))
        );
    }

    function transferOwnership(address to) external {
        require(msg.sender == address(hub), "NOT_AUTHORIZED");
        owner = to;
    }
}
