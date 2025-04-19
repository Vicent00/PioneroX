<h1 align="center" style="text-align: center;">🚀 PioneroX - Tiered NFT Presale System</h1>

<div align="center">
  <img src="https://img.shields.io/badge/Solidity-0.8.26-blue?style=for-the-badge&logo=solidity&logoColor=white" alt="Solidity">
  <img src="https://img.shields.io/badge/Foundry-FFDB1C?style=for-the-badge&logo=ethereum&logoColor=black" alt="Foundry">
  <img src="https://img.shields.io/badge/Arbitrum-28A0F0?style=for-the-badge&logo=arbitrum&logoColor=white" alt="Arbitrum">
  <img src="https://img.shields.io/badge/License-MIT-yellow?style=for-the-badge" alt="License">
</div>

<br>


<div align="center">
  <img src="snapshots\structure.png" alt="Project Structure" width="600">
  <p><em>🎨 Visual representation of the project's structure and components</em></p>
</div>

## 📋 Overview

PioneroX is a sophisticated tiered NFT presale system built on the Arbitrum network. It implements a unique mechanism where users can purchase NFTs of different tiers (BRONZE, SILVER, GOLD) and later redeem them for PioneroX tokens with tier-specific discounts.

## 🔄 Protocol Flow Diagrams

### 1. 🏗️ Initial Setup Flow
```mermaid
sequenceDiagram
    participant 👤 Owner
    participant 📜 Contract
    participant 💰 Token
    
    👤 Owner->>📜 Contract: Deploy TieredPresale
    👤 Owner->>💰 Token: Deploy PioneroXToken
    👤 Owner->>📜 Contract: Set Token Contract Address
    👤 Owner->>📜 Contract: Configure Tiers (BRONZE, SILVER, GOLD)
    👤 Owner->>📜 Contract: Set Base URIs for each tier
    👤 Owner->>📜 Contract: Deposit Tokens for Presale
```

### 2. 🎨 NFT Minting Flow
```mermaid
sequenceDiagram
    participant 👤 User
    participant 📜 Contract
    participant 🖼️ NFT
    
    👤 User->>📜 Contract: Check Tier Availability
    📜 Contract->>📜 Contract: Validate Minting Period
    📜 Contract->>📜 Contract: Check Supply Limits
    👤 User->>📜 Contract: Send ETH Payment
    📜 Contract->>📜 Contract: Validate Payment
    📜 Contract->>🖼️ NFT: Mint NFT
    📜 Contract->>👤 User: Transfer NFT
    📜 Contract->>📜 Contract: Update Supply Count
```

### 3. 💰 Token Redemption Flow
```mermaid
sequenceDiagram
    participant 👤 User
    participant 📜 Contract
    participant 💰 Token
    
    👤 User->>📜 Contract: Check Token Sale Status
    📜 Contract->>📜 Contract: Validate Sale Period
    👤 User->>📜 Contract: Redeem NFT
    📜 Contract->>📜 Contract: Calculate Discount
    👤 User->>📜 Contract: Send ETH Payment
    📜 Contract->>📜 Contract: Validate Payment
    📜 Contract->>💰 Token: Transfer Tokens
    📜 Contract->>👤 User: Send Tokens
    📜 Contract->>📜 Contract: Burn NFT
```

### 4. 👑 Owner Management Flow
```mermaid
sequenceDiagram
    participant 👤 Owner
    participant 📜 Contract
    participant 💰 Token
    
    👤 Owner->>📜 Contract: Start Token Sale
    👤 Owner->>📜 Contract: Configure Sale Parameters
    👤 Owner->>📜 Contract: Monitor Sales
    👤 Owner->>📜 Contract: Withdraw ETH
    👤 Owner->>💰 Token: Manage Token Supply
    👤 Owner->>📜 Contract: Emergency Withdraw
```

### 5. 🔄 Complete Protocol Flow
```mermaid
graph TD
    A[🚀 Start] --> B[🏗️ Deploy Contracts]
    B --> C[⚙️ Configure Tiers]
    C --> D[💰 Deposit Tokens]
    D --> E[🎨 Start NFT Sale]
    E --> F{👤 User Actions}
    F -->|Mint NFT| G[💸 Send ETH]
    F -->|Redeem NFT| H[💸 Send ETH]
    G --> I[🖼️ Receive NFT]
    H --> J[💰 Receive Tokens]
    I --> K[🏁 End]
    J --> K
    E --> L[👑 Owner Actions]
    L --> M[📊 Monitor Sales]
    M --> N[💸 Withdraw Funds]
    N --> K
```

