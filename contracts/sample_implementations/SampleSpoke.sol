pragma solidity 0.8.17;

import "../Spoke.sol";

// Very basic Spoke implementation. This is a simple implementation that has
// that allows users to set a name for their spoke.
contract SampleSpoke is Spoke {
    string public name;
    string public tokenURI;

    constructor(address _owner, uint256 _tokenId) Spoke(_owner, _tokenId) {}

    // Lets us give our spoke a name
    function setName(string memory _name) external {
        require(msg.sender == owner, "NOT_AUTHORIZED");
        name = _name;
    }

    function setTokenURI(string memory _tokenURI) external {
        require(msg.sender == owner, "NOT_AUTHORIZED");
        tokenURI = _tokenURI;
    }
}
