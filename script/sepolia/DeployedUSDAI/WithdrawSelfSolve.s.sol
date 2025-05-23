// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.21;

import "forge-std/Script.sol";
import {ERC20} from "@solmate/tokens/ERC20.sol";
import {BoringVault} from "src/base/BoringVault.sol";
import {TellerWithMultiAssetSupport} from "src/base/Roles/TellerWithMultiAssetSupport.sol";
import {ArcticArchitectureLens} from "src/helper/ArcticArchitectureLens.sol";
import {AccountantWithRateProviders} from "src/base/Roles/AccountantWithRateProviders.sol";
import {SepoliaAddresses} from "test/resources/SepoliaAddresses.sol";
import {BoringOnChainQueue} from "src/base/Roles/BoringQueue/BoringOnChainQueue.sol";
import {BoringOnChainQueueWithTracking} from "src/base/Roles/BoringQueue/BoringOnChainQueueWithTracking.sol";
import {Deployer} from "src/helper/Deployer.sol";
import {ContractNames} from "resources/ContractNames.sol";
import {MerkleTreeHelper} from "test/resources/MerkleTreeHelper/MerkleTreeHelper.sol";
import {BoringSolver} from "src/base/Roles/BoringQueue/BoringSolver.sol";

/**
 * @title USDAI Withdraw Integration Test
 * @notice This script demonstrates how to withdraw USDC and ASTR from the USDAI vault on Sepolia using the BoringQueue
 * @dev Run with: forge script script/DeployedUSDAI/Sepolia/Withdraw.s.sol --rpc-url $SEPOLIA_RPC_URL
 */
contract USDAISelfSolveScript is Script, SepoliaAddresses, ContractNames, MerkleTreeHelper {
    // Contract instances
    Deployer public deployer;
    BoringVault vault;
    TellerWithMultiAssetSupport teller;
    ArcticArchitectureLens lens;
    AccountantWithRateProviders accountant;
    BoringOnChainQueueWithTracking queue;
    BoringSolver solver;

    // User's initial share balance
    uint256 initialShares;
    uint256 withdrawShares;

    function setUp() public {
        vm.createSelectFork("sepolia");
        setSourceChainName("sepolia");
        deployer = Deployer(getAddress(sourceChain, "deployerAddress"));
        
        // Initialize contract instances
        vault = BoringVault(payable(deployer.getAddress(UsdaiVaultName)));
        teller = TellerWithMultiAssetSupport(deployer.getAddress(UsdaiVaultTellerName));
        lens = ArcticArchitectureLens(deployer.getAddress(UsdaiArcticArchitectureLensName));
        accountant = AccountantWithRateProviders(deployer.getAddress(UsdaiVaultAccountantName));
        queue = BoringOnChainQueueWithTracking(deployer.getAddress(UsdaiVaultQueueName));
        solver = BoringSolver(deployer.getAddress(UsdaiVaultQueueSolverName));
    }

    function run() public {
        uint256 privateKey = vm.envUint("TESTER"); // not the owner
        address user = vm.addr(privateKey);
        vm.startBroadcast(privateKey);

        // uint256 USDC_DEPOSIT_AMOUNT = 3 * 1e6; // 3 USDC (6 decimals)
        // withdrawShares = 1 * 1e6;
        // depositUSDC(user, USDC_DEPOSIT_AMOUNT);
        // createWithdrawalRequest(user, withdrawShares);

        // Self-solve the withdrawal
        selfSolveWithdrawal(user);

        vm.stopBroadcast();
    }

    /**
     * @notice Deposits USDC into the vault
     * @param user The address of the user making the deposit
     * @param depositAmount The amount of USDC to deposit
     */
    function depositUSDC(address user, uint256 depositAmount) internal {
        if (USDC.balanceOf(user) >= depositAmount) {
            console.log("\n=== Depositing USDC ===");
            
            // Calculate expected shares
            uint256 expectedUsdcShares = lens.previewDeposit(
                USDC,
                depositAmount,
                vault,
                accountant
            );
            console.log("Expected shares from USDC deposit:", expectedUsdcShares / 1e6);
            
            // Log allowance before approval
            console.log("USDC allowance before approval:", USDC.allowance(user, address(teller)));
            
            // Approve USDC for deposit
            USDC.approve(address(vault), depositAmount);
            console.log("USDC approved for deposit");
            
            // Log allowance after approval
            console.log("USDC allowance after approval:", USDC.allowance(user, address(vault)));
            
            // Deposit USDC
            uint256 sharesBefore = vault.balanceOf(user);
            teller.deposit(USDC, depositAmount, 0);
            uint256 sharesAfter = vault.balanceOf(user);
            
            console.log("Actual shares received:", (sharesAfter - sharesBefore) / 1e6);
        } else {
            console.log("Insufficient USDC balance for deposit");
        }
    }

    /**
     * @notice Creates a withdrawal request for the user
     * @param user The address of the user making the withdrawal request
     * @param sharesToWithdraw The amount of shares to withdraw
     */
    function createWithdrawalRequest(address user, uint256 sharesToWithdraw) internal {
        initialShares = vault.balanceOf(user);
        
        // Check if user has shares to withdraw
        if (initialShares > sharesToWithdraw) {
            vault.approve(address(queue), sharesToWithdraw);
            
            // Set discount and deadline parameters
            uint16 discount = 3; // 3 basis points discount (0.03%)
            uint24 secondsToDeadline = 10 minutes;
            
            // Request withdrawal through queue
            bytes32 requestId = queue.requestOnChainWithdraw(
                    address(USDC),
                    uint128(sharesToWithdraw),
                    discount,
                    secondsToDeadline
                );
  
            console.log("Withdrawal request created with ID:", vm.toString(requestId));
        } else {
            console.log("No shares available for withdrawal");
        }
    }

    /**
     * @notice Self-solves a user's withdrawal request
     * @param user The address of the user who wants to self-solve their withdrawal
     */
    function selfSolveWithdrawal(address user) internal {
        console.log("\n=== Self-solving Withdrawal Request ===");

        // Get all withdrawal requests
        (bytes32[] memory requestIds, BoringOnChainQueue.OnChainWithdraw[] memory requests) = queue.getWithdrawRequests();

        if (requestIds.length == 0) {
            console.log("No withdrawal requests found!");
            return;
        }

        // Find the user's request
        BoringOnChainQueue.OnChainWithdraw memory userRequest;
        bool found = false;

        for (uint256 i = 0; i < requests.length; i++) {
            console.log("Request user:", requests[i].user);
            if (requests[i].user == user) {
                userRequest = requests[i];
                found = true;
                break;
            }
        }

        if (!found) {
            console.log("No withdrawal request found for user");
            return;
        }

        solver.boringRedeemSelfSolve(userRequest, address(teller));

        console.log("Withdrawal request self-solved successfully!");
    }
}