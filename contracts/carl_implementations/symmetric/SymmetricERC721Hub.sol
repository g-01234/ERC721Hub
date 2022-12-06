// // SPDX-License-Identifier: AGPL-3.0-only
// pragma solidity >=0.8.0;

// import "../ERC721Hub.sol";

// /// @notice Modified ERC721 that generates an individual contract for each token.
// /// @author Team 4
// /// @ thanks Solmate (https://github.com/transmissions11/solmate/blob/main/src/tokens/ERC721.sol)

// abstract contract SymmetricERC721Hub is ERC721Hub {
//     function tokenURI(uint256 id) public view override returns (string memory) {
//         require(spokes[id] != address(0), "DOES_NOT_EXIST");
//         return IERC721Spoke(spokes[id]).tokenURI(id);
//     }

//     function ownerOf(
//         uint256 id
//     ) public view virtual override returns (address owner) {
//         require(
//             (owner = IERC721Spoke(spokes[id]).ownerOf(id)) != address(0),
//             "NOT_MINTED"
//         );
//     }

//     modifier onlySpoke(uint256 id) {
//         require(msg.sender == spokes[id], "NOT_SPOKE");
//         _;
//     }

//     /*//////////////////////////////////////////////////////////////
//                               ERC721 LOGIC
//     //////////////////////////////////////////////////////////////*/
//     function approve(address _approved, uint256 _tokenId) external override {
//         // Can skip this require if msg.sender is the spoke, already handle
//         // authorizations there
//         address spoke = spokes[_tokenId];
//         if (msg.sender != spokes[_tokenId]) {
//             require(isAuthorized(msg.sender, _tokenId), "NOT_AUTHORIZED");
//             IERC721Spoke(spoke).approve(_approved, _tokenId);
//         }
//         getApproved[_tokenId] = _approved;
//     }

//     function setApprovalForAllOnlySpoke(
//         address _owner,
//         address _operator,
//         bool _approved,
//         uint256 _tokenId
//     ) external onlySpoke(_tokenId) {
//         isApprovedForAll[_owner][_operator] = _approved;
//         emit ApprovalForAll(_owner, _operator, _approved);
//     }

//     /* Transfers */
//     function transferFrom(
//         address from,
//         address to,
//         uint256 id
//     ) public virtual override {
//         require(from == _ownerOf[id], "WRONG_FROM");

//         require(to != address(0), "INVALID_RECIPIENT");

//         address spoke = spokes[id];
//         bool fromSpoke = (msg.sender == spoke);

//         require(
//             msg.sender == from ||
//                 fromSpoke ||
//                 isApprovedForAll[from][msg.sender] ||
//                 msg.sender == getApproved[id],
//             "NOT_AUTHORIZED"
//         );

//         // Underflow of the sender's balance is impossible because we check for
//         // ownership above and the recipient's balance can't realistically overflow.
//         unchecked {
//             _balanceOf[from]--;

//             _balanceOf[to]++;
//         }

//         _ownerOf[id] = to;

//         delete getApproved[id];

//         if (!fromSpoke) IERC721Spoke(spoke).transferFrom(from, to, id);

//         emit Transfer(from, to, id);
//     }

//     function safeTransferFrom(
//         address from,
//         address to,
//         uint256 id
//     ) public virtual {
//         transferFrom(from, to, id);

//         require(
//             to.code.length == 0 ||
//                 ERC721TokenReceiver(to).onERC721Received(
//                     msg.sender,
//                     from,
//                     id,
//                     ""
//                 ) ==
//                 ERC721TokenReceiver.onERC721Received.selector,
//             "UNSAFE_RECIPIENT"
//         );
//     }

//     function safeTransferFrom(
//         address from,
//         address to,
//         uint256 id,
//         bytes calldata data
//     ) public virtual {
//         transferFrom(from, to, id);

//         require(
//             to.code.length == 0 ||
//                 ERC721TokenReceiver(to).onERC721Received(
//                     msg.sender,
//                     from,
//                     id,
//                     data
//                 ) ==
//                 ERC721TokenReceiver.onERC721Received.selector,
//             "UNSAFE_RECIPIENT"
//         );
//     }

//     function isAuthorized(
//         address _operator,
//         uint256 _tokenId
//     ) internal view returns (bool) {
//         address _owner = _ownerOf[_tokenId];
//         return (_owner == _operator ||
//             isApprovedForAll[_owner][_operator] == true ||
//             getApproved[_tokenId] == _operator);
//     }

//     /*//////////////////////////////////////////////////////////////
//                               ERC165 LOGIC
//     //////////////////////////////////////////////////////////////*/

//     function supportsInterface(
//         bytes4 interfaceId
//     ) public view virtual returns (bool) {
//         return
//             interfaceId == 0x01ffc9a7 || // ERC165 Interface ID for ERC165
//             interfaceId == 0x80ac58cd || // ERC165 Interface ID for ERC721
//             interfaceId == 0x5b5e139f; // ERC165 Interface ID for ERC721Metadata
//     }

//     /*//////////////////////////////////////////////////////////////
//                         INTERNAL MINT/BURN LOGIC
//     //////////////////////////////////////////////////////////////*/

//     function _mint(address to, uint256 id) internal virtual {
//         require(to != address(0), "INVALID_RECIPIENT");

//         require(_ownerOf[id] == address(0), "ALREADY_MINTED");

//         // Counter overflow is incredibly unrealistic.
//         unchecked {
//             _balanceOf[to]++;
//         }

//         _ownerOf[id] = to;
//         spokes[id] = address(new ERC721Spoke(to, id));

//         emit Transfer(address(0), to, id);
//     }

//     function _burn(uint256 id) internal virtual {
//         address owner = _ownerOf[id];

//         require(owner != address(0), "NOT_MINTED");

//         // Ownership check above ensures no underflow.
//         unchecked {
//             _balanceOf[owner]--;
//         }

//         delete _ownerOf[id];

//         delete getApproved[id];

//         emit Transfer(owner, address(0), id);
//     }

//     /*//////////////////////////////////////////////////////////////
//                         INTERNAL SAFE MINT LOGIC
//     //////////////////////////////////////////////////////////////*/

//     function _safeMint(address to, uint256 id) internal virtual {
//         _mint(to, id);

//         require(
//             to.code.length == 0 ||
//                 ERC721TokenReceiver(to).onERC721Received(
//                     msg.sender,
//                     address(0),
//                     id,
//                     ""
//                 ) ==
//                 ERC721TokenReceiver.onERC721Received.selector,
//             "UNSAFE_RECIPIENT"
//         );
//     }

//     function _safeMint(
//         address to,
//         uint256 id,
//         bytes memory data
//     ) internal virtual {
//         _mint(to, id);

//         require(
//             to.code.length == 0 ||
//                 ERC721TokenReceiver(to).onERC721Received(
//                     msg.sender,
//                     address(0),
//                     id,
//                     data
//                 ) ==
//                 ERC721TokenReceiver.onERC721Received.selector,
//             "UNSAFE_RECIPIENT"
//         );
//     }
// }