## ✨ Features

- 🎨 **Tiered NFT System**: Three distinct tiers (BRONZE, SILVER, GOLD) with different benefits
- 💰 **Token Redemption**: Convert NFTs into PioneroX tokens with tier-based discounts
- 🔒 **Secure Smart Contracts**: Built with security best practices and reentrancy protection
- ⚙️ **Flexible Configuration**: Adjustable parameters for each tier and token sale
- 📝 **Metadata Support**: IPFS-based metadata for NFTs
- 👑 **Owner Controls**: Comprehensive management functions for contract owners

## 📜 Smart Contracts

### 💰 PioneroXToken (ERC20)
The PioneroX token is an ERC20 token with the following features:
- 🔥 Burnable functionality
- 👑 Owner-controlled minting
- 🔒 Reentrancy protection
- 📜 Standard ERC20 compliance

### 🎨 TieredPresale
The presale contract implements:
- 🎨 Tiered NFT minting system
- 💰 Token redemption mechanism
- ⚙️ Configurable tier parameters
- 🔒 Secure payment handling
- 🚨 Emergency withdrawal functions

## 📊 Technical Specifications

### 🎨 NFT Tiers

| Tier    | Benefits                    | Discount % | Emoji |
|---------|-----------------------------|------------|-------|
| 🥉 BRONZE  | Basic tier access           | 10%        | 🥉    |
| 🥈 SILVER  | Enhanced benefits           | 25%        | 🥈    |
| 🥇 GOLD    | Premium tier with max perks | 50%        | 🥇    |

### ⚙️ Contract Details

- 🔧 **Solidity Version**: 0.8.26
- 🌐 **Network**: Arbitrum Mainnet
- 🛠️ **Framework**: Foundry
- 📦 **OpenZeppelin**: Latest version

## 🚀 Installation

1. Clone the repository:
```bash
git clone https://github.com/your-username/pionerox.git
cd pionerox
```

2. Install dependencies:
```bash
forge install
```

3. Compile contracts:
```bash
forge build
```

## 🏗️ Deployment

1. Set up your environment variables in `.env`:
```bash
PRIVATE_KEY=your_private_key
ETHERSCAN_API_KEY=your_etherscan_api_key
ARBITRUM_RPC_URL=your_arbitrum_rpc_url
```

2. Deploy to Arbitrum Mainnet:
```bash
forge script script/Deploy.s.sol:DeployScript --rpc-url $ARBITRUM_RPC_URL --broadcast --verify -vvvv
```

## 📝 Usage

### 👤 For Users

1. **🎨 Mint NFT**
   - Choose your desired tier
   - Send the required ETH amount
   - Receive your NFT

2. **💰 Redeem for Tokens**
   - Wait for token sale to start
   - Redeem your NFT for PioneroX tokens
   - Enjoy tier-specific discounts

### 👑 For Contract Owner

1. **⚙️ Configure Tiers**
   ```solidity
   configureTier(
       Tier tier,
       uint256 price,
       uint256 maxSupply,
       uint256 discountPercentage,
       uint256 mintStartTime,
       uint256 mintEndTime
   )
   ```

2. **🚀 Start Token Sale**
   ```solidity
   startTokenSale(
       uint256 _tokenPrice,
       uint256 _saleDuration,
       uint256 _claimDeadline
   )
   ```

3. **💼 Manage Tokens**
   - Deposit tokens into the contract
   - Withdraw collected ETH
   - Emergency withdrawal if needed

## 🔒 Security Features

- 🔒 Reentrancy protection on all critical functions
- 👑 Owner-only administrative functions
- 🚨 Emergency withdrawal capabilities
- ✅ Input validation and requirements
- 💰 Safe token transfers using SafeERC20


## 🤝 Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 📞 Contact

- 🌐 Website: [vicenteaguilar.com](https://vicenteaguilar.com)
- 💬 Linkedin: [Visit my Profile](www.linkedin.com/in/vicente-aguilar00)

## 🙏 Acknowledgments

- 📦 OpenZeppelin for their secure smart contract libraries
- 🌐 Arbitrum for their Layer 2 scaling solution
- 🛠️ The Foundry team for their development framework
