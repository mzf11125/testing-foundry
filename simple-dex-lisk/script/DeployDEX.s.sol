// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {Script, console} from "forge-std/Script.sol";
import {CampusCoin} from "../src/CampusCoin.sol";
import {MockUSDC} from "../src/MockUSDC.sol";
import {SimpleDEX} from "../src/SimpleDEX.sol";

contract DeployDEX is Script {
    // Contract instances
    CampusCoin public campusCoin;
    MockUSDC public usdc;
    SimpleDEX public dex;

    function run() public returns (address, address, address) {
        console.log("========================================");
        console.log("Deploying Simple DEX to Lisk Sepolia...");
        console.log("========================================");
        console.log("");

        // Get deployer info
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        address deployer = vm.addr(deployerPrivateKey);

        console.log("Deployer address:", deployer);
        console.log("Network: Lisk Sepolia Testnet (Chain ID: 4202)");

        // Check balance
        uint256 balance = deployer.balance;
        console.log("Deployer balance:", balance / 1e18, "ETH");

        if (balance < 0.01 ether) {
            console.log("");
            console.log("WARNING: Low balance!");
            console.log("Get test ETH from faucet:");
            console.log("https://sepolia-faucet.lisk.com");
            console.log("");
        }

        vm.startBroadcast(deployerPrivateKey);

        // Step 1: Deploy CampusCoin
        console.log("");
        console.log("Step 1: Deploying CampusCoin...");
        console.log("-----------------------------------");
        campusCoin = new CampusCoin();
        console.log("CampusCoin deployed at:", address(campusCoin));

        // Step 2: Deploy MockUSDC
        console.log("");
        console.log("Step 2: Deploying MockUSDC...");
        console.log("-------------------------------");
        usdc = new MockUSDC();
        console.log("MockUSDC deployed at:", address(usdc));

        // Step 3: Deploy SimpleDEX
        console.log("");
        console.log("Step 3: Deploying SimpleDEX...");
        console.log("--------------------------------");
        dex = new SimpleDEX(address(campusCoin), address(usdc));
        console.log("SimpleDEX deployed at:", address(dex));

        vm.stopBroadcast();

        // Step 4: Verification
        console.log("");
        console.log("Step 4: Deployment verification...");
        console.log("------------------------------------");
        _verifyDeployment();

        // Step 5: Next steps
        console.log("");
        console.log("Step 5: Next steps...");
        console.log("----------------------");
        _printInstructions();

        return (address(campusCoin), address(usdc), address(dex));
    }

    function _verifyDeployment() internal view {
        console.log("CampusCoin:");
        console.log("  Name          :", campusCoin.name());
        console.log("  Symbol        :", campusCoin.symbol());
        console.log("  Decimals      :", campusCoin.decimals());
        console.log("  Initial Supply:", campusCoin.totalSupply() / 10**18, "CAMP");
        console.log("");

        console.log("MockUSDC:");
        console.log("  Name          :", usdc.name());
        console.log("  Symbol        :", usdc.symbol());
        console.log("  Decimals      :", usdc.decimals());
        console.log("  Initial Supply:", usdc.totalSupply() / 10**6, "USDC");
        console.log("");

        console.log("SimpleDEX:");
        console.log("  LP Token Name :", dex.name());
        console.log("  LP Token Symbol:", dex.symbol());
        console.log("  Token A       :", address(dex.tokenA()));
        console.log("  Token B       :", address(dex.tokenB()));
    }

    function _printInstructions() internal view {
        console.log("DEPLOYED CONTRACT ADDRESSES:");
        console.log("  CampusCoin :", address(campusCoin));
        console.log("  MockUSDC   :", address(usdc));
        console.log("  SimpleDEX  :", address(dex));
        console.log("");

        console.log("BLOCK EXPLORER:");
        console.log("  CampusCoin :", "https://sepolia-blockscout.lisk.com/address/%s", address(campusCoin));
        console.log("  MockUSDC   :", "https://sepolia-blockscout.lisk.com/address/%s", address(usdc));
        console.log("  SimpleDEX  :", "https://sepolia-blockscout.lisk.com/address/%s", address(dex));
        console.log("");

        console.log("NEXT STEPS:");
        console.log("  1. To add initial liquidity, run:");
        console.log("     forge script script/AddLiquidity.s.sol --rpc-url lisk_sepolia --broadcast --legacy");
        console.log("");
        console.log("  2. Interact with your DEX:");
        console.log("     - Add liquidity: dex.addLiquidity(campAmount, usdcAmount)");
        console.log("     - Swap CAMP->USDC: dex.swapAforB(campAmount, minUsdcOut)");
        console.log("     - Swap USDC->CAMP: dex.swapBforA(usdcAmount, minCampOut)");
        console.log("     - Remove liquidity: dex.removeLiquidity(lpAmount)");
        console.log("");
        console.log("Save these addresses for later use!");
    }
}