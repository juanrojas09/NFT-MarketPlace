// SPDX-License-Identifier: MIT OR Apache-2.0
pragma solidity ^0.8.3;


import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "hardhat/console.sol";

/**
Este es un contrato inteligente NFT 
bastante sencillo que permite 
a los usuarios crear activos 
digitales únicos y ser dueños de ellos.

 */
contract NFT is ERC721URIStorage {
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;
    address contractAdress;

    constructor(address marketplaceAddress) ERC721("Metaverse Tokens","METT"){
        contractAdress=marketplaceAddress;
    }
   function createToken(string memory tokenURI) public returns (uint){  
       _tokenIds.increment();
       uint256 newItemId=_tokenIds.current(); //el item del token arranca en 1

       _mint(msg.sender,newItemId); //permite mintear pasandole el msg y el id del item
       _setTokenURI(newItemId,tokenURI);// viene del erc721storage. le paso el item id q es como el token uri y el tokenuri
       setApprovalForAll(contractAdress,true);//la aprobacion de todos, le da al marketplace la aprobacion de la transaccion
       return  newItemId;
       }


}