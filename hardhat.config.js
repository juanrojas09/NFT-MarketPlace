require("@nomiclabs/hardhat-waffle");

const fs=require("fs");
const privateKey=fs.readFileSync(".secret").toString().trim() ||"aeabf5068275f712bc6bd2b1ebf572af68888cb4f77fd6e699a40a3f5541bc8f" //recupero desde el secret la clave
const projectId="4a4ddae0552f45318c2d4a38492d649f";

/**
 * @type import('hardhat/config').HardhatUserConfig
 */
module.exports = {
  networks:{
hardhat:{
  chainId:1337,
  gas: 2100000,
  gasPrice: 8000000000,
},
mumbai:{
  url:`https://polygon-mumbai.infura.io/v3/${projectId}`,
  accounts:[]
},
mainnet:{
  url:`https://polygon-mainnet.infura.io/v3/4a4ddae0552f45318c2d4a38492d649f`,
   accounts:[]
},
  },
  solidity: "0.8.4",
};
