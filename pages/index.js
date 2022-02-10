
import styles from '../styles/Home.module.css';
import { ethers } from 'ethers';
import { useEffect, useState } from 'react';
import axios from 'axios';
import Web3Modal from "web3modal";

import{
  nftaddress,nftmarketaddress

}from '../config'

import NFT from '../artifacts/contracts/NFT.sol/NFT.json';
import Market from '../artifacts/contracts/NFTMarket.sol/NFTMarket.json';
import { ConstructorFragment } from 'ethers/lib/utils';

export default function Home() {
 
  const [nfts,setNfts]=useState([]);
  const [loadingState,setLoadingState]=useState('not-loaded');

  useEffect(()=>{ //para invocar metodos
     loadNFTs() 
  },[])

async function loadNFTs(){
 /* create a generic provider and query for unsold market items */
 const provider=new ethers.providers.JsonRpcProvider();
 /*new ethers.Contract( address , abi , signerOrProvider )*/
 //instancias a los contratos
 const tokenContract= new ethers.Contract(nftaddress,NFT.abi,provider);
 const marketContract=new ethers.Contract(nftmarketaddress,Market.abi,provider);
const data=await marketContract.fetchMarketItems();
console.log(tokenContract,"contrato")
/*mapeo de los items que se retornan desde el smart contract y obtener los metadatos del token
*/
const items=await Promise.all(data.map(async i=>{
const tokenUri=await tokenContract.tokenURI(i.tokenId); //llamo al contrato del tokeny traigo el uri
const meta=await axios.get(tokenUri); //https://ipfs.org/nft/api/v1...
let price=ethers.utils.formatUnits(i.price.toString(),'ether'); //value call price y lo agrego al objeto
let item={
  price,
  tokenId: i.tokenId.toNumber(),
  seller: i.seller,
  owner: i.owner,
  image: meta.data.image,
  name: meta.data.name,
  description: meta.data.description,

}
console.log("items",item);
console.log("nft contract",tokenContract)
console.log("marketcontract",marketContract)
return item;



}))
setNfts(items);
setLoadingState('loaded');
}

async function buyNft(nft){
  /* needs the user to sign the transaction, so will use Web3Provider and sign it */
const web3modal=new Web3Modal();
const connection=await web3modal.connect({network: "mainnet",
cacheProvider: true,});
const provider=new ethers.providers.Web3Provider(connection);
const signer=provider.getSigner();
const contract=new ethers.Contract(nftmarketaddress,Market.abi,signer);

/* user will be prompted to pay the asking proces to complete the transaction */
const price = ethers.utils.parseUnits(nft.price.toString(), 'ether')   
const transaction = await contract.createMarketSale(nftaddress, nft.tokenId, { //referencia al contrato
  value: price

})
await transaction.wait();//espero a la transaccion que se ejecuto, esperar que se termine y luego hacer algo
loadNFTs()//llamo al metodo load nfts, reload de la pantalla porque se va a eliminar un nft de la view
}
if(loadingState=='loaded' && !nfts.length) return(<h1 className="px-20 py-300  text-3x2 p-12 t-9">No items in marketplace</h1>) //si eñ estado de la carga es en cargado y en el arreglo no hay nft, entonces larga ese mensaje
  return (
    
    <div className={styles.container}>
    

<div className="flex justify-center p-10">
      <div className="px-4" style={{ maxWidth: '1600px' }}>
        <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-4 pt-4">
          {
            nfts.map((nft, i) => (
              <div key={i} className="border shadow rounded-xl overflow-hidden">
                <img src={nft.image} />
                <div className="p-4">
                  <p style={{ height: '64px' }} className="text-2xl font-semibold">{nft.name}</p>
                  <div style={{ height: '70px', overflow: 'hidden' }}>
                    <p className="text-gray-400">{nft.description}</p>
                  </div>
                </div>
                <div className="p-4 bg-black">
                  <p className="text-2xl mb-4 font-bold text-white">{nft.price} ETH</p>
                  <button className="w-full bg-pink-500 text-white font-bold py-2 px-12 rounded" onClick={() => buyNft(nft)}>Buy</button>
                </div>
              </div>
            ))
          }
        </div>
      </div>
    </div>


    </div>
  )
  
}
