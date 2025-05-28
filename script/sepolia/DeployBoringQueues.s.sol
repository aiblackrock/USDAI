// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.21;

import {MainnetAddresses} from "test/resources/MainnetAddresses.sol";
import {ERC20} from "@solmate/tokens/ERC20.sol";
import {Deployer} from "src/helper/Deployer.sol";
import {ContractNames} from "resources/ContractNames.sol";
import {GenericRateProvider} from "src/helper/GenericRateProvider.sol";
import {AddressToBytes32Lib} from "src/helper/AddressToBytes32Lib.sol";
import {AccountantWithRateProviders} from "src/base/Roles/AccountantWithRateProviders.sol";
import {RolesAuthority, Authority} from "@solmate/auth/authorities/RolesAuthority.sol";
import {BoringOnChainQueue} from "src/base/Roles/BoringQueue/BoringOnChainQueue.sol";
import {BoringOnChainQueueWithTracking} from "src/base/Roles/BoringQueue/BoringOnChainQueueWithTracking.sol";
import {BoringSolver} from "src/base/Roles/BoringQueue/BoringSolver.sol";
import {MerkleTreeHelper} from "test/resources/MerkleTreeHelper/MerkleTreeHelper.sol";

import "forge-std/Script.sol";
import "forge-std/StdJson.sol";
import {console} from "forge-std/console.sol";
/**
 *  source .env && forge script script/DeployBoringQueues.s.sol:DeployBoringQueuesScript --with-gas-price 3000000000 --broadcast --etherscan-api-key $ETHERSCAN_KEY --verify
 * @dev Optionally can change `--with-gas-price` to something more reasonable
 */
