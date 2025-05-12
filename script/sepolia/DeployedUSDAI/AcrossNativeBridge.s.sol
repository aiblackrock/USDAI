// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.21;

import "forge-std/Script.sol";
import {ERC20} from "@solmate/tokens/ERC20.sol";
import { ILayerZeroEndpointV2 } from "@layerzerolabs/lz-evm-protocol-v2/contracts/interfaces/ILayerZeroEndpointV2.sol";
import {BoringVault} from "src/base/BoringVault.sol";
import {AccountantWithRateProviders} from "src/base/Roles/AccountantWithRateProviders.sol";
import {SepoliaAddresses} from "test/resources/SepoliaAddresses.sol";
import {Deployer} from "src/helper/Deployer.sol";
import {ContractNames} from "resources/ContractNames.sol";
import {MerkleTreeHelper} from "test/resources/MerkleTreeHelper/MerkleTreeHelper.sol";
import {RolesAuthority, Authority} from "@solmate/auth/authorities/RolesAuthority.sol";
import {ManagerWithMerkleVerification} from "src/base/Roles/ManagerWithMerkleVerification.sol";
import {console} from "forge-std/console.sol";

/*
Try to update the foundry.toml if encounter the stack too deep error
 */

contract AcrossNativeBridgeScript is Script, SepoliaAddresses, ContractNames, MerkleTreeHelper {
    Deployer public deployer;
    BoringVault vault;
    AccountantWithRateProviders accountant;
    RolesAuthority rolesAuthority;
    ManagerWithMerkleVerification manager;

    address across = 0x5ef6C01E11889d86803e0B23e3cB3F9E9d97B662;
    address baseSepoliaUSDC = 0x036CbD53842c5426634e7929541eC2318f3dCF7e;
    uint256 destinationChainId = 84532; // baseSepolia chain id

    uint256 public sharesToBridge = 1e4;

    function setUp() public {
        vm.createSelectFork("sepolia");
        setSourceChainName("sepolia");
        deployer = Deployer(getAddress(sourceChain, "deployerAddress"));
        
        vault = BoringVault(payable(deployer.getAddress(UsdaiVaultName)));
        accountant = AccountantWithRateProviders(deployer.getAddress(UsdaiVaultAccountantName));
        manager = ManagerWithMerkleVerification(deployer.getAddress(UsdaiVaultManagerName));
    }

    function run() public {
        uint256 privateKey = vm.envUint("PRIVATE_KEY");
        address auth = vm.addr(privateKey);
        vm.startBroadcast(privateKey);
        
        setAddress(true, sepolia, "boringVault", deployer.getAddress(UsdaiVaultName));
        setAddress(true, sepolia, "managerAddress", deployer.getAddress(UsdaiVaultManagerName));
        setAddress(true, sepolia, "accountantAddress", deployer.getAddress(UsdaiVaultAccountantName));
        setAddress(true, sepolia, "rawDataDecoderAndSanitizer", deployer.getAddress(UsdaiAcrossDecoderAndSanitizerName));

        // 1. Create merkle tree leaves for allowed actions
        ManageLeaf[] memory leafs = new ManageLeaf[](128);

        _addAcrossLeafs(leafs);

       // 2. Generate the merkle tree and get the root
        bytes32[][] memory manageTree = _generateMerkleTree(leafs);

        // 3. Generate proofs for the actions you want to execute. Check AcrossLeafs.json for the leafs operation order
        // Approve USDC
        // depositV3
        uint256 opsAmt = 2;
        ManageLeaf[] memory manageLeafs = new ManageLeaf[](opsAmt);
        manageLeafs[0] = leafs[0];
        manageLeafs[1] = leafs[1];

        bytes32[][] memory manageProofs = _getProofsUsingTree(manageLeafs, manageTree);

        // 4. Prepare the action data
        address[] memory targets = new address[](opsAmt);
        targets[0] = getAddress(sourceChain, "USDC");
        targets[1] = across;

        bytes[] memory targetData = new bytes[](opsAmt);

        targetData[0] = abi.encodeWithSignature("approve(address,uint256)", across, type(uint256).max);

        targetData[1] = abi.encodeWithSignature(
            "depositV3(address,address,address,address,uint256,uint256,uint256,address,uint32,uint32,uint32,bytes)",
            deployer.getAddress(UsdaiVaultName),
            auth,
            getAddress(sourceChain, "USDC"),
            baseSepoliaUSDC,
            sharesToBridge,
            sharesToBridge/2,
            destinationChainId,
            address(0),
            uint32(block.timestamp),
            uint32(block.timestamp + 1 hours),
            0,
            abi.encode(bytes(""))
        );

        address[] memory decodersAndSanitizers = new address[](opsAmt);  
        decodersAndSanitizers[0] = deployer.getAddress(UsdaiAcrossDecoderAndSanitizerName);
        decodersAndSanitizers[1] = deployer.getAddress(UsdaiAcrossDecoderAndSanitizerName);

        uint256[] memory values = new uint256[](opsAmt);

        // extra
        string memory filePath = "./leafs/AcrossLeafs.json";
        bytes32 merkleRoot = manageTree[manageTree.length - 1][0];

        _generateLeafs(filePath, leafs, merkleRoot, manageTree);

        manager.setManageRoot(auth, merkleRoot);

        // 5. Execute the actions through the manager
        manager.manageVaultWithMerkleVerification(
            manageProofs,
            decodersAndSanitizers,
            targets,
            targetData,
            values
        );

        vm.stopBroadcast();
    }
}