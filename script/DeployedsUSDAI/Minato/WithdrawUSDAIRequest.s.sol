// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.21;

import "forge-std/Script.sol";
import {ERC20} from "@solmate/tokens/ERC20.sol";
import {BoringVault} from "src/base/BoringVault.sol";
import {TellerWithMultiAssetSupport} from "src/base/Roles/TellerWithMultiAssetSupport.sol";
import {ArcticArchitectureLens} from "src/helper/ArcticArchitectureLens.sol";
import {AccountantWithRateProviders} from "src/base/Roles/AccountantWithRateProviders.sol";
import {MinatoAddresses} from "test/resources/MinatoAddresses.sol";
import {BoringOnChainQueue} from "src/base/Roles/BoringQueue/BoringOnChainQueue.sol";
import {BoringOnChainQueueWithTracking} from "src/base/Roles/BoringQueue/BoringOnChainQueueWithTracking.sol";
import {Deployer} from "src/helper/Deployer.sol";
import {ContractNames} from "resources/ContractNames.sol";
import {MerkleTreeHelper} from "test/resources/MerkleTreeHelper/MerkleTreeHelper.sol";

/**
 * @title USDAI Withdraw Integration Test
 * @notice This script demonstrates how to withdraw USDC and ASTR from the USDAI vault on Minato using the BoringQueue
 * @dev Run with: forge script script/DeployedUSDAI/Minato/Withdraw.s.sol --rpc-url $MINATO_RPC_URL
 */
contract sUSDAIWithdrawRequestScript is Script, MinatoAddresses, ContractNames, MerkleTreeHelper {
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

    function setUp() public {
        vm.createSelectFork("minato");
        setSourceChainName("minato");
        deployer = Deployer(getAddress(sourceChain, "deployerAddress"));
        
        // Initialize contract instances
        vault = BoringVault(payable(deployer.getAddress(sUsdaiMinatoVaultName)));
        teller = TellerWithMultiAssetSupport(deployer.getAddress(sUsdaiMinatoVaultTellerName));
        lens = ArcticArchitectureLens(deployer.getAddress(sUsdaiMinatoArcticArchitectureLensName));
        accountant = AccountantWithRateProviders(deployer.getAddress(sUsdaiMinatoVaultAccountantName));
        queue = BoringOnChainQueueWithTracking(deployer.getAddress(sUsdaiMinatoVaultQueueName));
    }

    function run() public {
        uint256 privateKey = vm.envUint("PRIVATE_KEY");
        address user = vm.addr(privateKey);
        
        initialShares = vault.balanceOf(user);
        
        withdrawShares = 1 * 1e6;
        vm.startBroadcast(privateKey);
        
        console.log("=== Initial State ===");
        console.log("User address:", user);
        console.log("USDAI balance:", USDAI.balanceOf(user) / 1e6, "USDAI");
        console.log("Vault share balance:", vault.balanceOf(user) / 1e6, "shares");
        
        uint256 sharesValue = lens.balanceOfInAssets(user, vault, accountant);
        console.log("Value of shares in USDAI:", sharesValue / 1e6, "USDAI");
        
        // Check if user has shares to withdraw
        if (initialShares > withdrawShares) {
            console.log("\n=== Requesting Withdrawal via Queue ===");
            console.log("Requesting withdrawal of shares amount:", withdrawShares / 1e6, "shares");
            
            // Approve queue to spend shares
            vault.approve(address(queue), withdrawShares);
            
            // Set discount and deadline parameters
            uint16 discount = 3; // 3 basis points discount (0.03%)
            uint24 secondsToDeadline = 10 minutes;
            
            // Request withdrawal through queue
            bytes32 requestId = queue.requestOnChainWithdraw(
                    address(USDAI),
                    uint128(withdrawShares),
                    discount,
                    secondsToDeadline
                );
  
            console.log("Withdrawal request created with ID:", vm.toString(requestId));
            // Get the withdraw request details
            try queue.getOnChainWithdraw(requestId) returns (BoringOnChainQueue.OnChainWithdraw memory request) {
                console.log("\n=== Withdraw Request Details ===");
                console.log("User:", request.user);
                console.log("Asset out:", request.assetOut);
                console.log("Amount of shares:", uint256(request.amountOfShares) / 1e6, "shares");
                console.log("Amount of assets:", uint256(request.amountOfAssets) / 1e6, "assets");
                console.log("Creation time:", request.creationTime);
                console.log("Seconds to maturity:", request.secondsToMaturity);
                console.log("Seconds to deadline:", request.secondsToDeadline);
                console.log("Nonce:", request.nonce);
            } catch {
                console.log("Failed to retrieve withdraw request details");
            }
            
        } else {
            console.log("No shares available for withdrawal");
        }
        
        vm.stopBroadcast();
    }
}
