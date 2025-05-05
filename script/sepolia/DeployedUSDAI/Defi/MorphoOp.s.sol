// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.21;
import "forge-std/Script.sol";
import {SepoliaAddresses} from "test/resources/SepoliaAddresses.sol";
import {Address} from "@openzeppelin/contracts/utils/Address.sol";
import {MerkleProofLib} from "@solmate/utils/MerkleProofLib.sol";
import {BoringVault} from "src/base/BoringVault.sol";
import {ManagerWithMerkleVerification} from "src/base/Roles/ManagerWithMerkleVerification.sol";
import {SafeTransferLib} from "@solmate/utils/SafeTransferLib.sol";
import {FixedPointMathLib} from "@solmate/utils/FixedPointMathLib.sol";
import {ERC20} from "@solmate/tokens/ERC20.sol";
import {MerkleTreeHelper} from "test/resources/MerkleTreeHelper/MerkleTreeHelper.sol";
import {ContractNames} from "resources/ContractNames.sol";
import {Deployer} from "src/helper/Deployer.sol";
import {console} from "forge-std/console.sol";

/*
notice possible issues:
1. sepolia operation is totally diff from mainnet, need to rewrite all logic for mainnet
example tx: https://sepolia.etherscan.io/tx/0x563c1e3daaeb60ac16d203040f2aeb9c15b25dc96f8c2be071b36af9625e6a87
*/

contract MorphoOp is Script, SepoliaAddresses, MerkleTreeHelper, ContractNames {
    using SafeTransferLib for ERC20;
    using FixedPointMathLib for uint256;
    using Address for address;

    Deployer public deployer;
    BoringVault vault;
    ManagerWithMerkleVerification manager;
    address morpho = 0x2Ed0a90f247cd7fBe3a6a246b4D9b89a257F7348;
    address TEST_USDC = 0x1c7D4B196Cb0C7B01d743Fbc6116a902379C7238;

    function setUp() external {
        vm.createSelectFork("sepolia");
        setSourceChainName("sepolia");
        
        deployer = Deployer(getAddress(sourceChain, "deployerAddress"));
        vault = BoringVault(payable(deployer.getAddress(UsdaiSepoliaVaultName)));
        manager = ManagerWithMerkleVerification(deployer.getAddress(UsdaiSepoliaVaultManagerName));
    }

    function run() public {
        uint256 privateKey = vm.envUint("PRIVATE_KEY");
        address auth = vm.addr(privateKey);
        
        vm.startBroadcast(privateKey);
        
        setAddress(true, sepolia, "boringVault", deployer.getAddress(UsdaiSepoliaVaultName));
        setAddress(true, sepolia, "managerAddress", deployer.getAddress(UsdaiSepoliaVaultManagerName));
        setAddress(true, sepolia, "accountantAddress", deployer.getAddress(UsdaiSepoliaVaultAccountantName));
        setAddress(true, sepolia, "rawDataDecoderAndSanitizer", deployer.getAddress(UsdaiSepoliaMorphoDecoderAndSanitizerName));

        // 1. Create merkle tree leaves for allowed actions
        ManageLeaf[] memory leafs = new ManageLeaf[](128);
        
        // only support instant mint with USDC for now
        _addMorphoLeafs(leafs);

        // 2. Generate the merkle tree and get the root
        bytes32[][] memory manageTree = _generateMerkleTree(leafs);

        // 3. Generate proofs for the actions you want to execute. Check USDAILeafs.json for the leafs operation order
        // Approve USDC
        // Instant mint
        // Instant redeem
        uint256 opsAmt = 3;
        ManageLeaf[] memory manageLeafs = new ManageLeaf[](opsAmt);
        manageLeafs[0] = leafs[0];
        manageLeafs[1] = leafs[1];
        manageLeafs[2] = leafs[2];

        bytes32[][] memory manageProofs = _getProofsUsingTree(manageLeafs, manageTree);

        // 4. Prepare the action data
        address[] memory targets = new address[](opsAmt);
        targets[0] = TEST_USDC;//getAddress(sourceChain, "USDC");
        targets[1] = morpho;
        targets[2] = morpho;

        bytes[] memory targetData = new bytes[](opsAmt);
        uint256 adapterId = 2;
        uint256 USDCSupplyAmount = 1e6;

        targetData[0] = abi.encodeWithSignature("approve(address,uint256)", morpho, type(uint256).max);
        targetData[1] = abi.encodeWithSignature("deposit(uint256,uint256)",adapterId,USDCSupplyAmount);
        targetData[2] = abi.encodeWithSignature("withdraw(uint256)",adapterId);

        address[] memory decodersAndSanitizers = new address[](opsAmt);  
        decodersAndSanitizers[0] = deployer.getAddress(UsdaiSepoliaMorphoDecoderAndSanitizerName);
        decodersAndSanitizers[1] = deployer.getAddress(UsdaiSepoliaMorphoDecoderAndSanitizerName);
        decodersAndSanitizers[2] = deployer.getAddress(UsdaiSepoliaMorphoDecoderAndSanitizerName);

        uint256[] memory values = new uint256[](opsAmt);

        // extra
        string memory filePath = "./leafs/MorphoLeafs.json";
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
