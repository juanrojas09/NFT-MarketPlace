// contracts/Market.sol
// SPDX-License-Identifier: MIT OR Apache-2.0
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

import "hardhat/console.sol";

contract NFTMarket is ReentrancyGuard {
    using Counters for Counters.Counter;
    Counters.Counter private _itemIds;
    Counters.Counter private _itemsSold;

    address payable owner; //ver quien es el dueño, porque va a generar una comision en cada item vendido
    uint256 listingPrice = 0.025 ether; //fee para cuando listan

    /**
 Solidity proporciona una declaración de 
 constructor dentro del contrato inteligente y
 se invoca solo una vez cuando se implementa 
 el contrato y se usa para inicializar el 
 estado del contrato. El compilador crea 
 un constructor predeterminado si 
 no hay un constructor definido explícitamente. */
    constructor() {
        owner = payable(msg.sender);
    }

    struct MarketItem {
        uint256 itemId;
        address nftContract;
        uint256 tokenId;
        address payable seller;
        address payable owner;
        uint256 price;
        bool sold;
    }

    mapping(uint256 => MarketItem) private idToMarketItem;
    //el evento emitido
    event MarketItemCreated(
        uint256 indexed itemId,
        address indexed nftContract,
        uint256 indexed tokenId,
        address seller,
        address owner,
        uint256 price,
        bool sold
    );

    //traigo la lista de precio de el contrato
    function getListingPrice() public view returns (uint256) {
        return listingPrice;
    }

    /* Places an item for sale on the marketplace */
    function createMarketItem(
        address nftContract,
        uint256 tokenId,
        uint256 price
    )
        public
        payable
    //el nonreentrant, previene los re-entry attacks nonReentrant
    {
        require(price > 0, "El precio tiene que ser como minimo 1");
        require(
            msg.value == listingPrice,
            "el precio debe ser igual al precio de lista"
        );

        _itemIds.increment();
        uint256 itemId = _itemIds.current();

        /**
  id a market item del mapping, le paso un arreglo con itemid
  los parametros del market item vienen de argumentos 
  sender es la perona que vende
  el dueño se le setea un address vacio, no tiene dueño
   el precio y el booleano de si esta vendido o no
     */
        idToMarketItem[itemId] = MarketItem(
            itemId,
            nftContract,
            tokenId,
            payable(msg.sender),
            payable(address(0)),
            price,
            false
        );

        //se transfiere el item de el dueño anterior al actual.
        //se usa el irc721 de pasandole el contrato nft transfiriendolo
        //desde el dueño al comprador y le paso el token id
        IERC721(nftContract).transferFrom(msg.sender, address(this), tokenId);

        //emito el evento, emitiendo que se creo el market item.
        emit MarketItemCreated(
            itemId,
            nftContract,
            tokenId,
            msg.sender,
            address(0),
            price,
            false
        );
    }

    /* Creates the sale of a marketplace item */
    /* Transfers ownership of the item, as well as funds between parties */
    function createMarketSale(address nftContract, uint256 itemId)
        public
        payable
        nonReentrant
    {
        uint256 price = idToMarketItem[itemId].price;
        uint256 tokenId = idToMarketItem[itemId].tokenId;
        require(
            msg.value == price,
            "envie el precio solicitado para completar la compra"
        );

        //siempre utiñizando el mapping
        idToMarketItem[itemId].seller.transfer(msg.value); //se transfiere el precio solicitado
        IERC721(nftContract).transferFrom(address(this), msg.sender, tokenId); //transfiere el item desde el dueño al msg sender
        idToMarketItem[itemId].owner = payable(msg.sender);
        idToMarketItem[itemId].sold = true;
        _itemsSold.increment();
        payable(owner).transfer(listingPrice); //se le paga al dueño
    }

    function fetchMarketItems() public view returns (MarketItem[] memory) {
        ///* Returns all unsold market items *
        uint256 itemCount = _itemIds.current();
        uint256 unsoldItemCount = _itemIds.current() - _itemsSold.current();
        uint256 currentIndex = 0;

        MarketItem[] memory items = new MarketItem[](unsoldItemCount); //el parentesis es el largo del arreglo
        for (uint256 i = 0; i < itemCount; i++) {
            //loopeo el numero de items creados
            if (idToMarketItem[i + 1].owner == address(0)) {
                // si tiene un address nulo, incrementa el contador, porque significa que no se vendio, me fijo
                //el idtomarket item map apuntado al owner y leo el address
                uint256 currentId = i + 1; //defino una variable q la voy aumentando por vuelta que se cumple la condicion
                MarketItem storage currentItem = idToMarketItem[currentId]; //hago una referencia a marketitem[] donde defino en el mapping del idto.. y le paso
                //al array el valor del current id que sacamos del recorrido
                items[currentIndex] = currentItem; //inserto los items en el arreglo
                currentIndex++;
            }
        }
        return items;
    }

    function fetchMyNft() public view returns (MarketItem[] memory) {
        uint256 totalItemCount = _itemIds.current();
        uint256 itemCount = 0;
        uint256 currentIndex = 0;

        for (uint256 i = 0; i < totalItemCount; i++) {
            //recorro el array de items y veo el numero que se vendio
            if (idToMarketItem[i + 1].owner == msg.sender) {
                itemCount++;
            }
        }
        MarketItem[] memory items = new MarketItem[](totalItemCount);
        for (uint256 i = 0; i < totalItemCount; i++) {
            if (idToMarketItem[i + 1].owner == msg.sender) {
                uint256 currentId = i + 1;
                MarketItem storage currentItem = idToMarketItem[currentId];
                items[currentIndex] = currentItem;
                currentIndex++;
            }
        }
        return items;
    }


 /* Returns only items a user has created */
 //verifica que yo sea la persona q creo el item y cuenta esos items
 function fetchItemsCreated() public view returns (MarketItem[] memory) {
    uint totalItemCount = _itemIds.current();
    uint itemCount = 0;
    uint currentIndex = 0;

    for (uint i = 0; i < totalItemCount; i++) {
      if (idToMarketItem[i + 1].seller == msg.sender) {
        itemCount += 1;
      }
    }

    MarketItem[] memory items = new MarketItem[](itemCount);
    for (uint i = 0; i < totalItemCount; i++) {
      if (idToMarketItem[i + 1].seller == msg.sender) {
        uint currentId = i + 1;
        MarketItem storage currentItem = idToMarketItem[currentId];
        items[currentIndex] = currentItem;
        currentIndex += 1;
      }
    }
    return items;
  }
 }