contract DeployBoringQueuesScript is Script, ContractNames, MerkleTreeHelper {
    using AddressToBytes32Lib for address;

    uint256 public privateKey;

    address public devOwner = 0x8Ab8aEEf444AeE718A275a8325795FE90CF162c4;
    address public canSolve = 0x8Ab8aEEf444AeE718A275a8325795FE90CF162c4;
    address public admin = 0x8Ab8aEEf444AeE718A275a8325795FE90CF162c4;
    address public superAdmin = 0x8Ab8aEEf444AeE718A275a8325795FE90CF162c4;
    address public globalOwner = 0x8Ab8aEEf444AeE718A275a8325795FE90CF162c4;

    // Contracts to deploy
    Deployer public deployer;

    // Roles
    uint8 public constant CAN_SOLVE_ROLE = 31;
    uint8 public constant ONLY_QUEUE_ROLE = 32;
    uint8 public constant ADMIN_ROLE = 33;
    uint8 public constant SUPER_ADMIN_ROLE = 34;

    function setUp() external {
        privateKey = vm.envUint("PRIVATE_KEY");
        vm.createSelectFork("sepolia");
        setSourceChainName(sepolia);
        deployer = Deployer(getAddress(sourceChain, "deployerAddress"));
    }

    function run() external {
        bytes memory creationCode;
        bytes memory constructorArgs;

        vm.startBroadcast(privateKey);

        creationCode = type(RolesAuthority).creationCode;
        constructorArgs = abi.encode(devOwner, Authority(address(0)));
        RolesAuthority rolesAuthority = RolesAuthority(
            deployer.deployContract(UsdaiBoringOnChainQueuesRolesAuthorityName, creationCode, constructorArgs, 0)
        );

        address[] memory assets = new address[](1);
        //============================== LiquidEth ===============================
        assets[0] = getAddress(sourceChain, "USDC");


        BoringOnChainQueue.WithdrawAsset[] memory assetsToSetup = new BoringOnChainQueue.WithdrawAsset[](2);
        assetsToSetup[0] = BoringOnChainQueue.WithdrawAsset({
            allowWithdraws: true, // not used in script.
            secondsToMaturity: 3 minutes,
            minimumSecondsToDeadline: 3 minutes,
            minDiscount: 1,
            maxDiscount: 10,
            minimumShares: 0
        });

        rolesAuthority.setUserRole(devOwner, SUPER_ADMIN_ROLE, true);

        _deployContracts(
            UsdaiVaultName,
            UsdaiVaultAccountantName,
            UsdaiVaultQueueName,
            UsdaiVaultQueueSolverName,
            rolesAuthority,
            assets,
            assetsToSetup
        );

        rolesAuthority.setUserRole(canSolve, CAN_SOLVE_ROLE, true);
        rolesAuthority.setUserRole(admin, ADMIN_ROLE, true);
        rolesAuthority.setUserRole(superAdmin, SUPER_ADMIN_ROLE, true);
        rolesAuthority.transferOwnership(globalOwner);

        vm.stopBroadcast();
    }

    function _deployContracts(
        string memory boringVaultName,
        string memory accountantName,
        string memory queueName,
        string memory solverName,
        RolesAuthority rolesAuthority,
        address[] memory assets,
        BoringOnChainQueue.WithdrawAsset[] memory assetsToSetup
    ) internal {
        bytes memory creationCode;
        bytes memory constructorArgs;

        address boringVault = deployer.getAddress(boringVaultName);
        address accountant = deployer.getAddress(accountantName);

        creationCode = type(BoringOnChainQueueWithTracking).creationCode;
        constructorArgs = abi.encode(devOwner, address(rolesAuthority), payable(boringVault), accountant, true);
        console.log("Deploying BoringOnChainQueueWithTracking with args:");
        console.log("deployer:", address(deployer));
        console.log("devOwner:", devOwner);
        console.log("rolesAuthority:", address(rolesAuthority));
        console.log("boringVault:", boringVault);
        console.log("accountant:", accountant);
        BoringOnChainQueueWithTracking queue =
            BoringOnChainQueueWithTracking(deployer.deployContract(queueName, creationCode, constructorArgs, 0));

        creationCode = type(BoringSolver).creationCode;
        constructorArgs = abi.encode(devOwner, address(rolesAuthority), address(queue));
        address solver = deployer.deployContract(solverName, creationCode, constructorArgs, 0);

        rolesAuthority.setRoleCapability(
            SUPER_ADMIN_ROLE, address(queue), BoringOnChainQueue.updateWithdrawAsset.selector, true
        );

        // Setup withdraw assets.
        for (uint256 i; i < assets.length; ++i) {
            queue.updateWithdrawAsset(
                assets[i],
                assetsToSetup[i].secondsToMaturity,
                assetsToSetup[i].minimumSecondsToDeadline,
                assetsToSetup[i].minDiscount,
                assetsToSetup[i].maxDiscount,
                assetsToSetup[i].minimumShares
            );
        }

        // Setup RolesAuthority.

        // Public functions.
        rolesAuthority.setPublicCapability(address(queue), BoringOnChainQueue.requestOnChainWithdraw.selector, true);
        rolesAuthority.setPublicCapability(
            address(queue), BoringOnChainQueue.requestOnChainWithdrawWithPermit.selector, true
        );
        rolesAuthority.setPublicCapability(address(queue), BoringOnChainQueue.cancelOnChainWithdraw.selector, true);
        rolesAuthority.setPublicCapability(address(queue), BoringOnChainQueue.replaceOnChainWithdraw.selector, true);
        rolesAuthority.setPublicCapability(solver, BoringSolver.boringRedeemSelfSolve.selector, true);
        rolesAuthority.setPublicCapability(address(queue), BoringOnChainQueueWithTracking.cancelOnChainWithdrawUsingRequestId.selector, true);
        /// @notice By default the self solve functions are not made public.

        // CAN_SOLVE_ROLE
        // rolesAuthority.setRoleCapability(
        //     CAN_SOLVE_ROLE, solver, BoringOnChainQueue.solveOnChainWithdraws.selector, true
        // );
        rolesAuthority.setRoleCapability(
            CAN_SOLVE_ROLE, address(queue), BoringOnChainQueue.solveOnChainWithdraws.selector, true
        );
        rolesAuthority.setRoleCapability(CAN_SOLVE_ROLE, solver, BoringSolver.boringRedeemSolve.selector, true);
        rolesAuthority.setRoleCapability(CAN_SOLVE_ROLE, solver, BoringSolver.boringRedeemMintSolve.selector, true);

        // ONLY_QUEUE_ROLE
        rolesAuthority.setRoleCapability(ONLY_QUEUE_ROLE, solver, BoringSolver.boringSolve.selector, true);

        // ADMIN_ROLE
        rolesAuthority.setRoleCapability(
            ADMIN_ROLE, address(queue), BoringOnChainQueue.stopWithdrawsInAsset.selector, true
        );
        rolesAuthority.setRoleCapability(
            ADMIN_ROLE, address(queue), BoringOnChainQueue.cancelUserWithdraws.selector, true
        );
        rolesAuthority.setRoleCapability(ADMIN_ROLE, address(queue), BoringOnChainQueue.pause.selector, true);

        // SUPER_ADMIN_ROLE
        rolesAuthority.setRoleCapability(
            SUPER_ADMIN_ROLE, address(queue), BoringOnChainQueue.updateWithdrawAsset.selector, true
        );
        rolesAuthority.setRoleCapability(SUPER_ADMIN_ROLE, address(queue), BoringOnChainQueue.pause.selector, true);
        rolesAuthority.setRoleCapability(SUPER_ADMIN_ROLE, address(queue), BoringOnChainQueue.unpause.selector, true);
        rolesAuthority.setRoleCapability(
            SUPER_ADMIN_ROLE, address(queue), BoringOnChainQueue.stopWithdrawsInAsset.selector, true
        );
        rolesAuthority.setRoleCapability(
            SUPER_ADMIN_ROLE, address(queue), BoringOnChainQueue.rescueTokens.selector, true
        );
        rolesAuthority.setRoleCapability(SUPER_ADMIN_ROLE, solver, BoringOnChainQueue.rescueTokens.selector, true);

        // Give Queue the OnlyQueue role.
        rolesAuthority.setUserRole(address(queue), ONLY_QUEUE_ROLE, true);
        rolesAuthority.setUserRole(solver, CAN_SOLVE_ROLE, true);

        // Transfer ownership.
        queue.transferOwnership(globalOwner);
        BoringSolver(solver).transferOwnership(globalOwner);
    }
}
