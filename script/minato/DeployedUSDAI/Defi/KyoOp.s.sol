// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.21;
import "forge-std/Script.sol";
import {MinatoAddresses} from "test/resources/MinatoAddresses.sol";
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

contract KyoOp is Script, MinatoAddresses, MerkleTreeHelper, ContractNames {
    using SafeTransferLib for ERC20;
    using FixedPointMathLib for uint256;
    using Address for address;

    Deployer public deployer;
    BoringVault vault;
    ManagerWithMerkleVerification manager;
    address kyoRouter = 0xe54Ae3B49438dfEf203fC79858270c35B834905C;

    function setUp() external {
        vm.createSelectFork("minato");
        setSourceChainName("minato");
        
        deployer = Deployer(getAddress(sourceChain, "deployerAddress"));
        vault = BoringVault(payable(deployer.getAddress(UsdaiVaultName)));
        manager = ManagerWithMerkleVerification(deployer.getAddress(UsdaiVaultManagerName));
    }

    function run() public {
        uint256 privateKey = vm.envUint("PRIVATE_KEY");
        address auth = vm.addr(privateKey);
        
        vm.startBroadcast(privateKey);
        
        setAddress(true, minato, "boringVault", deployer.getAddress(UsdaiVaultName));
        setAddress(true, minato, "managerAddress", deployer.getAddress(UsdaiVaultManagerName));
        setAddress(true, minato, "accountantAddress", deployer.getAddress(UsdaiVaultAccountantName));
        setAddress(true, minato, "rawDataDecoderAndSanitizer", deployer.getAddress(UsdaiKyoDecoderAndSanitizerName));

        // 1. Create merkle tree leaves for allowed actions
        ManageLeaf[] memory leafs = new ManageLeaf[](128);
        
        // only support instant mint with USDC for now
        _addKyoLeafs(leafs);

        // 2. Generate the merkle tree and get the root
        bytes32[][] memory manageTree = _generateMerkleTree(leafs);

        // 3. Generate proofs for the actions you want to execute. Check USDAILeafs.json for the leafs operation order
        // Approve USDC
        // exactInputSingle
        uint256 opsAmt = 2;
        ManageLeaf[] memory manageLeafs = new ManageLeaf[](opsAmt);
        manageLeafs[0] = leafs[0];
        manageLeafs[1] = leafs[1];

        bytes32[][] memory manageProofs = _getProofsUsingTree(manageLeafs, manageTree);

        // 4. Prepare the action data
        address[] memory targets = new address[](opsAmt);
        targets[0] = getAddress(sourceChain, "USDC");
        targets[1] = kyoRouter;

        bytes[] memory targetData = new bytes[](opsAmt);
        uint256 USDCSupplyAmount = 1e6;
        address tokenOut = 0xA5D6513082EF1F157A33A066293309E74A8aF6Df;

        targetData[0] = abi.encodeWithSignature("approve(address,uint256)", kyoRouter, type(uint256).max);
        targetData[1] = abi.encodeWithSignature("exactInputSingle((address,address,uint24,address,uint256,uint256,uint256,uint160))",
            getAddress(sourceChain, "USDC"),        // tokenIn
            tokenOut,                               // tokenOut
            10000,                                  // fee (0.1% = 1000, 1% = 10000)
            deployer.getAddress(UsdaiVaultName),    // recipient
            block.timestamp + 1 hours,              // deadline
            USDCSupplyAmount,                       // amountIn
            0,                                      // amountOutMinimum
            0);    

        address[] memory decodersAndSanitizers = new address[](opsAmt);  
        decodersAndSanitizers[0] = deployer.getAddress(UsdaiKyoDecoderAndSanitizerName);
        decodersAndSanitizers[1] = deployer.getAddress(UsdaiKyoDecoderAndSanitizerName);

        uint256[] memory values = new uint256[](opsAmt);

        // extra
        string memory filePath = "./leafs/KyoLeafs.json";
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
