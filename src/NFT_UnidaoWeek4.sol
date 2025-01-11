// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "lib/openzeppelin-contracts/contracts/access/Ownable.sol";
import "lib/openzeppelin-contracts/contracts/token/ERC721/ERC721.sol";

contract NFT is ERC721, Ownable {
    using Strings for uint256;

    uint256 public constant MAX_TOKENS = 3000;
    uint256 public price = 0.001 ether;

    uint256 public totalSupply;
    mapping(address => uint256) private mintedPerWallet;

    string public baseUri;
    string public baseExtension = ".json";

    //Bhai Akshat, Harrish ya jo koi aur dekh rha hai, I spent quite a long time on it, searching
    //for a way to make the owner add any image as an NFT here directly but I couldn't do it as I was using IPFS.
    //so otherthan that functionality, everything else works fine, only thing is I have got 10 images toh zyada mint mat krna abhi XD.

    constructor(string memory _name, string memory _symbol) ERC721(_name, _symbol) Ownable(msg.sender) {
        baseUri = "ipfs://bafybeibdmr5jxhuzmdrm2u42fungj427pjvs7ce5ffbdpzm2xyvvg7sofi/";
    }

    function mint(uint256 _numTokens) external payable {
        uint256 curTotalSupply = totalSupply;
        require(curTotalSupply + _numTokens <= MAX_TOKENS, "Exceeds total supply.");
        require(_numTokens * price <= msg.value, "Insufficient funds.");

        for (uint256 i = 1; i <= _numTokens; ++i) {
            _safeMint(msg.sender, curTotalSupply + i);
        }
        mintedPerWallet[msg.sender] += _numTokens;
        totalSupply += _numTokens;
    }

    function setPrice(uint256 _price) external onlyOwner {
        price = _price;
    }

    function withdrawAll() external payable onlyOwner {
        uint256 balance = address(this).balance;
        (bool transfer, ) = payable(msg.sender).call{value: balance}("");
        require(transfer, "Transfer failed.");
    }

    function tokenURI(uint256 tokenId) public view virtual override returns (string memory) {
        require(_ownerOf(tokenId) != address(0), "ERC721Metadata: URI query for nonexistent token");

        string memory currentBaseURI = _baseURI();
        return bytes(currentBaseURI).length > 0
            ? string(abi.encodePacked(currentBaseURI, tokenId.toString(), baseExtension))
            : "";
    }
}
