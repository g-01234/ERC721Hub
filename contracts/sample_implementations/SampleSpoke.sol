pragma solidity 0.8.17;

import "../Spoke.sol";

contract SampleSpoke is Spoke {
    string public name;

    constructor(address _owner, uint256 _tokenId) Spoke(_owner, _tokenId) {}

    // Lets us give our spoke a name
    function setName(string memory _name) external {
        require(msg.sender == owner, "NOT_AUTHORIZED");
        name = _name;
    }

    function tokenURI(uint256 id) external view returns (string memory) {
        return "wip";
    }
}
