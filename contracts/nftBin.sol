// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/utils/ERC721Holder.sol";

contract nftBin is ERC721Enumerable, ERC721Holder, Ownable {
    struct NFT {
        address nftContract;
        uint256 tokenId;
    }

    uint256 public immutable MAX_WEB3PASS;
    uint256 public tokenCounter;

    mapping(address => bool) public minted;
    mapping(address => uint256) public nftCount;
    mapping(address => NFT[]) public nftbin;

    uint256 public maxTransferred;
    address public maxAddress;

    bool public activated;

    // constructor() ERC721("WEB3 Pass", "WEB3") {
    constructor() ERC721("sexking", "SEX") {
        MAX_WEB3PASS = 3000;
        tokenCounter = 0;
        maxTransferred = 0;
        activated = true;
    }

    function depositNFTAndGetWEB3Pass(address contractaddr, uint256 tokenId)
        external
    {
        require(activated, "Sorry gate closed");
        ERC721(contractaddr).safeTransferFrom(
            msg.sender,
            address(this),
            tokenId
        );
        nftCount[msg.sender]++;
        nftbin[msg.sender].push(NFT(contractaddr, tokenId));
        if (nftCount[msg.sender] > maxTransferred) {
            maxTransferred = nftCount[msg.sender];
            maxAddress = msg.sender;
        }
        if (!minted[msg.sender] && tokenCounter < MAX_WEB3PASS) {
            _safeMint(msg.sender, tokenCounter++);
            minted[msg.sender] = true;
        }
    }

    function flipStatus() public onlyOwner {
        activated = !activated;
    }

    function withdrawNFT(
        address contractaddr,
        uint256 tokenId,
        address to
    ) external onlyOwner {
        ERC721(contractaddr).safeTransferFrom(address(this), to, tokenId);
    }

    function tokenURI(uint256 _tokenId)
        public
        view
        override
        returns (string memory)
    {
        return
            "https://ipfs.io/ipfs/QmXUpzRRv9DDvKDjAK5hdZ2x3iciwC5eBxqC6NP5n8oC6x?filename=tokenURI.json";
    }
}
