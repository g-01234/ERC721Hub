pragma solidity 0.8.17;

import "solmate/src/utils/LibString.sol";

contract SampleRenderer {
    /* Pixel/Art Stuff - Will need to be reorganized */
    /* Much of this could go in a separate renderer contract */

    uint8 private constant PX_WH = 8; // 8x8 pixels
    uint8 private constant BYTE_PER_PX = 4; // 4 bytes per pixel
    uint8 private constant PX_PER_SLOT = 8; // 8 pixels per slot
    uint8 private constant RESOLUTION = 24; // 24x24 pixels

    bytes16 private constant _SYMBOLS = "0123456789abcdef";
    string private constant rx = "<rect x='";
    string private constant ry = "' y='";
    string private constant rwh = "' width='8' height='8' fill='";
    string private constant rc = "'/>";

    // 24 x 24 grid = 576 pixels
    // [uint8, uint8, uint8, uint8] = [r, g, b, a]
    // 4 bytes per pixel -> 8 pixels per slot -> 72 slots
    // pixel #s: 01 == (0, 0), 02 == (1, 0)
    // 01 02 03 04 05 06 07 08 word1 - start y=0
    // 09 10 11 12 13 14 15 16 word2
    // 17 18 19 20 21 22 23 24 word3 - end y=0
    // 25 26 27 28 29 30 31 32 word4 - start y=1
    // 33 34 35 36 37 38 39 40 word5
    // 41 42 43 44 45 46 47 48 word6 - end y=1
    // etc..
    uint8[2304] public pixels;

    string internal constant SVG_HEADER =
        '<svg xmlns="http://www.w3.org/2000/svg" version="1.2" viewBox="0 0 128 128">';
    string internal constant SVG_FOOTER = "</svg>";

    function generateSvg() public view returns (string memory) {
        string memory svg = SVG_HEADER;

        for (uint8 y = 0; y < 16; ) {
            for (uint8 x = 0; x < 16; ) {
                svg = string(
                    abi.encodePacked(
                        svg,
                        rx,
                        LibString.toString(x * PX_WH),
                        ry,
                        LibString.toString(y * PX_WH),
                        rwh,
                        rgbaToHex(getPixelFromCoords(x, y)),
                        rc
                    )
                );
                unchecked {
                    ++x;
                }
            }
            unchecked {
                ++y;
            }
        }

        svg = string(abi.encodePacked(svg, "</svg>"));
        return svg;
    }

    // /// @param wordSlot -
    // function getWordOfPixels(uint8 wordSlot) internal view returns (bytes32) {

    // }

    function getPixelFromCoords(
        uint256 x,
        uint256 y
    ) public view returns (uint8[4] memory) {
        uint8[4] memory pixel;
        uint256 serial = (y * RESOLUTION * BYTE_PER_PX) + (x * BYTE_PER_PX);
        for (uint8 i = 0; i < 4; i++) {
            pixel[i] = pixels[serial + i];
        }
        return pixel;
    }

    function garbage() public view returns (string memory) {
        return u8ToHexDigits(255);
    }

    function rgbaToHex(
        uint8[4] memory rgba
    ) internal view returns (string memory) {
        return
            string(
                abi.encodePacked(
                    "#",
                    u8ToHexDigits(rgba[0]),
                    u8ToHexDigits(rgba[1]),
                    u8ToHexDigits(rgba[2]),
                    u8ToHexDigits(rgba[3])
                )
            );
    }

    /**
     * @dev Converts a `uint8` to its ASCII `hex` digits, without 0x prefix.
     */
    function u8ToHexDigits(
        uint256 value
    ) internal pure returns (string memory) {
        bytes memory buffer = new bytes(2);

        buffer[1] = _SYMBOLS[value & 0xf];
        buffer[0] = _SYMBOLS[(value >> 4) & 0xf];
        return string(buffer);
    }

    function setPixels(uint8[2304] calldata _pixels) external {
        require(msg.sender == _ownerOf, "NOT_OWNER");
        pixels = _pixels;
    }

    function setPixelsAssembly(uint8[2304] calldata) external {
        require(msg.sender == _ownerOf, "NOT_OWNER");

        assembly {
            let pxNum := 0
            for {
                let wordNum := 0
            } lt(wordNum, 72) {
                // 2304 / 32 = 72
                wordNum := add(wordNum, 1)
            } {
                mstore(0x40, 0x0) // zero the mem we're using to be safe
                for {
                    let cursor := 0
                } lt(cursor, 32) {
                    cursor := add(cursor, 1)
                } {
                    let buffer := mload(0x40)
                    // paaaack it in
                    mstore(
                        0x40,
                        add(
                            buffer,
                            shl(
                                mul(cursor, 8),
                                calldataload(add(mul(32, pxNum), 4))
                            )
                        )
                    )
                    pxNum := add(pxNum, 1)
                }
                sstore(add(pixels.slot, wordNum), mload(0x40))
            }
        }
    }

    function setPixelsAssembly2(uint8[2304] calldata) external {
        require(msg.sender == _ownerOf, "NOT_OWNER");

        assembly {
            let pxNum := 0
            for {
                let wordNum := 0
            } lt(wordNum, 72) {
                // 2304 / 32 = 72
                wordNum := add(wordNum, 1)
            } {
                mstore(0x40, 0x0) // zero the mem we're using to be safe
                for {
                    let cursor := 0
                } lt(cursor, 32) {
                    cursor := add(cursor, 1)
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
    }

    function setPixels2(uint8[2304] calldata _pixels) external {
        require(msg.sender == _ownerOf, "NOT_OWNER");
        pixels = _pixels;
    }
}
