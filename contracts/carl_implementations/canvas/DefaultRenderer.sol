// SPDX-License-Identifier: AGPL-3.0-only

pragma solidity 0.8.17;

import "solmate/src/utils/LibString.sol";
import "./Base64.sol";

interface ISpoke {
    function pixelsSet() external view returns (bool);

    function getPixels() external view returns (uint8[1024] memory);
}

/// @author @popular_12345 / popular#1234
contract DefaultRenderer {
    uint8[1024] public pixels;
    uint8 private constant PX_WH = 8; // 8x8 pixels
    uint8 private constant BYTE_PER_PX = 4; // 4 bytes per pixel
    uint8 private constant RESOLUTION = 16; // 24x24 pixels

    bytes16 private constant _SYMBOLS = "0123456789abcdef";
    string private constant RX = '<rect x="';
    string private constant RY = '" y="';
    string private constant RWH = '" width="8" height="8" fill="';
    string private constant RC = '"/>';

    string private constant MD1 = '{"name":"Canvas #';
    string private constant MD2 =
        '","description":"TEST","image":"data:image/svg+xml;base64,';
    string private constant MD3 = '"}';

    string internal constant SVG_HEADER =
        '<svg xmlns="http://www.w3.org/2000/svg" width="100%" height="100%" viewBox="0 0 128 128">';
    string internal constant SVG_FOOTER = "</svg>";

    function tokenURI(uint256 tokenId) external view returns (string memory) {
        string memory json = Base64.encode(
            bytes(
                string(
                    abi.encodePacked(
                        MD1,
                        LibString.toString(tokenId),
                        MD2,
                        renderSVG(),
                        MD3
                    )
                )
            )
        );
        return string(abi.encodePacked("data:application/json;base64,", json));
    }

    function renderSVG() public view returns (string memory) {
        bool ps = ISpoke(msg.sender).pixelsSet();
        uint8[1024] memory _pixels;
        uint256 px; // pixel index
        if (ps) {
            _pixels = ISpoke(msg.sender).getPixels();
        }

        string memory svg = SVG_HEADER;
        for (uint8 y = 0; y < 16; y++) {
            for (uint8 x = 0; x < 16; x++) {
                svg = string.concat(
                    svg,
                    RX,
                    LibString.toString(x * PX_WH),
                    RY,
                    LibString.toString(y * PX_WH),
                    RWH,
                    ps
                        ? rgbaToHex(
                            [
                                _pixels[px],
                                _pixels[px + 1],
                                _pixels[px + 2],
                                _pixels[px + 3]
                            ]
                        )
                        : getRandyPixel(x + y),
                    RC
                );
                px += 4;
            }
        }
        svg = string.concat(svg, SVG_FOOTER);
        return Base64.encode(bytes(svg));
    }

    // Will result in unique image for each token
    function getRandyPixel(uint8 salt) internal view returns (string memory) {
        bytes4 hash = bytes4(
            keccak256(abi.encodePacked(address(this), msg.sender, salt))
        );
        return
            string(
                abi.encodePacked(
                    "#",
                    u8ToHexDigits(uint8(hash[0])),
                    u8ToHexDigits(uint8(hash[1])),
                    u8ToHexDigits(uint8(hash[2])),
                    u8ToHexDigits(uint8(hash[3]))
                )
            );
    }

    function rgbaToHex(
        uint8[4] memory rgba
    ) internal pure returns (string memory) {
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

    // Converts a `uint8` to its ASCII `hex` digits, without 0x prefix.
    function u8ToHexDigits(
        uint256 value
    ) internal pure returns (string memory) {
        bytes memory buffer = new bytes(2);

        buffer[1] = _SYMBOLS[value & 0xf];
        buffer[0] = _SYMBOLS[(value >> 4) & 0xf];
        return string(buffer);
    }
}
