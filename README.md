# CryptoColors
## own Colors, Mix Colors to get new colors




Inspired from cryptoKitties, Cryptocolors is an attempt to implement NFTs on ERC1155 standard. 
The main idea is that players can own Colors and mix them to get new NFT colors.
The color image is hosted on IPFS.

## Structure Of the Code
The whole code is broken down into contracts according to the functionality.

- [Cryptocolors] is our main contract which inherits all the functionalities
- [paletteBase] is the base contract which defines the necessary variables and data storage
- [paletteOwnership] is the contract implementing ERC1155 standard which holds the ownership details of colorsNFT. This can also hold ERC20 tokens which can be introduced in further versions.
- [colorMixing] is the contract which enables players to mix colors and get new NFTs


## IPFS image collection
> colors from #000 to #9ff can be accessed with the CID of QmZNFPrHQwZ6sj6biCuuJCREJXvraL8LQqs2SmWNwvCsGV/{colorId}
> colors from #9ff to #fff can be accessed with the CID of QmQPSkBDsgW83WEtG5w2HgipKPDQUQQu9tpvDyN5nVAPw8/{colorId}

ex: ipfs://QmQPSkBDsgW83WEtG5w2HgipKPDQUQQu9tpvDyN5nVAPw8/d46.png


## ToDo

- dev a marketplace where players can sell and buy Cryptocolors

