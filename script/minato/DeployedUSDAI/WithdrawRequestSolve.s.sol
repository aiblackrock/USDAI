// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.21;

import "forge-std/Script.sol";
import {ERC20} from "@solmate/tokens/ERC20.sol";
import {SafeTransferLib} from "@solmate/utils/SafeTransferLib.sol";
import {BoringVault} from "src/base/BoringVault.sol";
import {TellerWithMultiAssetSupport} from "src/base/Roles/TellerWithMultiAssetSupport.sol";
import {ArcticArchitectureLens} from "src/helper/ArcticArchitectureLens.sol";
import {AccountantWithRateProviders} from "src/base/Roles/AccountantWithRateProviders.sol";
import {MinatoAddresses} from "test/resources/MinatoAddresses.sol";
import {BoringOnChainQueue} from "src/base/Roles/BoringQueue/BoringOnChainQueue.sol";
import {BoringOnChainQueueWithTracking} from "src/base/Roles/BoringQueue/BoringOnChainQueueWithTracking.sol";
import {BoringSolver} from "src/base/Roles/BoringQueue/BoringSolver.sol";
import {Deployer} from "src/helper/Deployer.sol";
import {ContractNames} from "resources/ContractNames.sol";
import {MerkleTreeHelper} from "test/resources/MerkleTreeHelper/MerkleTreeHelper.sol";
import {console} from "forge-std/console.sol";
import {RolesAuthority, Authority} from "@solmate/auth/authorities/RolesAuthority.sol";

/**
 * @title USDAI Withdraw Request Solve Script
 * @notice This script solves all withdrawal requests from the USDAI vault on Minato using the BoringSolver
 * @dev Run with: forge script script/DeployedUSDAI/Minato/WithdrawRequestSolve.s.sol --rpc-url $MINATO_RPC_URL -vvvv
 */
contract USDAIWithdrawRequestSolveScript is Script, MinatoAddresses, ContractNames, MerkleTreeHelper {
    using SafeTransferLib for ERC20;
    
    // Contract instances
    Deployer public deployer;
    BoringVault vault;
    TellerWithMultiAssetSupport teller;
    ArcticArchitectureLens lens;
    AccountantWithRateProviders accountant;
    BoringOnChainQueueWithTracking queue;
    BoringSolver solver;

    function setUp() public {
        vm.createSelectFork("minato");
        setSourceChainName("minato");
        
        deployer = Deployer(getAddress(sourceChain, "deployerAddress"));
        vault = BoringVault(payable(deployer.getAddress(UsdaiVaultName)));
        teller = TellerWithMultiAssetSupport(deployer.getAddress(UsdaiVaultTellerName));
        lens = ArcticArchitectureLens(deployer.getAddress(UsdaiArcticArchitectureLensName));
        accountant = AccountantWithRateProviders(deployer.getAddress(UsdaiVaultAccountantName));
        queue = BoringOnChainQueueWithTracking(deployer.getAddress(UsdaiVaultQueueName));
        solver = BoringSolver(deployer.getAddress(UsdaiVaultQueueSolverName));
    }

    function run() public {
        uint256 privateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(privateKey);
        
        console.log("=== Solving Withdrawal Requests by Solver ===");
        
        // Get all withdrawal requests
        (bytes32[] memory requestIds, BoringOnChainQueue.OnChainWithdraw[] memory requests) = queue.getWithdrawRequests();
        
        if (requestIds.length == 0) {
            console.log("No withdrawal requests found!");
            vm.stopBroadcast();
            return;
        }
        
        console.log("Found %d withdrawal requests", requestIds.length);
        
        // Filter requests by maturity and deadline
        uint256 validRequestCount = 0;
        for (uint256 i = 0; i < requests.length; i++) {
            BoringOnChainQueue.OnChainWithdraw memory request = requests[i];
            
            // Check if request is matured
            uint256 maturityTime = request.creationTime + request.secondsToMaturity;
            if (block.timestamp < maturityTime) {
                console.log("Request %d is not yet matured. Skipping.", i);
                continue;
            }
            
            // Check if deadline has passed
            uint256 deadlineTime = maturityTime + request.secondsToDeadline;
            if (block.timestamp > deadlineTime) {
                console.log("Request %d deadline has passed. Skipping.", i);
                continue;
            }
            
            // Move valid request to the front of the array
            if (i != validRequestCount) {
                requests[validRequestCount] = request;
            }
            validRequestCount++;
        }
        
        if (validRequestCount == 0) {
            console.log("No valid withdrawal requests to solve!");
            vm.stopBroadcast();
            return;
        }
        
        // Create a new array with only valid requests
        BoringOnChainQueue.OnChainWithdraw[] memory validRequests = new BoringOnChainQueue.OnChainWithdraw[](validRequestCount);
        for (uint256 i = 0; i < validRequestCount; i++) {
            validRequests[i] = requests[i];
        }
        
        console.log("Processing %d valid withdrawal requests", validRequestCount);
        
        // Group requests by asset
        address[] memory uniqueAssets = new address[](validRequestCount);
        uint256 uniqueAssetCount = 0;
        
        for (uint256 i = 0; i < validRequestCount; i++) {
            address assetOut = validRequests[i].assetOut;
            bool isUnique = true;
            
            for (uint256 j = 0; j < uniqueAssetCount; j++) {
                if (uniqueAssets[j] == assetOut) {
                    isUnique = false;
                    break;
                }
            }
            
            if (isUnique) {
                uniqueAssets[uniqueAssetCount] = assetOut;
                uniqueAssetCount++;
            }
        }
        
        // Process each asset group separately
        for (uint256 assetIndex = 0; assetIndex < uniqueAssetCount; assetIndex++) {
            address assetOut = uniqueAssets[assetIndex];
            ERC20 asset = ERC20(assetOut);
            
            // Count requests for this asset
            uint256 assetRequestCount = 0;
            for (uint256 i = 0; i < validRequestCount; i++) {
                if (validRequests[i].assetOut == assetOut) {
                    assetRequestCount++;
                }
            }
            
            // Create array of requests for this asset
            BoringOnChainQueue.OnChainWithdraw[] memory assetRequests = new BoringOnChainQueue.OnChainWithdraw[](assetRequestCount);
            uint256 totalAssetsNeeded = 0;
            uint256 requestIndex = 0;
            
            for (uint256 i = 0; i < validRequestCount; i++) {
                if (validRequests[i].assetOut == assetOut) {
                    assetRequests[requestIndex] = validRequests[i];
                    totalAssetsNeeded += validRequests[i].amountOfAssets;
                    requestIndex++;
                }
            }
            
            console.log("\n=== Processing %d requests for asset %s ===", assetRequestCount, assetOut);
            console.log("Total assets needed: %d", totalAssetsNeeded / 10**asset.decimals());
            
            console.log("Calling boringRedeemSolve...");
            
            solver.boringRedeemSolve(assetRequests, address(teller));
            
            console.log("Withdrawal requests solved!");
        }
        
        console.log("\n=== All Withdrawal Requests Processed ===");
        
        vm.stopBroadcast();
    }
}
