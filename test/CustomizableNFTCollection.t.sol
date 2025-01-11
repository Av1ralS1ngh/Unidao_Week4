// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "../src/CustomizableNFTCollection.sol";

contract CustomizableNFTCollectionTest is Test {
    CustomizableNFTCollection public nft;
    address public owner;
    address public user;
    
    function setUp() public {
        owner = address(this);
        user = address(0x1);
        nft = new CustomizableNFTCollection();
        vm.deal(user, 100 ether);
    }
    
    function testMint() public {
        string memory tokenURI = "ipfs://QmExample";
        
        vm.prank(user);
        uint256 tokenId = nft.mint{value: 0.05 ether}(tokenURI);
        
        assertEq(nft.ownerOf(tokenId), user);
        assertEq(nft.tokenURI(tokenId), tokenURI);
        assertEq(nft.currentTokenId(), 1);
    }
    
    function testFailMintWithInsufficientPayment() public {
        vm.prank(user);
        nft.mint{value: 0.04 ether}("ipfs://QmExample");
    }
    
    function testUpdateTokenURI() public {
        string memory initialURI = "ipfs://QmInitial";
        string memory newURI = "ipfs://QmUpdated";
        
        vm.prank(user);
        uint256 tokenId = nft.mint{value: 0.05 ether}(initialURI);
        
        vm.prank(user);
        nft.updateTokenURI(tokenId, newURI);
        
        assertEq(nft.tokenURI(tokenId), newURI);
    }
    
    function testFailUpdateTokenURINotOwner() public {
        vm.prank(user);
        uint256 tokenId = nft.mint{value: 0.05 ether}("ipfs://QmExample");
        
        address notOwner = address(0x2);
        vm.prank(notOwner);
        nft.updateTokenURI(tokenId, "ipfs://QmNew");
    }
    
    function testMaxSupply() public {
        string memory tokenURI = "ipfs://QmExample";
        
        for(uint i = 0; i < 3000; i++) {
            vm.prank(user);
            nft.mint{value: 0.05 ether}(tokenURI);
        }
        
        vm.expectRevert("Max supply reached");
        vm.prank(user);
        nft.mint{value: 0.05 ether}(tokenURI);
    }
}