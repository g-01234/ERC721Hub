// pragma solidity 0.8.17;

// import "solmate/src/utils/LibString.sol";
// import "./IERC721.sol"; // Trying to avoid importing the whole factory for each deployed token
// // import "./CanvasMaker.sol";
// import "hardhat/console.sol";

// interface IFactory {
//     function setApprovalForAllOnlyCanvas(
//         address _owner,
//         address _operator,
//         bool _approved,
//         uint256 _tokenId
//     ) external;
// }

// contract ERC721Spoke {
//     bytes4 constant SET_APPROVAL_ONLY_CANVAS = hex"3305e316";
//     // ERC721 Functionality
//     // Most non-view functions will have two cases - one where the caller is an EOA, and another
//     // where the caller is the standalone canvas

//     // Events: Transfer, Approval, ApprovalForAll - emitted from hub contract
//     // ERC721 Functions:
//     // balanceOf(address _owner) external view returns (uint256);
//     // ownerOf(uint256 _tokenId) external view returns (address);
//     // safeTransferFrom(address _from, address _to, uint256 _tokenId, bytes data) external payable;
//     // safeTransferFrom(address _from, address _to, uint256 _tokenId) external payable;
//     // transferFrom(address _from, address _to, uint256 _tokenId) external payable;
//     // approve(address _approved, uint256 _tokenId) external payable;
//     // setApprovalForAll(address _operator, bool _approved) external;
//     // getApproved(uint256 _tokenId) external view returns (address);
//     // isApprovedForAll(address _owner, address _operator) external view returns (bool);

//     // ERC721Metadata functions: tokenURI, name, symbol

//     /* ERC721 Stuff */
//     IERC721 public factory;
//     address public ownerOf;
//     uint256 public immutable tokenId;

//     address private _getApproved;

//     // bytes4 constant SET_APPROVAL_SELECTOR = bytes4("a22cb465")

//     // is there a way to make these immutable in assembly - bytes[11] doesn't work
//     string public name;
//     string public symbol;

//     constructor(address _owner, uint256 _tokenId) {
//         ownerOf = _owner;
//         tokenId = _tokenId;
//         factory = IERC721(msg.sender);
//         name = string(
//             abi.encodePacked("Canvas #", LibString.toString(_tokenId))
//         );
//     }

//     function transferFrom(address from, address to, uint256 id) external {
//         require(isApprovedForAll(ownerOf, msg.sender));
//         delete _getApproved;
//         factory.transferFrom(from, to, tokenId);
//         ownerOf = to;
//     }

//     function approve(address spender, uint256 id) external {
//         if (msg.sender != address(factory)) {
//             require(
//                 msg.sender == ownerOf || isApprovedForAll(ownerOf, msg.sender)
//             );
//             factory.approve(spender, id); // need to check approval in factory
//         }
//         _getApproved = spender;
//     }

//     // Ugly but not sure how else to do it
//     function setApprovalForAll(address _operator, bool _approved) external {
//         // Can probably remove the success check? Not sure how this would ever fail
//         // (bool success, ) = address(factory).call(
//         //     abi.encodeWithSelector(
//         //         SET_APPROVAL_ONLY_CANVAS,
//         //         msg.sender,
//         //         _operator,
//         //         _approved,
//         //         tokenId
//         //     )
//         // );
//         // require(success);
//         IFactory(address(factory)).setApprovalForAllOnlyCanvas(
//             msg.sender,
//             _operator,
//             _approved,
//             tokenId
//         );
//     }

//     /* View functions */
//     function getApproved(uint256 _tokenId) external view returns (address) {
//         return _getApproved;
//     }

//     function isApprovedForAll(
//         address owner,
//         address spender
//     ) public view returns (bool) {
//         return (factory.isApprovedForAll(owner, spender));
//     }

//     function tokenURI(uint256 id) external view returns (string memory) {
//         // Currently have a separate function that generates a SVG (generateSVG())
//         return "wip";
//     }

//     function balanceOf(address owner) external view returns (uint256) {
//         return IERC721(factory).balanceOf(msg.sender);
//     }

//     /* Pixel/Art Stuff - Will need to be reorganized */
//     /* Much of this could go in a separate renderer contract */

//     uint8 private constant PX_WH = 8; // 8x8 pixels
//     uint8 private constant BYTE_PER_PX = 4; // 4 bytes per pixel
//     uint8 private constant PX_PER_SLOT = 8; // 8 pixels per slot
//     uint8 private constant RESOLUTION = 24; // 24x24 pixels

//     bytes16 private constant _SYMBOLS = "0123456789abcdef";
//     string private constant rx = "<rect x='";
//     string private constant ry = "' y='";
//     string private constant rwh = "' width='8' height='8' fill='";
//     string private constant rc = "'/>";

//     // 24 x 24 grid = 576 pixels
//     // [uint8, uint8, uint8, uint8] = [r, g, b, a]
//     // 4 bytes per pixel -> 8 pixels per slot -> 72 slots
//     // pixel #s: 01 == (0, 0), 02 == (1, 0)
//     // 01 02 03 04 05 06 07 08 word1 - start y=0
//     // 09 10 11 12 13 14 15 16 word2
//     // 17 18 19 20 21 22 23 24 word3 - end y=0
//     // 25 26 27 28 29 30 31 32 word4 - start y=1
//     // 33 34 35 36 37 38 39 40 word5
//     // 41 42 43 44 45 46 47 48 word6 - end y=1
//     // etc..
//     uint8[2304] public pixels;

