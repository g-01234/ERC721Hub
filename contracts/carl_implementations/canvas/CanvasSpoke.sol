pragma solidity 0.8.17;

import "../../Spoke.sol";

interface Renderer {
    function render() external view returns (string memory);

    function setPixels(uint8[2304] calldata _pixels) external;
}

contract CanvasSpoke is Spoke {
    uint8[2304] public pixels;
    address public renderer;

    constructor(
        address _owner,
        uint256 _tokenId,
        address _defaultRenderer
    ) Spoke(_owner, _tokenId) {
        renderer = _defaultRenderer;
    }

    function delegateRender() public returns (string memory) {
        require(msg.sender == address(this)); // lmao
        (bool success, bytes memory result) = renderer.delegatecall(
            abi.encodeWithSelector(Renderer(renderer).render.selector)
        );
        require(success, "FAILED_TO_RENDER");
        return abi.decode(result, (string));
    }

    function renderSVG() public view returns (string memory) {
        (bool success, bytes memory data) = address(this).staticcall(
            abi.encodeWithSelector(this.delegateRender.selector)
        );
        require(success);
        return abi.decode(data, (string));
    }

    function setRenderer(address _renderer) external {
        require(msg.sender == owner, "NOT_AUTHORIZED");
        renderer = renderer;
    }

    function setPixels(uint8[2304] calldata _pixels) external {
        require(msg.sender == owner, "NOT_OWNER");
        (bool success, ) = renderer.delegatecall(
            abi.encodeWithSelector(
                Renderer(renderer).setPixels.selector,
                _pixels
            )
        );
        require(success, "FAILED_TO_SET_PIXELS");
    }
}
