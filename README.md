# ERC721 Hub + Spoke

ERC721Hub deploys a new Spoke contract for each token minted

Each Spoke is both an individual NFT and a standalone smart contract, enabling some additional capabilities

We can implement arbitrary logic in each spoke contract, while still maintaining all of the benefits of existing ERC721 infrastructure (marketplaces, vaults, etc.)
