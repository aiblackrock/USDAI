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
import {SakeDecoderAndSanitizer} from "src/base/DecodersAndSanitizers/Protocols/SakeDecoderAndSanitizer.sol";
import {DecoderCustomTypes} from "src/interfaces/DecoderCustomTypes.sol";
import {MerkleTreeHelper} from "test/resources/MerkleTreeHelper/MerkleTreeHelper.sol";
import {ContractNames} from "resources/ContractNames.sol";
import {Deployer} from "src/helper/Deployer.sol";
import {console} from "forge-std/console.sol";

contract SakeOp is Script, MinatoAddresses, MerkleTreeHelper, ContractNames {
    using SafeTransferLib for ERC20;
    using FixedPointMathLib for uint256;
    using Address for address;

    Deployer public deployer;
    BoringVault vault;
    ManagerWithMerkleVerification manager;

    function setUp() external {
        vm.createSelectFork("minato");
        setSourceChainName("minato");
        
        deployer = Deployer(getAddress(sourceChain, "deployerAddress"));
        vault = BoringVault(payable(deployer.getAddress(UsdaiMinatoVaultName)));
        manager = ManagerWithMerkleVerification(deployer.getAddress(UsdaiMinatoVaultManagerName));
    }

    function run() public {
        uint256 privateKey = vm.envUint("PRIVATE_KEY");
        address auth = vm.addr(privateKey);
        
        vm.startBroadcast(privateKey);
        
        setAddress(true, minato, "boringVault", deployer.getAddress(UsdaiMinatoVaultName));
        setAddress(true, minato, "managerAddress", deployer.getAddress(UsdaiMinatoVaultManagerName));
        setAddress(true, minato, "rawDataDecoderAndSanitizer", deployer.getAddress(UsdaiMinatoVaultDecoderAndSanitizerName));
                
        console.log("Starting SakeOp script execution");

        // 1. Create merkle tree leaves for allowed actions
        ManageLeaf[] memory leafs = new ManageLeaf[](128);
        uint256 supplyAssetAmt = 2;
        uint256 borrowAssetAmt = 2;
        uint256 claimAssetAmt = 0;
        ERC20[] memory supplyAssets = new ERC20[](supplyAssetAmt);
        supplyAssets[0] = getERC20(sourceChain, "USDC");
        supplyAssets[1] = getERC20(sourceChain, "ASTR");
        ERC20[] memory borrowAssets = new ERC20[](borrowAssetAmt);
        borrowAssets[0] = getERC20(sourceChain, "USDC");
        borrowAssets[1] = getERC20(sourceChain, "ASTR");
        _addAaveV3Leafs(leafs, supplyAssets, borrowAssets, new ERC20[](claimAssetAmt));

        // 2. Generate the merkle tree and get the root
        bytes32[][] memory manageTree = _generateMerkleTree(leafs);

        // 3. Generate proofs for the actions you want to execute. Check USDAILeafs.json for the leafs operation order
        // Approve USDC
        // Approve ASTR
        // Supply USDC
        // Supply ASTR
        // Borrow ASTR
        // Repay ASTR
        // Withdraw ASTR
        uint256 opsAmt = 7;
        ManageLeaf[] memory manageLeafs = new ManageLeaf[](opsAmt);
        manageLeafs[0] = leafs[0];
        manageLeafs[1] = leafs[1];
        manageLeafs[2] = leafs[2];
        manageLeafs[3] = leafs[3];
        manageLeafs[4] = leafs[7];
        manageLeafs[5] = leafs[9];
        manageLeafs[6] = leafs[5];
        bytes32[][] memory manageProofs = _getProofsUsingTree(manageLeafs, manageTree);

        // 4. Prepare the action data
        address[] memory targets = new address[](opsAmt);
        targets[0] = getAddress(sourceChain, "USDC");
        targets[1] = getAddress(sourceChain, "ASTR");
        targets[2] = getAddress(sourceChain, "v3Pool");
        targets[3] = getAddress(sourceChain, "v3Pool");
        targets[4] = getAddress(sourceChain, "v3Pool");
        targets[5] = getAddress(sourceChain, "v3Pool");
        targets[6] = getAddress(sourceChain, "v3Pool");

        bytes[] memory targetData = new bytes[](opsAmt);
        uint256 USDCSupplyAmount = 4e6;
        uint256 ASTRSupplyAmount = 4e18;
        uint256 ASTRBorrowAmount = 3e18;
        uint256 ASTRRepayAmount = 2e18;
        uint256 ASTRWithdrawAmount = 1e18;
        uint256 interestRateMode = 2;
        targetData[0] = abi.encodeWithSignature("approve(address,uint256)", getAddress(sourceChain, "v3Pool"), type(uint256).max);
        targetData[1] = abi.encodeWithSignature("approve(address,uint256)", getAddress(sourceChain, "v3Pool"), type(uint256).max);
        targetData[2] = abi.encodeWithSignature("supply(address,uint256,address,uint16)", getAddress(sourceChain, "USDC"), USDCSupplyAmount, deployer.getAddress(UsdaiMinatoVaultName), 0);
        targetData[3] = abi.encodeWithSignature("supply(address,uint256,address,uint16)", getAddress(sourceChain, "ASTR"), ASTRSupplyAmount, deployer.getAddress(UsdaiMinatoVaultName), 0);
        targetData[4] = abi.encodeWithSignature("borrow(address,uint256,uint256,uint16,address)", getAddress(sourceChain, "ASTR"), ASTRBorrowAmount, interestRateMode, 0, deployer.getAddress(UsdaiMinatoVaultName));
        targetData[5] = abi.encodeWithSignature("repay(address,uint256,uint256,address)", getAddress(sourceChain, "ASTR"), ASTRRepayAmount, interestRateMode, deployer.getAddress(UsdaiMinatoVaultName));
        targetData[6] = abi.encodeWithSignature("withdraw(address,uint256,address)", getAddress(sourceChain, "ASTR"), ASTRWithdrawAmount, deployer.getAddress(UsdaiMinatoVaultName));

        address[] memory decodersAndSanitizers = new address[](opsAmt);  
        decodersAndSanitizers[0] = deployer.getAddress(UsdaiMinatoVaultDecoderAndSanitizerName);
        decodersAndSanitizers[1] = deployer.getAddress(UsdaiMinatoVaultDecoderAndSanitizerName);
        decodersAndSanitizers[2] = deployer.getAddress(UsdaiMinatoVaultDecoderAndSanitizerName);
        decodersAndSanitizers[3] = deployer.getAddress(UsdaiMinatoVaultDecoderAndSanitizerName);
        decodersAndSanitizers[4] = deployer.getAddress(UsdaiMinatoVaultDecoderAndSanitizerName);
        decodersAndSanitizers[5] = deployer.getAddress(UsdaiMinatoVaultDecoderAndSanitizerName);
        decodersAndSanitizers[6] = deployer.getAddress(UsdaiMinatoVaultDecoderAndSanitizerName);
        uint256[] memory values = new uint256[](opsAmt);

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
