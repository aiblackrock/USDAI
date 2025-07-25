// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.21;
import "forge-std/Script.sol";
import {PlumeAddresses} from "test/resources/PlumeAddresses.sol";
import {Address} from "@openzeppelin/contracts/utils/Address.sol";
import {MerkleProofLib} from "@solmate/utils/MerkleProofLib.sol";
import {BoringVault} from "src/base/BoringVault.sol";
import {ManagerWithMerkleVerification} from "src/base/Roles/ManagerWithMerkleVerification.sol";
import {SafeTransferLib} from "@solmate/utils/SafeTransferLib.sol";
import {FixedPointMathLib} from "@solmate/utils/FixedPointMathLib.sol";
import {ERC20} from "@solmate/tokens/ERC20.sol";
import {BaseDecoderAndSanitizer} from "src/base/DecodersAndSanitizers/BaseDecoderAndSanitizer.sol";
import {DecoderCustomTypes} from "src/interfaces/DecoderCustomTypes.sol";
import {MerkleTreeHelper} from "test/resources/MerkleTreeHelper/MerkleTreeHelper.sol";
import {ContractNames} from "resources/ContractNames.sol";
import {Deployer} from "src/helper/Deployer.sol";
import {console} from "forge-std/console.sol";

contract BaseOp is Script, PlumeAddresses, MerkleTreeHelper, ContractNames {
    using SafeTransferLib for ERC20;
    using FixedPointMathLib for uint256;
    using Address for address;

    Deployer public deployer;
    BoringVault vault;
    ManagerWithMerkleVerification manager;

    function setUp() external {
        vm.createSelectFork("plume");
        setSourceChainName("plume");
        
        deployer = Deployer(getAddress(sourceChain, "deployerAddress"));
        vault = BoringVault(payable(deployer.getAddress(UsdaiVaultName)));
        manager = ManagerWithMerkleVerification(deployer.getAddress(UsdaiVaultManagerName));
    }

    function run() public {
        uint256 privateKey = vm.envUint("PRIVATE_KEY");
        address auth = vm.addr(privateKey);
        
        vm.startBroadcast(privateKey);
        
        setAddress(true, plume, "boringVault", deployer.getAddress(UsdaiVaultName));
        setAddress(true, plume, "managerAddress", deployer.getAddress(UsdaiVaultManagerName));
        setAddress(true, plume, "accountantAddress", deployer.getAddress(UsdaiVaultAccountantName));
        setAddress(true, plume, "rawDataDecoderAndSanitizer", deployer.getAddress(UsdaiBaseDecoderAndSanitizerName));

        // 1. Create merkle tree leaves for allowed actions
        ManageLeaf[] memory leafs = new ManageLeaf[](128);
        
        // Add approval and transfer leafs for USDC only
        ERC20 usdcToken = ERC20(getAddress(sourceChain, "PUSD"));
        
        _addApprovalLeafs(leafs, usdcToken, auth);
        _addTransferLeafs(leafs, usdcToken, auth);

        // 2. Generate the merkle tree and get the root
        bytes32[][] memory manageTree = _generateMerkleTree(leafs);

        // 3. Generate proofs for the actions you want to execute
        uint256 opsAmt = 2;
        ManageLeaf[] memory manageLeafs = new ManageLeaf[](opsAmt);
        manageLeafs[0] = leafs[0]; // USDC approval
        manageLeafs[1] = leafs[1]; // USDC transfer

        bytes32[][] memory manageProofs = _getProofsUsingTree(manageLeafs, manageTree);

        // 4. Prepare the action data - both operations target USDC token
        address[] memory targets = new address[](opsAmt);
        targets[0] = getAddress(sourceChain, "PUSD"); // approve
        targets[1] = getAddress(sourceChain, "PUSD"); // transfer

        bytes[] memory targetData = new bytes[](opsAmt);
        targetData[0] = abi.encodeWithSignature("approve(address,uint256)", auth, type(uint256).max);
        targetData[1] = abi.encodeWithSignature("transfer(address,uint256)", auth, 1e6);

        address[] memory decodersAndSanitizers = new address[](opsAmt);  
        decodersAndSanitizers[0] = deployer.getAddress(UsdaiBaseDecoderAndSanitizerName);
        decodersAndSanitizers[1] = deployer.getAddress(UsdaiBaseDecoderAndSanitizerName);

        uint256[] memory values = new uint256[](opsAmt);

        // extra
        string memory filePath = "./leafs/BaseLeafs.json";
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
