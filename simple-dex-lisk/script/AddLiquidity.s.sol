// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {Script, console} from "forge-std/Script.sol";
import {CampusCoin} from "../src/CampusCoin.sol";
import {MockUSDC} from "../src/MockUSDC.sol";
import {SimpleDEX} from "../src/SimpleDEX.sol";

contract AddLiquidity is Script {
    // Existing contract addresses on Lisk Sepolia (Latest Deployment)
    address constant CAMP_ADDRESS = 0x58cCF6ffF745C97Be8CA1ef1cE39346cb90d3ff7;
    address constant USDC_ADDRESS = 0x0Eb09fF73E7c574263a635bb60eaa73dB155Ee69;
    address constant DEX_ADDRESS = 0x56C3e0D38cbdFce27CC870F2dbaD0428f082E973;

    // Liquidity amounts
    uint256 constant CAMP_AMOUNT = 1000 * 10**18;  // 1,000 CAMP
    uint256 constant USDC_AMOUNT = 2000 * 10**6;   // 2,000 USDC

    function run() public {
        console.log("Adding liquidity to existing DEX on Lisk Sepolia...");
        console.log("");

        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        address deployer = vm.addr(deployerPrivateKey);

        console.log("Deployer:", deployer);
        console.log("DEX:", DEX_ADDRESS);
        console.log("");

        CampusCoin camp = CampusCoin(CAMP_ADDRESS);
        MockUSDC usdc = MockUSDC(USDC_ADDRESS);
        SimpleDEX dex = SimpleDEX(DEX_ADDRESS);

        vm.startBroadcast(deployerPrivateKey);

        // Check balances
        uint256 campBalance = camp.balanceOf(deployer);
        uint256 usdcBalance = usdc.balanceOf(deployer);

        console.log("Current balances:");
        console.log("CAMP:", campBalance / 10**18);
        console.log("USDC:", usdcBalance / 10**6);
        console.log("");

        // Mint if needed
        if (campBalance < CAMP_AMOUNT) {
            console.log("Minting CAMP tokens...");
            camp.mint(deployer, CAMP_AMOUNT + 5000 * 10**18);
        }

        if (usdcBalance < USDC_AMOUNT) {
            console.log("Minting USDC tokens...");
            usdc.mint(deployer, USDC_AMOUNT + 10000 * 10**6);
        }

        // Approve
        console.log("Approving tokens...");
        camp.approve(DEX_ADDRESS, type(uint256).max);
        usdc.approve(DEX_ADDRESS, type(uint256).max);

        // Add liquidity
        console.log("Adding liquidity...");
        uint256 liquidity = dex.addLiquidity(CAMP_AMOUNT, USDC_AMOUNT);

        console.log("Success! LP tokens minted:", liquidity);
        console.log("");

        vm.stopBroadcast();

        // Verify
        (uint256 reserveA, uint256 reserveB, uint256 totalLP, uint256 price) = dex.getPoolInfo();
        console.log("Pool Info:");
        console.log("CAMP Reserve:", reserveA / 10**18);
        console.log("USDC Reserve:", reserveB / 10**6);
        console.log("Total LP:", totalLP);
        console.log("Price:", price / 1e18, "USDC per CAMP");
    }
}