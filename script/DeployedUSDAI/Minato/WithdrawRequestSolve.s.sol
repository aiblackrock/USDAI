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
import {BoringSolver} from "src/base/Roles/BoringQueue/BoringSolver.sol";

/**
 * @title USDAI Withdraw Request Solve Script
 * @notice This script solves a withdrawal request from the USDAI vault on Minato using the BoringSolver
 * @dev Run with: forge script script/DeployedUSDAI/Minato/WithdrawRequestSolve.s.sol --rpc-url $MINATO_RPC_URL -vvvv
 */
contract USDAIWithdrawRequestSolveScript is Script, MinatoAddresses {
    using SafeTransferLib for ERC20;

    // Core contract addresses from deployment
    address public constant BORING_VAULT = 0x214E3B8099596697116FD934BbdB3903451a27b0;
    address public constant TELLER = 0x3cc9069a8e143E7fD4f4Fd593EB720416933877b;
    address public constant ACCOUNTANT = 0x664d42c3057a2f835505f39cFf48f6983d2f2c60;
    address public constant LENS = 0x904BAE52c17bC5Aa59c64B6b4C96c06034d080F4;

    // Queue and solver contract addresses
    address public constant BORING_QUEUE = 0xAc0f96de42527F0aB6935d2C309cf7aF65B042e9;
    address public constant BORING_SOLVER = 0x0E6afe0a279dd6E8b2AF495F39Cbf5222c26c157; 
    
    // Contract instances
    BoringVault vault;
    TellerWithMultiAssetSupport teller;
    ArcticArchitectureLens lens;
    AccountantWithRateProviders accountant;
    BoringOnChainQueue queue;
    BoringSolver solver;

    // Request ID to solve (will be set via command line)
    bytes32 requestIdToSolve;

    function setUp() public {
        // Create a fork of Minato network
        vm.createSelectFork("minato");
        
        // Initialize contract instances
        vault = BoringVault(payable(BORING_VAULT));
        teller = TellerWithMultiAssetSupport(TELLER);
        lens = ArcticArchitectureLens(LENS);
        accountant = AccountantWithRateProviders(ACCOUNTANT);
        queue = BoringOnChainQueue(BORING_QUEUE);
        solver = BoringSolver(BORING_SOLVER);
    }

    function run() public {
        // Get the private key from environment variable
        uint256 privateKey = vm.envUint("PRIVATE_KEY");
        // address user = vm.addr(privateKey);
        
        // Start broadcasting transactions
        vm.startBroadcast(privateKey);
        
        console.log("=== Solving Withdrawal Request ===");
        
        // // Get the withdrawal request
        // BoringOnChainQueue.OnChainWithdraw memory request = queue.getOnChainWithdraw(requestIdToSolve);
        
        // // Validate the request
        // if (request.user == address(0)) {
        //     console.log("Request not found or invalid!");
        //     vm.stopBroadcast();
        //     return;
        // }
        
        // console.log("Request details:");
        // console.log("  User:", request.user);
        // console.log("  Asset out:", request.assetOut);
        // console.log("  Amount of shares:", request.amountOfShares / 1e6, "shares");
        // console.log("  Amount of assets:", request.amountOfAssets / 1e6, "assets");
        
        // // Check if request is matured
        // uint256 maturityTime = request.creationTime + request.secondsToMaturity;
        // if (block.timestamp < maturityTime) {
        //     console.log("Request is not yet matured. Cannot solve.");
        //     console.log("Current time:", block.timestamp);
        //     console.log("Maturity time:", maturityTime);
        //     console.log("Time until maturity:", maturityTime - block.timestamp, "seconds");
        //     vm.stopBroadcast();
        //     return;
        // }
        
        // // Check if deadline has passed
        // uint256 deadlineTime = maturityTime + request.secondsToDeadline;
        // if (block.timestamp > deadlineTime) {
        //     console.log("Request deadline has passed. Cannot solve.");
        //     console.log("Current time:", block.timestamp);
        //     console.log("Deadline time:", deadlineTime);
        //     vm.stopBroadcast();
        //     return;
        // }
        
        // // Create an array with the single request to solve
        // BoringOnChainQueue.OnChainWithdraw[] memory requests = new BoringOnChainQueue.OnChainWithdraw[](1);
        // requests[0] = request;
        
        // // Check solver's asset balance before solving
        // ERC20 assetOut = ERC20(request.assetOut);
        // uint256 assetBalanceBefore = assetOut.balanceOf(user);
        // console.log("Solver's asset balance before:", assetBalanceBefore / 10**assetOut.decimals());
        
        // // Check if solver has enough assets
        // if (assetBalanceBefore < request.amountOfAssets) {
        //     console.log("Warning: Solver may not have enough assets to cover the withdrawal!");
        //     console.log("Required:", request.amountOfAssets / 10**assetOut.decimals());
        //     console.log("Available:", assetBalanceBefore / 10**assetOut.decimals());
        // }
        
        // // Approve assets for the solver if needed
        // if (assetOut.allowance(user, address(solver)) < request.amountOfAssets) {
        //     console.log("Approving assets for the solver...");
        //     assetOut.safeApprove(address(solver), type(uint256).max);
        // }
        
        // console.log("\nCalling boringRedeemSolve...");
        
        // // Following the pattern from testRedeemSolve in BoringQueue.t.sol
        // uint256 assetDelta = assetOut.balanceOf(user);
        // solver.boringRedeemSolve(requests, TELLER);
        // assetDelta = assetOut.balanceOf(user) - assetDelta;
        
        // console.log("\n=== Withdrawal Request Solved ===");
        // console.log("User received:", request.amountOfAssets / 10**assetOut.decimals(), "assets");
        // console.log("Solver's asset delta:", assetDelta / 10**assetOut.decimals(), "assets");
        
        // // Check solver's final balance
        // uint256 assetBalanceAfter = assetOut.balanceOf(user);
        // console.log("Solver's asset balance after:", assetBalanceAfter / 10**assetOut.decimals());
        
        vm.stopBroadcast();
    }
}
