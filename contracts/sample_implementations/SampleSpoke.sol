pragma solidity 0.8.17;

import "../Spoke.sol";

contract SampleSpoke is Spoke {
    constructor(address _owner, uint256 _tokenId) Spoke(_owner, _tokenId) {}

    function tokenURI(uint256 id) external view returns (string memory) {
        return "wip";
    }
}
