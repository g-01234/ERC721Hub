// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;
// import "solmate/src/tokens/ERC721.sol";
import "solmate/src/auth/Owned.sol";
import "./Canvas.sol";

import "hardhat/console.sol";

interface IERC721 {
    function ownerOf(uint256 id) external view returns (address owner);
}

contract CanvasMaker is Owned {
    uint256 public constant MAX_SUPPLY = 2048;
    uint256 public constant PRICE = .02 ether;

    uint256 public totalSupply;

    mapping(uint256 => address) public canvases;
    mapping(uint256 => address) public getApproved;

    mapping(uint256 => address) internal _ownerOf; // can delete?
    mapping(address => uint256) internal _balanceOf;

    mapping(address => mapping(address => bool)) public isApprovedForAll;

    constructor() Owned(msg.sender) {}

    // ERC721 Functionality
    // Most non-view functions will have two cases - one where the caller is an EOA, and another
    // where the caller is the standalone canvas

    // Events: Transfer, Approval, ApprovalForAll - emitted from hub contract
    // ERC721 Functions:
    // balanceOf(address _owner) external view returns (uint256);
    // ownerOf(uint256 _tokenId) external view returns (address);
    // safeTransferFrom(address _from, address _to, uint256 _tokenId, bytes data) external payable;
    // safeTransferFrom(address _from, address _to, uint256 _tokenId) external payable;
    // transferFrom(address _from, address _to, uint256 _tokenId) external payable;
    // approve(address _approved, uint256 _tokenId) external payable;
    // setApprovalForAll(address _operator, bool _approved) external;
    // getApproved(uint256 _tokenId) external view returns (address);
    // isApprovedForAll(address _owner, address _operator) external view returns (bool);

    // ERC721Metadata functions: tokenURI, name, symbol

    /* Events */
    event Transfer(
        address indexed _from,
        address indexed _to,
        uint256 indexed _tokenId
    );
    event Approval(
        address indexed _owner,
        address indexed _approved,
        uint256 indexed _tokenId
    );
    event ApprovalForAll(
        address indexed _owner,
        address indexed _operator,
        bool _approved
    );

    /* View functions */
    function ownerOf(uint256 _tokenId) public view returns (address) {
        return Canvas(canvases[_tokenId]).ownerOf(); // will correctly throw if token doesn't exist
    }

    function balanceOf(address _owner) public view virtual returns (uint256) {
        // Spec says that this must throw for queries about the 0 address
        require(owner != address(0), "ZERO_ADDRESS");
        return _balanceOf[owner];
    }

    function tokenURI(uint256 id) public view returns (string memory) {
        require(canvases[id] != address(0), "DOES_NOT_EXIST");
        return Canvas(canvases[id]).tokenURI();
    }

    /* Approvals */
    function approve(address _approved, uint256 _tokenId) external {
        // Can skip this require if msg.sender is the canvas, already handle
        // authorizations there
        if (msg.sender != canvases[_tokenId]) {
            require(isAuthorized(msg.sender, _tokenId), "NOT_AUTHORIZED");
        }
        getApproved[_tokenId] = _approved;
    }

    function setApprovalForAll(address _operator, bool _approved) external {
        isApprovedForAll[msg.sender][_operator] = _approved;
    }

    // Would prefer to not do this but only other way I can think of is using tx.origin?
    function setApprovalForAllFromCanvas(
        uint256 _tokenId,
        address _owner,
        address _operator,
        bool _approved
    ) external {
        require(fromCanvas(_tokenId), "NOT_AUTHORIZED");
        isApprovedForAll[_owner][_operator] = _approved; // is this safe?
    }

    /* Transfers */
    function transferFrom(address from, address to, uint256 tokenId) public {
        if (msg.sender == canvases[tokenId]) {
            // Call is from the canvas, can assume some things?
        } else {
            // Not using the canvas
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

    /* Minting Logic */
    function mintWithEth() external payable {
        require(msg.value == PRICE, "NOT_ENOUGH_ETH");
        cutCanvas();
    }

    // Removing address(0) checks from solmate ERC721
    function _mint(address to, uint256 id) internal {
        // Counter overflow is incredibly unrealistic.
        unchecked {
            _balanceOf[to]++;
        }

        emit Transfer(address(0), to, id);
    }

    // Mint
    function cutCanvas() internal {
        uint id = ++totalSupply;
        require(id < MAX_SUPPLY, "OUT_OF_STOCK");
        address newCanvas = address(new Canvas(msg.sender, id));
        canvases[id] = newCanvas;
        _mint(msg.sender, id);
    }

    // Helpers
    function isContract(address addr) internal view returns (bool) {
        uint size;
        assembly {
            size := extcodesize(addr)
        }
        return size > 0;
    }

    function isAuthorized(
        address _operator,
        uint256 _tokenId
    ) internal view returns (bool) {
        address _owner = _ownerOf[_tokenId];
        return (_owner == _operator ||
            isApprovedForAll[_owner][_operator] == true ||
            getApproved[_tokenId] == _operator);
    }

    function fromCanvas(uint256 _tokenId) internal view returns (bool) {
        return (msg.sender == canvases[_tokenId]);
    }
}

abstract contract ERC721TokenReceiver {
    function onERC721Received(
        address,
        address,
        uint256,
        bytes calldata
    ) external virtual returns (bytes4) {
        return ERC721TokenReceiver.onERC721Received.selector;
    }
}
