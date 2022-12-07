// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity >=0.8.0;

import "solmate/src/tokens/ERC721.sol";

/// @notice Modified ERC721 that generates an individual contract for each token.
/// @author Team 4
interface ISpoke {
    function setOwner(address to) external payable;
}

abstract contract ERC721Hub is ERC721 {
    /*//////////////////////////////////////////////////////////////
                     ERC721HUB-SPECIFIC STORAGE/MODS
    //////////////////////////////////////////////////////////////*/
    mapping(uint256 => address) public spokes;

    /*//////////////////////////////////////////////////////////////
                               CONSTRUCTOR
    //////////////////////////////////////////////////////////////*/

    constructor(
        string memory _name,
        string memory _symbol
    ) ERC721(_name, _symbol) {}

    /*//////////////////////////////////////////////////////////////
                              TRANSFER LOGIC
    //////////////////////////////////////////////////////////////*/

    /* Transfers */
    function transferFrom(
        address from,
        address to,
        uint256 id
    ) public virtual override {
        super.transferFrom(from, to, id);
        ISpoke(spokes[id]).setOwner(to);
    }

    /*//////////////////////////////////////////////////////////////
                        INTERNAL MINT/BURN LOGIC
    //////////////////////////////////////////////////////////////*/

    function _burn(uint256 id) internal virtual override {
        super._burn(id);
        delete spokes[id];
    }
}
