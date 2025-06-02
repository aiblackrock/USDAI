// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.21;

import "forge-std/Script.sol";
import {ERC20} from "@solmate/tokens/ERC20.sol";
import {BoringVault} from "src/base/BoringVault.sol";
import {TellerWithMultiAssetSupport} from "src/base/Roles/TellerWithMultiAssetSupport.sol";
import {ArcticArchitectureLens} from "src/helper/ArcticArchitectureLens.sol";
import {AccountantWithRateProviders} from "src/base/Roles/AccountantWithRateProviders.sol";
import {PlumeAddresses} from "test/resources/PlumeAddresses.sol";
import {Deployer} from "src/helper/Deployer.sol";
import {ContractNames} from "resources/ContractNames.sol";
import {MerkleTreeHelper} from "test/resources/MerkleTreeHelper/MerkleTreeHelper.sol";

/**
 * @title USDAI Deposit Integration Test
 * @notice This script demonstrates how to deposit PUSD into the USDAI vault on Plume
 * @dev Run with: forge script script/USDAIIntegrationTest/Deposit.sol --rpc-url $PLUME_RPC_URL
 */
contract USDAIDepositScript is Script, PlumeAddresses, ContractNames, MerkleTreeHelper {
    // Test parameters
    uint256 public constant PUSD_DEPOSIT_AMOUNT = 5 * 1e6; // 1 PUSD (18 decimals)
    
    // Contract instances
    Deployer public deployer;
    BoringVault vault;
    TellerWithMultiAssetSupport teller;
    ArcticArchitectureLens lens;
    AccountantWithRateProviders accountant;

    function setUp() public {
        vm.createSelectFork("plume");
        setSourceChainName("plume");
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
        
        // Print initial balances
        console.log("=== Initial State ===");
        console.log("User address:", user);
        console.log("PUSD balance:", PUSD.balanceOf(user) / 1e18, "PUSD");
        console.log("Vault share balance:", vault.balanceOf(user) / 1e18, "shares");
        
        // Deposit PUSD
        if (PUSD.balanceOf(user) >= PUSD_DEPOSIT_AMOUNT) {
            console.log("\n=== Depositing PUSD ===");
            
            // Calculate expected shares
            uint256 expectedPusdShares = lens.previewDeposit(
                PUSD,
                PUSD_DEPOSIT_AMOUNT,
                vault,
                accountant
            );
            console.log("Expected shares from PUSD deposit:", expectedPusdShares / 1e18);
            
            // Log allowance before approval
            console.log("PUSD allowance before approval:", PUSD.allowance(user, address(teller)));
            
            // Approve PUSD for deposit
            PUSD.approve(address(vault), PUSD_DEPOSIT_AMOUNT);
            console.log("PUSD approved for deposit");
            
            // Log allowance after approval
            console.log("PUSD allowance after approval:", PUSD.allowance(user, address(vault)));
            
            // Deposit PUSD
            uint256 sharesBefore = vault.balanceOf(user);
            teller.deposit(PUSD, PUSD_DEPOSIT_AMOUNT, 0);
            uint256 sharesAfter = vault.balanceOf(user);
            
            console.log("Actual shares received:", (sharesAfter - sharesBefore) / 1e18);
        } else {
            console.log("Insufficient PUSD balance for deposit");
        }
        
        // Print final state
        console.log("\n=== Final State ===");
        console.log("PUSD balance:", PUSD.balanceOf(user) / 1e18, "PUSD");
        console.log("Vault share balance:", vault.balanceOf(user) / 1e18, "shares");
        
        // Calculate value of shares in PUSD
        uint256 sharesValue = lens.balanceOfInAssets(user, vault, accountant);
        console.log("Value of shares in PUSD:", sharesValue / 1e18, "PUSD");
        
        vm.stopBroadcast();
    }
}