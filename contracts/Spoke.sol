pragma solidity >=0.8.0;

import "./ERC721Hub.sol";
import "solmate/src/auth/Owned.sol";

/// @author @popular_12345 / popular#1234
contract Spoke is Owned {
    address public hub;
    uint256 public immutable tokenId;

    modifier onlyHub() virtual {
        require(msg.sender == hub, "UNAUTHORIZED");
        _;
    }

    constructor(address _owner, uint256 _tokenId) Owned(_owner) {
        tokenId = _tokenId;
        hub = msg.sender;
    }

    function setOwner(address newOwner) public virtual override onlyHub {
        owner = newOwner;

        // Only way to call this is in transferFrom, which already
        // emits an event
    }
}
