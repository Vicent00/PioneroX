// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

import "forge-std/Script.sol";
import "../src/PioneroXToken.sol";
import "../src/TieredPresale.sol";

contract DeployScript is Script {
    function run() external {
        // Obtener la clave privada del .env
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        
        // Iniciar broadcasting de transacciones
        vm.startBroadcast(deployerPrivateKey);

        // 1. Desplegar el token
        PioneroXToken token = new PioneroXToken(
            "PioneroX Token",
            "PXT",
            1000000 * 10**18  // 1 millón de tokens
        );

      
        TieredPresale presale = new TieredPresale(
            "PioneroX Presale NFT",
            "PXN",
            "ipfs://bafybeidt5xhqnc236gdusvlwr7hmyxcgoephsxwrr3qtnggwd5zfvfm6um/",  // Reemplaza con tu hash de IPFS
            address(token)
        );

        // 3. Configurar los tiers
        // BRONZE
        presale.configureTier(
            TieredPresale.Tier.BRONZE,
            0.1 ether,    // 0.1 ETH
            1000,         // 1000 NFTs
            20,           // 20% de descuento
            block.timestamp + 1 hours,  // Inicio en 1 hora
            block.timestamp + 7 days    // Duración 7 días
        );

        // SILVER
        presale.configureTier(
            TieredPresale.Tier.SILVER,
            0.2 ether,    // 0.2 ETH
            500,          // 500 NFTs
            30,           // 30% de descuento
            block.timestamp + 1 hours,  // Inicio en 1 hora
            block.timestamp + 7 days    // Duración 7 días
        );

        // GOLD
        presale.configureTier(
            TieredPresale.Tier.GOLD,
            0.5 ether,    // 0.5 ETH
            100,          // 100 NFTs
            40,           // 40% de descuento
            block.timestamp + 1 hours,  // Inicio en 1 hora
            block.timestamp + 7 days    // Duración 7 días
        );

        // 4. Mintear tokens para el presale
        token.mint(address(presale), 1000000 * 10**18);

        // 5. Iniciar la token sale
        presale.startTokenSale(
            0.1 ether,    // Precio del token en ETH
            7 days,       // Duración de la venta
            30 days       // Deadline para canjear
        );

        // Detener broadcasting
        vm.stopBroadcast();

        // Log de las direcciones desplegadas
        console.log("Token deployed at:", address(token));
        console.log("Presale deployed at:", address(presale));
    }
} 