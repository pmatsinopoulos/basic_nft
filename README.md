# Deploy BasicNFT in ANVIL

```bash
forge script script/DeployBasicNft.s.sol --broadcast \
  --rpc-url http://127.0.0.1:8545 \
  --account ANVIL_PRIVATE_KEY_FIRST_ACCOUNT
```

# Mint NFT in ANVIL

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

# Deploy (and Verify) BasicNFT to Base Sepolia

``bash
forge script script/DeployBasicNft.s.sol --broadcast \
  --rpc-url ${ALCHEMY_RPC_URL_FOR_BASE_SEPOLIA} \
  --account myaccount \
  --verify \
  --resume \
  --verifier blockscout \
  --verifier-url https://base-sepolia.blockscout.com/api/
```
