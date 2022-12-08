pragma solidity 0.8.17;

import "../../ERC721Hub.sol";
import "solmate/src/utils/LibString.sol";

import "hardhat/console.sol";

/// @author @popular_12345 / popular#1234
interface IHub {
    function setApprovalForAllOnlySpoke(
        address _owner,
        address _operator,
        bool _approved,
        uint256 _tokenId
    ) external;
}

contract ERC721Spoke {
    // ERC721 Functionality
    // Most non-view functions will have two cases - one where the caller is an EOA, and another
    // where the caller is the standalone canvas

    // Events: Transfer, Approval, ApprovalForAll - emitted from hub contract
    // ERC721 Functions:
    // balanceOf(address _owner) external view returns (uint256);
    // _ownerOf(uint256 _tokenId) external view returns (address);
    // safeTransferFrom(address _from, address _to, uint256 _tokenId, bytes data) external payable;
    // safeTransferFrom(address _from, address _to, uint256 _tokenId) external payable;
    // transferFrom(address _from, address _to, uint256 _tokenId) external payable;
    // approve(address _approved, uint256 _tokenId) external payable;
    // setApprovalForAll(address _operator, bool _approved) external;
    // getApproved(uint256 _tokenId) external view returns (address);
    // isApprovedForAll(address _owner, address _operator) external view returns (bool);

    // ERC721Metadata functions: tokenURI, name, symbol

    /* ERC721 Stuff */
    ERC721Hub public hub;
    address internal _ownerOf;
    uint256 public immutable tokenId;

    address private _getApproved;

    // bytes4 constant SET_APPROVAL_SELECTOR = bytes4("a22cb465")

    // is there a way to make these immutable in assembly - bytes[11] doesn't work
    string public name;
    string public symbol;

    constructor(address _owner, uint256 _tokenId) {
        _ownerOf = _owner;
        tokenId = _tokenId;
        hub = ERC721Hub(msg.sender);
        name = string(
            abi.encodePacked("Canvas #", LibString.toString(_tokenId))
        );
    }

    function ownerOf(uint256) external view returns (address) {
        return _ownerOf;
    }

    /* View functions */
    function getApproved(uint256 _tokenId) external view returns (address) {
        return _getApproved;
    }

    function isApprovedForAll(
        address owner,
        address spender
    ) public view returns (bool) {
        return (hub.isApprovedForAll(owner, spender));
    }

    function tokenURI(uint256 id) external view returns (string memory) {
        // Currently have a separate function that generates a SVG (generateSVG())
        return "wip";
    }

    function balanceOf(address owner) external view returns (uint256) {
        return hub.balanceOf(msg.sender);
    }

    /* Approvals */
    function approve(address spender, uint256 id) external {
        if (msg.sender != address(hub)) {
            require(
                msg.sender == _ownerOf || isApprovedForAll(_ownerOf, msg.sender)
            );
            hub.approve(spender, id); // need to check approval in hub
        }
        _getApproved = spender;
    }

    // Ugly but not sure how else to do it
    function setApprovalForAll(address _operator, bool _approved) external {
        IHub(address(hub)).setApprovalForAllOnlySpoke(
            msg.sender,
            _operator,
            _approved,
            tokenId
        );
    }

    /* Transfers */
    function transferFrom(address from, address to, uint256 id) public {
        require(
            _ownerOf == msg.sender ||
                address(hub) == msg.sender ||
                _getApproved == msg.sender ||
                isApprovedForAll(from, msg.sender)
        );
        _ownerOf = to;
        delete _getApproved;

        if (msg.sender != address(hub)) {
            hub.transferFrom(from, to, tokenId);
        }
    }

    function safeTransferFrom(
        address from,
        address to,
        uint256 id
    ) public virtual {
        transferFrom(from, to, id);

        require(
            to.code.length == 0 ||
                ERC721TokenReceiver(to).onERC721Received(
                    msg.sender,
                    from,
                    id,
                    ""
                ) ==
                ERC721TokenReceiver.onERC721Received.selector,
            "UNSAFE_RECIPIENT"
        );
    }

    function safeTransferFrom(
        address from,
        address to,
        uint256 id,
        bytes calldata data
    ) public virtual {
        transferFrom(from, to, id);

        require(
            to.code.length == 0 ||
                ERC721TokenReceiver(to).onERC721Received(
                    msg.sender,
                    from,
                    id,
                    data
                ) ==
                ERC721TokenReceiver.onERC721Received.selector,
            "UNSAFE_RECIPIENT"
        );
    }

    /* ERC165 Logic */
    function supportsInterface(
        bytes4 interfaceId
    ) public view virtual returns (bool) {
        return
            interfaceId == 0x01ffc9a7 || // ERC165 Interface ID for ERC165
            interfaceId == 0x80ac58cd || // ERC165 Interface ID for ERC721
            interfaceId == 0x5b5e139f; // ERC165 Interface ID for ERC721Metadata
    }
}
