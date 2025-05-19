# BasicNFT

## Deploy BasicNFT in ANVIL

```bash
forge script script/DeployBasicNft.s.sol --broadcast \
  --rpc-url http://127.0.0.1:8545 \
  --account ANVIL_PRIVATE_KEY_FIRST_ACCOUNT
```

## Mint NFT in ANVIL

```bash
forge script script/MintNft.s.sol \
  --sig "run(address,address,string,string,string)" \
  0x5FbDB2315678afecb367f032d93F642f64180aa3 \
  0x70997970C51812dc3A010C7d01b50e0d17dc79C8 \
  "Boobie" "My Fantastic Boobie" "https://ipfs.io/ipfs/sfadlfkj" \
  --broadcast \
  --rpc-url http://127.0.0.1:8545 \
  --account ANVIL_PRIVATE_KEY_FIRST_ACCOUNT
```

## Deploy (and Verify) BasicNFT to Base Sepolia

```bash
forge script script/DeployBasicNft.s.sol --broadcast \
  --rpc-url ${ALCHEMY_RPC_URL_FOR_BASE_SEPOLIA} \
  --account myaccount \
  --verify \
  --resume \
  --verifier blockscout \
  --verifier-url https://base-sepolia.blockscout.com/api/
```

# MoodNFT

## Deploy MoodNFT in Anvil

```bash
forge script script/DeployMoodNft.s.sol \
  --sig "run(string,string)" \
  './img/sad.svg' \
  './img/happy.svg' \
  --rpc-url http://127.0.0.1:8545 \
  --account ANVIL_PRIVATE_KEY_FIRST_ACCOUNT \
  --broadcast
```

## Mint MoodNFT in Anvil

This will mint the MoodNFT to the first ANVIL account.

```bash
forge script script/ManageMoodNft.s.sol \
  --sig "mint(address,address)" \
  0x5FbDB2315678afecb367f032d93F642f64180aa3 \
  0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266 \
  --rpc-url http://127.0.0.1:8545 \
  --broadcast \
  --account ANVIL_PRIVATE_KEY_FIRST_ACCOUNT
```

## Flip MoodNFT in Anvil

This will mint the MoodNFT to the first ANVIL account.

```bash
forge script script/ManageMoodNft.s.sol \
  --sig "flipMood(address,uint256)" \
  0x5FbDB2315678afecb367f032d93F642f64180aa3 \
  0 \
  --rpc-url http://127.0.0.1:8545 \
  --broadcast \
  --account ANVIL_PRIVATE_KEY_FIRST_ACCOUNT
```