//     string internal constant SVG_HEADER =
//         '<svg xmlns="http://www.w3.org/2000/svg" version="1.2" viewBox="0 0 128 128">';
//     string internal constant SVG_FOOTER = "</svg>";

//     function generateSvg() public view returns (string memory) {
//         string memory svg = SVG_HEADER;

//         for (uint8 y = 0; y < 16; ) {
//             for (uint8 x = 0; x < 16; ) {
//                 svg = string(
//                     abi.encodePacked(
//                         svg,
//                         rx,
//                         LibString.toString(x * PX_WH),
//                         ry,
//                         LibString.toString(y * PX_WH),
//                         rwh,
//                         rgbaToHex(getPixelFromCoords(x, y)),
//                         rc
//                     )
//                 );
//                 unchecked {
//                     ++x;
//                 }
//             }
//             unchecked {
//                 ++y;
//             }
//         }

//         svg = string(abi.encodePacked(svg, "</svg>"));
//         return svg;
//     }

//     // /// @param wordSlot -
//     // function getWordOfPixels(uint8 wordSlot) internal view returns (bytes32) {

//     // }

//     function getPixelFromCoords(
//         uint256 x,
//         uint256 y
//     ) public view returns (uint8[4] memory) {
//         uint8[4] memory pixel;
//         uint256 serial = (y * RESOLUTION * BYTE_PER_PX) + (x * BYTE_PER_PX);
//         for (uint8 i = 0; i < 4; i++) {
//             pixel[i] = pixels[serial + i];
//         }
//         return pixel;
//     }

//     function garbage() public view returns (string memory) {
//         return u8ToHexDigits(255);
//     }

//     function rgbaToHex(
//         uint8[4] memory rgba
//     ) internal view returns (string memory) {
//         return
//             string(
//                 abi.encodePacked(
//                     "#",
//                     u8ToHexDigits(rgba[0]),
//                     u8ToHexDigits(rgba[1]),
//                     u8ToHexDigits(rgba[2]),
//                     u8ToHexDigits(rgba[3])
//                 )
//             );
//     }

//     /**
//      * @dev Converts a `uint8` to its ASCII `hex` digits, without 0x prefix.
//      */
//     function u8ToHexDigits(
//         uint256 value
//     ) internal pure returns (string memory) {
//         bytes memory buffer = new bytes(2);

//         buffer[1] = _SYMBOLS[value & 0xf];
//         buffer[0] = _SYMBOLS[(value >> 4) & 0xf];
//         return string(buffer);
//     }

//     function setPixels(uint8[2304] calldata _pixels) external {
//         require(msg.sender == ownerOf, "NOT_OWNER");
//         pixels = _pixels;
//     }

//     function setPixelsAssembly(uint8[2304] calldata) external {
//         require(msg.sender == ownerOf, "NOT_OWNER");

//         assembly {
//             let pxNum := 0
//             for {
//                 let wordNum := 0
//             } lt(wordNum, 72) {
//                 // 2304 / 32 = 72
//                 wordNum := add(wordNum, 1)
//             } {
//                 mstore(0x40, 0x0) // zero the mem we're using to be safe
//                 for {
//                     let cursor := 0
//                 } lt(cursor, 32) {
//                     cursor := add(cursor, 1)
//                 } {
//                     let buffer := mload(0x40)
//                     // paaaack it in
//                     mstore(
//                         0x40,
//                         add(
//                             buffer,
//                             shl(
//                                 mul(cursor, 8),
//                                 calldataload(add(mul(32, pxNum), 4))
//                             )
//                         )
//                     )
//                     pxNum := add(pxNum, 1)
//                 }
//                 sstore(add(pixels.slot, wordNum), mload(0x40))
//             }
//         }
//     }

//     function setPixelsAssembly2(uint8[2304] calldata) external {
//         require(msg.sender == ownerOf, "NOT_OWNER");

//         assembly {
//             let pxNum := 0
//             for {
//                 let wordNum := 0
//             } lt(wordNum, 72) {
//                 // 2304 / 32 = 72
//                 wordNum := add(wordNum, 1)
//             } {
//                 mstore(0x40, 0x0) // zero the mem we're using to be safe
//                 for {
//                     let cursor := 0
//                 } lt(cursor, 32) {
//                     cursor := add(cursor, 1)
//                 } {
//                     let buffer := mload(0x40)
//                     // paaaack it in
//                     mstore(
//                         0x40,
//                         add(
//                             buffer,
//                             shl(
//                                 mul(8, cursor),
//                                 calldataload(add(4, mul(32, pxNum)))
//                             )
//                         )
//                     )
//                     pxNum := add(1, pxNum)
//                 }
//                 sstore(add(pixels.slot, wordNum), mload(0x40))
//             }
//         }
//     }

//     function setPixels2(uint8[2304] calldata _pixels) external {
//         require(msg.sender == ownerOf, "NOT_OWNER");
//         pixels = _pixels;
//     }

//     /* ERC165 Logic */
//     function supportsInterface(
//         bytes4 interfaceId
//     ) public view virtual returns (bool) {
//         return
//             interfaceId == 0x01ffc9a7 || // ERC165 Interface ID for ERC165
//             interfaceId == 0x80ac58cd || // ERC165 Interface ID for ERC721
//             interfaceId == 0x5b5e139f; // ERC165 Interface ID for ERC721Metadata
//     }
// }
