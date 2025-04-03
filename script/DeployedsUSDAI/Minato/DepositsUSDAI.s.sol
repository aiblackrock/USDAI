// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.21;

import "forge-std/Script.sol";
import {ERC20} from "@solmate/tokens/ERC20.sol";
import {BoringVault} from "src/base/BoringVault.sol";
import {TellerWithMultiAssetSupport} from "src/base/Roles/TellerWithMultiAssetSupport.sol";
import {ArcticArchitectureLens} from "src/helper/ArcticArchitectureLens.sol";
import {AccountantWithRateProviders} from "src/base/Roles/AccountantWithRateProviders.sol";
import {MinatoAddresses} from "test/resources/MinatoAddresses.sol";
import {Deployer} from "src/helper/Deployer.sol";
import {ContractNames} from "resources/ContractNames.sol";
import {MerkleTreeHelper} from "test/resources/MerkleTreeHelper/MerkleTreeHelper.sol";

/**
 * @title sUSDAI Deposit Integration Test
 * @notice This script demonstrates how to deposit USDC and ASTR into the sUSDAI vault on Minato
 * @dev Run with: forge script script/sUSDAIIntegrationTest/Deposit.sol --rpc-url $MINATO_RPC_URL
 */
contract sUSDAIDepositScript is Script, MinatoAddresses, ContractNames, MerkleTreeHelper {
    // Test parameters
    uint256 public constant USDAI_DEPOSIT_AMOUNT = 20 * 1e6; // 20 USDAI (6 decimals)
    
    // Contract instances
    Deployer public deployer;
    BoringVault vault;
    TellerWithMultiAssetSupport teller;
    ArcticArchitectureLens lens;
    AccountantWithRateProviders accountant;

    function setUp() public {
        vm.createSelectFork("minato");
        setSourceChainName("minato");
        deployer = Deployer(getAddress(sourceChain, "deployerAddress"));
        
        // Initialize contract instances
        vault = BoringVault(payable(deployer.getAddress(sUsdaiMinatoVaultName)));
        teller = TellerWithMultiAssetSupport(deployer.getAddress(sUsdaiMinatoVaultTellerName));
        lens = ArcticArchitectureLens(deployer.getAddress(sUsdaiMinatoArcticArchitectureLensName));
        accountant = AccountantWithRateProviders(deployer.getAddress(sUsdaiMinatoVaultAccountantName));
    }

    function run() public {
        // Get the private key from environment variable
        uint256 privateKey = vm.envUint("PRIVATE_KEY");
        address user = vm.addr(privateKey);
        
        // Start broadcasting transactions
        vm.startBroadcast(privateKey);
        
        // Print initial balances
        console.log("=== Initial State ===");
        console.log("User address:", user);
        console.log("USDAI balance:", USDAI.balanceOf(user) / 1e6, "USDAI");
        console.log("Vault share balance:", vault.balanceOf(user) / 1e6, "shares");
        
        // Deposit USDAI
        if (USDAI.balanceOf(user) >= USDAI_DEPOSIT_AMOUNT) {
            console.log("\n=== Depositing USDAI ===");
            
            // Calculate expected shares
            uint256 expectedUsdaiShares = lens.previewDeposit(
                USDAI,
                USDAI_DEPOSIT_AMOUNT,
                vault,
                accountant
            );
            console.log("Expected shares from USDAI deposit:", expectedUsdaiShares / 1e6);
            
            // Log allowance before approval
            console.log("USDAI allowance before approval:", USDAI.allowance(user, address(teller)));
            
            // Approve USDAI for deposit
            USDAI.approve(address(vault), USDAI_DEPOSIT_AMOUNT);
            console.log("USDAI approved for deposit");
            
            // Log allowance after approval
            console.log("USDAI allowance after approval:", USDAI.allowance(user, address(vault)));
            
            // Deposit USDAI
            uint256 sharesBefore = vault.balanceOf(user);
            teller.deposit(USDAI, USDAI_DEPOSIT_AMOUNT, 0);
            uint256 sharesAfter = vault.balanceOf(user);
            
            console.log("Actual shares received:", (sharesAfter - sharesBefore) / 1e6);
        } else {
            console.log("Insufficient USDAI balance for deposit");
        }
        
        // Print final state
        console.log("\n=== Final State ===");
        console.log("USDAI balance:", USDAI.balanceOf(user) / 1e6, "USDAI");
        console.log("Vault share balance:", vault.balanceOf(user) / 1e6, "shares");
        
        uint256 sharesValue = lens.balanceOfInAssets(user, vault, accountant);
        console.log("Value of shares in USDAI:", sharesValue / 1e6, "USDAI");
        
        vm.stopBroadcast();
    }
}