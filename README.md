# Deploy BasicNFT

```bash
forge script script/DeployBasicNft.s.sol --broadcast \
  --rpc-url http://127.0.0.1:8545 \
  --account ANVIL_PRIVATE_KEY_FIRST_ACCOUNT
```

# Mint NFT

```bash
forge script script/MintNft.s.sol \
  --sig "run(address,address,string,string,string)" \
  0x5FbDB2315678afecb367f032d93F642f64180aa3 \
  0x70997970C51812dc3A010C7d01b50e0d17dc79C8 \
  "Boobie" "My Fantastic Boobie" "https://ipfs.io/ipfs/sfadlfkj" \
  --broadcast \
  --rpc-url https://127.0.0.1:8545 \
  --account ANVIL_PRIVATE_KEY_FIRST_ACCOUNT
```
