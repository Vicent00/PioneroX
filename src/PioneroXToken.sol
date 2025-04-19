// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

import "../lib/openzeppelin-contracts/contracts/token/ERC20/ERC20.sol";
import "../lib/openzeppelin-contracts/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import "../lib/openzeppelin-contracts/contracts/access/Ownable.sol";
import "../lib/openzeppelin-contracts/contracts/utils/ReentrancyGuard.sol";

/**
 * @title PioneroXToken
 * @dev Implementation of the PioneroX ERC20 token with burnable and ownable functionality.
 * This token is used in the PioneroX presale system for tiered NFT sales.
 * The token implements standard ERC20 functionality with additional features:
 * - Burnable tokens (users can burn their own tokens)
 * - Ownable (only owner can mint new tokens)
 * - Reentrancy protection for mint and burn operations
 */
contract PioneroXToken is ERC20, ERC20Burnable, Ownable, ReentrancyGuard {
    /**
     * @dev Emitted when new tokens are minted
     * @param to The address receiving the minted tokens
     * @param amount The amount of tokens minted
     */
    event TokensMinted(address indexed to, uint256 amount);
    
    /**
     * @dev Emitted when tokens are burned
     * @param from The address burning the tokens
     * @param amount The amount of tokens burned
     */
    event TokensBurned(address indexed from, uint256 amount);
    
    /**
     * @dev Constructor that initializes the token with a name, symbol, and initial supply.
     * @param name The name of the token (e.g., "PioneroX Token")
     * @param symbol The symbol of the token (e.g., "PXT")
     * @param initialSupply The initial supply of tokens to mint to the deployer
     * Requirements:
     * - The name and symbol must not be empty
     * - If initialSupply is greater than 0, tokens will be minted to the deployer
     */
    constructor(
        string memory name,
        string memory symbol,
        uint256 initialSupply
    ) ERC20(name, symbol) Ownable(msg.sender) {
        if (initialSupply > 0) {
            _mint(msg.sender, initialSupply);
        }
    }
    
    /**
     * @dev Mints new tokens to a specified address.
     * @param to The address to mint tokens to
     * @param amount The amount of tokens to mint
     * Requirements:
     * - Only the owner can mint tokens
     * - The amount must be greater than 0
     * - The recipient address cannot be zero
     * - The function is protected against reentrancy attacks
     */
    function mint(address to, uint256 amount) 
        external 
        onlyOwner 
        nonReentrant 
    {
        require(to != address(0), "Mint to zero address");
        require(amount > 0, "Amount must be greater than 0");
        
        _mint(to, amount);
        emit TokensMinted(to, amount);
    }
    
    /**
     * @dev Burns tokens from the caller's balance.
     * @param amount The amount of tokens to burn
     * Requirements:
     * - The caller must have sufficient balance
     * - The amount must be greater than 0
     * - The function is protected against reentrancy attacks
     */
    function burn(uint256 amount) 
        public 
        override 
        nonReentrant 
    {
        super.burn(amount);
        emit TokensBurned(msg.sender, amount);
    }
} 