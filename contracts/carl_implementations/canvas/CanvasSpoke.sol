// SPDX-License-Identifier: AGPL-3.0-only

pragma solidity 0.8.17;
import "../../Spoke.sol";

/// @notice A spoke that stores a 16x16 grid of pixels.
/// @author @popular_12345 / popular#1234
interface Renderer {
    function renderSVG() external view returns (string memory);

    function tokenURI(uint256 tokenId) external view returns (string memory);
}

contract CanvasSpoke is Spoke {
    // 16 x 16 grid = 256 pixels
    // [uint8, uint8, uint8, uint8] = [r, g, b, a]
    // 4 bytes per pixel -> 8 pixels per slot -> 32 slots total
    // pixel #s: 01 == (0, 0), 02 == (1, 0) ...
    // 01 02 03 04 05 06 07 08 word1 - y=0
    // 09 10 11 12 13 14 15 16 word2 - y=0
    // 17 18 19 20 21 22 23 24 word3 - y=1
    // 25 26 27 28 29 30 31 32 word4 - y=1
    // 33 34 35 36 37 38 39 40 word5 - y=2
    // 41 42 43 44 45 46 47 48 word6 - y=2
    // etc..
    uint8[1024] public pixels;

    address public renderer;
    bool public pixelsSet;

    constructor(
        address _owner,
        uint256 _tokenId,
        address _defaultRenderer
    ) Spoke(_owner, _tokenId) {
        renderer = _defaultRenderer;
    }

    function tokenURI(uint256 id) external view returns (string memory) {
        return Renderer(renderer).tokenURI(id);
    }

    function renderSVG() external view returns (string memory) {
        return Renderer(renderer).renderSVG();
    }

    function getPixels() external view returns (uint8[1024] memory) {
        return pixels;
    }

    function setRenderer(address _renderer) external onlyOwner {
        renderer = _renderer;
    }

    // calldata isn't packed - need to pack it into memory -> store it
    function setPixels(uint8[1024] calldata) external onlyOwner {
        assembly {
            let pxNum := 0
            for {
                let wordNum := 0
            } lt(wordNum, 32) {
                wordNum := add(1, wordNum)
            } {
                mstore(0x40, 0x0) // zero the mem we're using to be safe
                for {
                    let cursor := 0
                } lt(cursor, 32) {
                    cursor := add(1, cursor)
                } {
                    let buffer := mload(0x40)
                    // paaaack it in
                    mstore(
                        0x40,
                        add(
                            buffer,
                            shl(
                                mul(8, cursor),
                                calldataload(add(4, mul(32, pxNum)))
                            )
                        )
                    )
                    pxNum := add(1, pxNum)
                }
                sstore(add(pixels.slot, wordNum), mload(0x40))
            }
        }
        pixelsSet = true;
    }

    // Note that the storage is not zeroed out, so this is not a true "unset".
    // Would have to zero everything in setPixels() and then use this.
    function unsetPixels() external onlyOwner {
        pixelsSet = false;
    }
}
