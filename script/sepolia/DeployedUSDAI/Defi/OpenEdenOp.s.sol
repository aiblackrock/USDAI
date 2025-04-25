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
1. the boring vault need to by listed im OpenEden kyc list
2. there is min supply and redeem amount limit in OpenEden
example tx: https://sepolia.etherscan.io/tx/0xc83ec3d505fa53aaedc4c12da46da740f1c89beab1fe2bf5355c13f7e1eff499
*/

contract OpenEdenOp is Script, SepoliaAddresses, MerkleTreeHelper, ContractNames {
    using SafeTransferLib for ERC20;
    using FixedPointMathLib for uint256;
    using Address for address;

    Deployer public deployer;
    BoringVault vault;
    ManagerWithMerkleVerification manager;
    address USDOExpress = 0xD65eF7fF5e7B3DBCCD07F6637Dc47101311ecEe6;
    address TEST_USDC = 0x7069C635d6fCd1C3D0cd9b563CDC6373e06052ee;

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
        setAddress(true, sepolia, "rawDataDecoderAndSanitizer", deployer.getAddress(UsdaiSepoliaOpenEdenDecoderAndSanitizerName));

        // 1. Create merkle tree leaves for allowed actions
        ManageLeaf[] memory leafs = new ManageLeaf[](128);
        
        // only support instant mint with USDC for now
        _addOpenEdenLeafs(leafs);

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
        targets[1] = USDOExpress;
        targets[2] = USDOExpress;

        bytes[] memory targetData = new bytes[](opsAmt);
        uint256 USDCSupplyAmount = 5000e6;
        uint256 USDOWithdrawAmount = 4000e18;

        targetData[0] = abi.encodeWithSignature("approve(address,uint256)", USDOExpress, type(uint256).max);
        targetData[1] = abi.encodeWithSignature("instantMint(address,address,uint256)",TEST_USDC,deployer.getAddress(UsdaiSepoliaVaultName),USDCSupplyAmount);
        targetData[2] = abi.encodeWithSignature("instantRedeem(address,uint256)",deployer.getAddress(UsdaiSepoliaVaultName),USDOWithdrawAmount);

        address[] memory decodersAndSanitizers = new address[](opsAmt);  
        decodersAndSanitizers[0] = deployer.getAddress(UsdaiSepoliaOpenEdenDecoderAndSanitizerName);
        decodersAndSanitizers[1] = deployer.getAddress(UsdaiSepoliaOpenEdenDecoderAndSanitizerName);
        decodersAndSanitizers[2] = deployer.getAddress(UsdaiSepoliaOpenEdenDecoderAndSanitizerName);

        uint256[] memory values = new uint256[](opsAmt);

        // extra
        string memory filePath = "./leafs/USDOLeafs.json";
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
