# ETHDenver x Encode Bootcamp Team 4 Final Project

## ERC721 Hub + Spoke

ERC721Hub deploys a new Spoke contract for each token minted

Each Spoke is both an individual NFT and a standalone smart contract, enabling some additional capabilities

We can implement arbitrary logic in each spoke contract, while still maintaining all of the benefits of existing ERC721 infrastructure (marketplaces, vaults, etc.)

### Why did we make this?

1. Simply cooler to own a full contract rather than just: ownerOf(tokenId) = <your_address>
2. Provides flexibility and extensibility to NFTs to enable more powerful use cases
3. Enables buying / selling of whole contracts on existing marketplaces
4. Consider what was unlocked in defi by treating LP positions as tradable/stakeable ERC721s - extend that to arbitrary logic versus just an LP position
5. Further benefits to be determined!

### Team Implementations

1. Canvas - Each token contract contains an array of uint8s that can be used to store arbitrary pixels on-chain
   - One RGBA pixel = [uint8 R, uint8 G, uint8 B, uint8 Alpha]
   - Comes with a default renderer with on-chain generative SVG art
   - [OpenSea testnet link](https://testnets.opensea.io/collection/canvashub-v3)
2. ETFERC20 - Each token contract is a standalone ERC20 that issues shares equal to the derived NAV
   - These ETF contracts can then be bought and sold on marketplaces
   - Many different types of ETFERC20 Spokes can be minted, tracking different asset classes
   - [OpenSea testnet link](https://testnets.opensea.io/assets/goerli/0x67df00d251b71a15776770ba5affb9ea6b5b3551/1)

![architecture](https://raw.githubusercontent.com/popular0/ETHDenver_ERC721Hub/main/architecture.png)
