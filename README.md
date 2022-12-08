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

![architecture](https://raw.githubusercontent.com/popular0/ETHDenver_ERC721Hub/main/architecture.png)
