// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

import "../lib/openzeppelin-contracts/contracts/token/ERC721/ERC721.sol";
import "../lib/openzeppelin-contracts/contracts/utils/ReentrancyGuard.sol";
import "../lib/openzeppelin-contracts/contracts/access/Ownable.sol";
import "../lib/openzeppelin-contracts/contracts/utils/Strings.sol";
import "../lib/openzeppelin-contracts/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "../lib/openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";
import "../lib/openzeppelin-contracts/contracts/token/ERC20/utils/SafeERC20.sol";

/**
 * @title TieredPresale
 * @dev Implementation of a tiered NFT presale system with token redemption functionality.
 * This contract allows users to purchase NFTs of different tiers (BRONZE, SILVER, GOLD)
 * and later redeem them for tokens with tier-specific discounts.
 */
contract TieredPresale is ERC721Enumerable, Ownable, ReentrancyGuard {
    using Strings for uint256;
    using SafeERC20 for IERC20;

    /**
     * @dev Enum representing the different tiers of NFTs
     */
    enum Tier {
        BRONZE,
        SILVER,
        GOLD
    }

    /**
     * @dev Struct containing configuration for each tier
     */
    struct TierConfig {
        uint256 price;              // Price in ETH to mint an NFT of this tier
        uint256 maxSupply;          // Maximum number of NFTs that can be minted in this tier
        uint256 discountPercentage; // Discount percentage for token purchases
        uint256 mintStartTime;      // Start time for minting NFTs of this tier
        uint256 mintEndTime;        // End time for minting NFTs of this tier
        uint256 currentSupply;      // Current number of NFTs minted in this tier
    }

    // Mapping from tier to its configuration
    mapping(Tier => TierConfig) public tierConfigs;
    
    // Mapping from tokenId to tier
    mapping(uint256 => Tier) public tokenTiers;
    
    // Mapping from user address to whether they have minted
    mapping(address => bool) public hasMinted;
    
    // Mapping from tokenId to whether it has been redeemed
    mapping(uint256 => bool) public isRedeemed;
    
    // Token sale configuration
    uint256 public tokenSaleStartTime;
    uint256 public tokenSaleEndTime;
    uint256 public tokenPrice; // Price in ETH per token
    uint256 public claimDeadline;
    
    // Token contract
    IERC20 public tokenContract;
    
    // Token counter for NFT IDs
    uint256 private _tokenIdCounter;
    
    // Base URIs for each tier
    mapping(Tier => string) private _tierBaseURIs;
    
    // Events
    event NFTPurchased(address indexed buyer, uint256 indexed tokenId, Tier tier);
    event NFTRedeemed(address indexed owner, uint256 indexed tokenId, Tier tier, uint256 amount);
    event TokenSaleStarted(uint256 startTime, uint256 endTime);
    event TokenSaleEnded(uint256 endTime);
    event TokenSaleCancelled();
    event EmergencyWithdraw(address indexed owner, uint256 amount);
    event TokensDeposited(uint256 amount);
    
    /**
     * @dev Constructor that initializes the presale contract
     * @param name The name of the NFT
     * @param symbol The symbol of the NFT
     * @param baseTokenURI The base URI for NFT metadata
     * @param _tokenContract The address of the ERC20 token contract
     */
    constructor(
        string memory name,
        string memory symbol,
        string memory baseTokenURI,
        address _tokenContract
    ) ERC721(name, symbol) Ownable(msg.sender) {
        _tokenIdCounter = 1;
        _tierBaseURIs[Tier.BRONZE] = baseTokenURI;
        tokenContract = IERC20(_tokenContract);
    }
    
    /**
     * @dev Sets the base URI for a specific tier
     * @param tier The tier to set the URI for
     * @param baseURI The new base URI
     * Requirements:
     * - Only the owner can call this function
     * - The base URI must not be empty
     */
    function setTierBaseURI(Tier tier, string memory baseURI) external onlyOwner {
        require(bytes(baseURI).length > 0, "Invalid base URI");
        _tierBaseURIs[tier] = baseURI;
    }
    
    /**
     * @dev Returns the token URI for a given token ID
     * @param tokenId The ID of the token
     * @return The token URI
     * Requirements:
     * - The token must exist
     */
    function tokenURI(uint256 tokenId) public view override returns (string memory) {
        require(ownerOf(tokenId) != address(0), "ERC721Metadata: URI query for nonexistent token");
        
        Tier tier = tokenTiers[tokenId];
        string memory tierBaseURI = _tierBaseURIs[tier];
        
        return bytes(tierBaseURI).length > 0 
            ? string(abi.encodePacked(tierBaseURI, tokenId.toString(), ".json"))
            : "";
    }
    
    /**
     * @dev Configures a tier with its parameters
     * @param tier The tier to configure
     * @param price The price in ETH to mint an NFT of this tier
     * @param maxSupply The maximum number of NFTs that can be minted in this tier
     * @param discountPercentage The discount percentage for token purchases
     * @param mintStartTime The start time for minting NFTs of this tier
     * @param mintEndTime The end time for minting NFTs of this tier
     * Requirements:
     * - Only the owner can call this function
     * - The end time must be after the start time
     * - The discount percentage must be less than or equal to 100
     */
    function configureTier(
        Tier tier,
        uint256 price,
        uint256 maxSupply,
        uint256 discountPercentage,
        uint256 mintStartTime,
        uint256 mintEndTime
    ) external onlyOwner {
        require(mintEndTime > mintStartTime, "Invalid time window");
        require(discountPercentage <= 100, "Invalid discount percentage");
        
        tierConfigs[tier] = TierConfig({
            price: price,
            maxSupply: maxSupply,
            discountPercentage: discountPercentage,
            mintStartTime: mintStartTime,
            mintEndTime: mintEndTime,
            currentSupply: 0
        });
    }
    
    /**
     * @dev Starts the token sale
     * @param _tokenPrice The price in ETH per token
     * @param _saleDuration The duration of the sale in seconds
     * @param _claimDeadline The deadline for claiming tokens in seconds
     * Requirements:
     * - Only the owner can call this function
     * - The sale must not be already active
     * - The duration and deadline must be valid
     */
    function startTokenSale(
        uint256 _tokenPrice,
        uint256 _saleDuration,
        uint256 _claimDeadline
    ) external onlyOwner {
        require(tokenSaleStartTime == 0 || block.timestamp > tokenSaleEndTime, "Token sale already active");
        require(_saleDuration > 0, "Invalid sale duration");
        require(_claimDeadline > _saleDuration, "Invalid claim deadline");
        require(_tokenPrice > 0, "Token price must be greater than 0");
        
        tokenPrice = _tokenPrice;
        tokenSaleStartTime = block.timestamp;
        tokenSaleEndTime = block.timestamp + _saleDuration;
        claimDeadline = block.timestamp + _claimDeadline;
        
        emit TokenSaleStarted(tokenSaleStartTime, tokenSaleEndTime);
    }
    
    /**
     * @dev Mints an NFT of a specific tier
     * @param tier The tier of NFT to mint
     * Requirements:
     * - The sender must not have already minted an NFT
     * - The minting period must be active
     * - The tier must not have reached its maximum supply
     * - The sender must send enough ETH
     */
    function mintNFT(Tier tier) external payable nonReentrant {
        require(!hasMinted[msg.sender], "Already minted");
        require(block.timestamp >= tierConfigs[tier].mintStartTime, "Mint not started");
        require(block.timestamp <= tierConfigs[tier].mintEndTime, "Mint ended");
        require(tierConfigs[tier].currentSupply < tierConfigs[tier].maxSupply, "Max supply reached");
        require(msg.value >= tierConfigs[tier].price, "Insufficient payment");
        
        uint256 tokenId = _tokenIdCounter++;
        _safeMint(msg.sender, tokenId);
        tokenTiers[tokenId] = tier;
        hasMinted[msg.sender] = true;
        tierConfigs[tier].currentSupply++;
        
        emit NFTPurchased(msg.sender, tokenId, tier);
    }
    
    /**
     * @dev Redeems an NFT for token purchase
     * @param tokenId The ID of the NFT to redeem
     * @param amount The amount of tokens to purchase
     * Requirements:
     * - The sender must own the NFT or be approved
     * - The NFT must not have been already redeemed
     * - The token sale must be active
     * - The claim deadline must not have passed
     * - The sender must send enough ETH
     */
    function redeemNFT(uint256 tokenId, uint256 amount) external payable nonReentrant {
        require(ownerOf(tokenId) == msg.sender || isApprovedForAll(ownerOf(tokenId), msg.sender), "Not owner or approved");
        require(!isRedeemed[tokenId], "Already redeemed");
        require(block.timestamp >= tokenSaleStartTime, "Token sale not started");
        require(block.timestamp <= tokenSaleEndTime, "Token sale ended");
        require(block.timestamp <= claimDeadline, "Claim deadline passed");
        require(amount > 0, "Amount must be greater than 0");
        
        Tier tier = tokenTiers[tokenId];
        uint256 discount = tierConfigs[tier].discountPercentage;
        uint256 discountedPrice = (tokenPrice * (100 - discount)) / 100;
        uint256 totalCost = amount * discountedPrice;
        
        require(msg.value >= totalCost, "Insufficient ETH sent");
        
        if (msg.value > totalCost) {
            (bool success, ) = msg.sender.call{value: msg.value - totalCost}("");
            require(success, "ETH refund failed");
        }
        
        require(tokenContract.transfer(msg.sender, amount), "Token transfer failed");
        
        isRedeemed[tokenId] = true;
        _burn(tokenId);
        
        emit NFTRedeemed(msg.sender, tokenId, tier, amount);
    }
    
    /**
     * @dev Withdraws collected ETH to the owner
     * Requirements:
     * - Only the owner can call this function
     * - The contract must have a balance
     */
    function withdraw() external onlyOwner nonReentrant {
        uint256 balance = address(this).balance;
        require(balance > 0, "No ETH to withdraw");
        (bool success, ) = owner().call{value: balance}("");
        require(success, "ETH transfer failed");
    }

    /**
     * @dev Emergency withdraw function for ETH
     * Requirements:
     * - Only the owner can call this function
     * - The contract must have a balance
     */
    function emergencyWithdraw() external onlyOwner {
        uint256 balance = address(this).balance;
        require(balance > 0, "No ETH to withdraw");
        (bool success, ) = owner().call{value: balance}("");
        require(success, "ETH transfer failed");
        emit EmergencyWithdraw(owner(), balance);
    }
    
    /**
     * @dev Returns the configuration for a specific tier
     * @param tier The tier to get configuration for
     * @return price The price in ETH
     * @return maxSupply The maximum supply
     * @return discountPercentage The discount percentage
     * @return mintStartTime The mint start time
     * @return mintEndTime The mint end time
     * @return currentSupply The current supply
     */
    function getTierConfig(Tier tier) external view returns (
        uint256 price,
        uint256 maxSupply,
        uint256 discountPercentage,
        uint256 mintStartTime,
        uint256 mintEndTime,
        uint256 currentSupply
    ) {
        TierConfig memory config = tierConfigs[tier];
        return (
            config.price,
            config.maxSupply,
            config.discountPercentage,
            config.mintStartTime,
            config.mintEndTime,
            config.currentSupply
        );
    }

    /**
     * @dev Sets the token contract address
     * @param _tokenContract The address of the token contract
     * Requirements:
     * - Only the owner can call this function
     * - The address must not be zero
     */
    function setTokenContract(address _tokenContract) external onlyOwner {
        require(_tokenContract != address(0), "Invalid token contract address");
        tokenContract = IERC20(_tokenContract);
    }

    /**
     * @dev Mints tokens to the owner's address
     * @param amount The amount of tokens to mint
     * Requirements:
     * - Only the owner can call this function
     * - The contract must have enough tokens
     */
    function ownerMintTokens(uint256 amount) external onlyOwner {
        require(amount > 0, "Amount must be greater than 0");
        require(tokenContract.balanceOf(address(this)) >= amount, "Not enough tokens in contract");
        
        tokenContract.safeTransfer(owner(), amount);
    }

    /**
     * @dev Deposits tokens into the contract
     * @param amount The amount of tokens to deposit
     * Requirements:
     * - Only the owner can call this function
     * - The amount must be greater than 0
     */
    function depositTokens(uint256 amount) external onlyOwner {
        require(amount > 0, "Amount must be greater than 0");
        require(tokenContract.transferFrom(msg.sender, address(this), amount), "Token transfer failed");
        emit TokensDeposited(amount);
    }

    /**
     * @dev Returns the contract's token balance
     * @return The balance of tokens in the contract
     */
    function getTokenBalance() external view returns (uint256) {
        return tokenContract.balanceOf(address(this));
    }
}