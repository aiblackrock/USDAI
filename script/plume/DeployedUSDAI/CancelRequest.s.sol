// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.21;

import "forge-std/Script.sol";
import {ERC20} from "@solmate/tokens/ERC20.sol";
import {BoringVault} from "src/base/BoringVault.sol";
import {TellerWithMultiAssetSupport} from "src/base/Roles/TellerWithMultiAssetSupport.sol";
import {ArcticArchitectureLens} from "src/helper/ArcticArchitectureLens.sol";
import {AccountantWithRateProviders} from "src/base/Roles/AccountantWithRateProviders.sol";
import {PlumeAddresses} from "test/resources/PlumeAddresses.sol";
import {BoringOnChainQueue} from "src/base/Roles/BoringQueue/BoringOnChainQueue.sol";
import {BoringOnChainQueueWithTracking} from "src/base/Roles/BoringQueue/BoringOnChainQueueWithTracking.sol";
import {Deployer} from "src/helper/Deployer.sol";
import {ContractNames} from "resources/ContractNames.sol";
import {MerkleTreeHelper} from "test/resources/MerkleTreeHelper/MerkleTreeHelper.sol";

/**
 * @title USDAI Cancel Request Integration Test
 * @notice This script demonstrates how to cancel a pending withdrawal request from the USDAI vault on Minato
 * @dev Run with: forge script script/DeployedUSDAI/Minato/CancelRequest.s.sol --rpc-url $MINATO_RPC_URL
 */
contract USDAICancelRequestScript is Script, PlumeAddresses, ContractNames, MerkleTreeHelper {
    // Contract instances
    Deployer public deployer;
    BoringVault vault;
    TellerWithMultiAssetSupport teller;
    ArcticArchitectureLens lens;
    AccountantWithRateProviders accountant;
    BoringOnChainQueueWithTracking queue;

    // User's initial share balance
    uint256 initialShares;
    uint256 withdrawShares;

    bytes32 requestId = 0x2c4ec705c6291150f29c7b10837917a4e03f68b48eaad85800c8bddc64de86c0;

    function setUp() public {
        vm.createSelectFork("plume");
        setSourceChainName("plume");
        deployer = Deployer(getAddress(sourceChain, "deployerAddress"));
        
        // Initialize contract instances
        vault = BoringVault(payable(deployer.getAddress(UsdaiVaultName)));
        teller = TellerWithMultiAssetSupport(deployer.getAddress(UsdaiVaultTellerName));
        lens = ArcticArchitectureLens(deployer.getAddress(UsdaiArcticArchitectureLensName));
        accountant = AccountantWithRateProviders(deployer.getAddress(UsdaiVaultAccountantName));
        queue = BoringOnChainQueueWithTracking(deployer.getAddress(UsdaiVaultQueueName));
    }

    function run() public {
        uint256 privateKey = vm.envUint("PRIVATE_KEY");
        address user = vm.addr(privateKey);
        
        vm.startBroadcast(privateKey);
        console.log("Queue address:", address(queue));
        console.log("vault address:", address(vault));
        
        console.log("=== Initial State ===");
        console.log("User address:", user);
        console.log("PUSD balance:", PUSD.balanceOf(user) / 1e6, "PUSD");
        console.log("Vault share balance:", vault.balanceOf(user) / 1e6, "shares");

        
        console.log("\n=== Canceling Withdrawal Request ===");
        console.log("Request ID to cancel:", vm.toString(requestId));
        
        // Display the request details before cancellation and cancel it
        try queue.cancelOnChainWithdrawUsingRequestId(requestId) returns (BoringOnChainQueue.OnChainWithdraw memory request) {
            console.log("\n=== Cancelled Withdraw Request Details ===");
            console.log("User:", request.user);
            console.log("Asset out:", request.assetOut);
            console.log("Amount of shares:", uint256(request.amountOfShares) / 1e6, "shares");
            console.log("Amount of assets:", uint256(request.amountOfAssets) / 1e6, "assets");
            console.log("\n=== Withdrawal Request Cancelled Successfully ===");
            
        } catch {
            console.log("Failed to cancel withdraw request. Request might not exist or already be cancelled.");
        }
        
        vm.stopBroadcast();
    }
}
