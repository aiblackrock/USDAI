// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.21;

import "forge-std/Script.sol";
import {ERC20} from "@solmate/tokens/ERC20.sol";
import {BoringVault} from "src/base/BoringVault.sol";
import {TellerWithMultiAssetSupport} from "src/base/Roles/TellerWithMultiAssetSupport.sol";
import {ArcticArchitectureLens} from "src/helper/ArcticArchitectureLens.sol";
import {AccountantWithRateProviders} from "src/base/Roles/AccountantWithRateProviders.sol";
import {SepoliaAddresses} from "test/resources/SepoliaAddresses.sol";
import {Deployer} from "src/helper/Deployer.sol";
import {ContractNames} from "resources/ContractNames.sol";
import {MerkleTreeHelper} from "test/resources/MerkleTreeHelper/MerkleTreeHelper.sol";

/**
 * @title USDAI Deposit Integration Test
 * @notice This script demonstrates how to deposit USDC into the USDAI vault on Sepolia
 * @dev Run with: forge script script/USDAIIntegrationTest/Deposit.sol --rpc-url $MINATO_RPC_URL
 */
contract USDAIDepositScript is Script, SepoliaAddresses, ContractNames, MerkleTreeHelper {
    // Test parameters
    uint256 public constant USDC_DEPOSIT_AMOUNT = 10 * 1e6; // 10 USDC (6 decimals)
    
    // Contract instances
    Deployer public deployer;
    BoringVault vault;
    TellerWithMultiAssetSupport teller;
    ArcticArchitectureLens lens;
    AccountantWithRateProviders accountant;

    function setUp() public {
        vm.createSelectFork("sepolia");
        setSourceChainName("sepolia");
        deployer = Deployer(getAddress(sourceChain, "deployerAddress"));
        
        // Initialize contract instances
        vault = BoringVault(payable(deployer.getAddress(UsdaiVaultName)));
        teller = TellerWithMultiAssetSupport(deployer.getAddress(UsdaiVaultTellerName));
        lens = ArcticArchitectureLens(deployer.getAddress(UsdaiArcticArchitectureLensName));
        accountant = AccountantWithRateProviders(deployer.getAddress(UsdaiVaultAccountantName));
    }

    function run() public {
        // Get the private key from environment variable
        uint256 privateKey = vm.envUint("PRIVATE_KEY");
        address user = vm.addr(privateKey);
        
        // Start broadcasting transactions
        vm.startBroadcast(privateKey);
        
        // Deposit USDC
        if (USDC.balanceOf(user) >= USDC_DEPOSIT_AMOUNT) {
            console.log("\n=== Depositing USDC ===");
            
            // Calculate expected shares
            uint256 expectedUsdcShares = lens.previewDeposit(
                USDC,
                USDC_DEPOSIT_AMOUNT,
                vault,
                accountant
            );
            console.log("Expected shares from USDC deposit:", expectedUsdcShares / 1e6);
            
            // Log allowance before approval
            console.log("USDC allowance before approval:", USDC.allowance(user, address(teller)));
            
            // Approve USDC for deposit
            USDC.approve(address(vault), USDC_DEPOSIT_AMOUNT);
            console.log("USDC approved for deposit");
            
            // Log allowance after approval
            console.log("USDC allowance after approval:", USDC.allowance(user, address(vault)));
            
            // Deposit USDC
            uint256 sharesBefore = vault.balanceOf(user);
            teller.deposit(USDC, USDC_DEPOSIT_AMOUNT, 0);
            uint256 sharesAfter = vault.balanceOf(user);
            
            console.log("Actual shares received:", (sharesAfter - sharesBefore) / 1e6);
        } else {
            console.log("Insufficient USDC balance for deposit");
        }
        
        // Calculate value of shares in USDC
        uint256 sharesValue = lens.balanceOfInAssets(user, vault, accountant);
        console.log("Value of shares in USDC:", sharesValue / 1e6, "USDC");
        
        vm.stopBroadcast();
    }
}