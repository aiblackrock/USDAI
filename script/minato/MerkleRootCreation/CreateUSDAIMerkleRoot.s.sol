// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.21;

import {FixedPointMathLib} from "@solmate/utils/FixedPointMathLib.sol";
import {ERC20} from "@solmate/tokens/ERC20.sol";
import {Strings} from "lib/openzeppelin-contracts/contracts/utils/Strings.sol";
import {ERC4626} from "@solmate/tokens/ERC4626.sol";
import {MerkleTreeHelper} from "test/resources/MerkleTreeHelper/MerkleTreeHelper.sol";
import "forge-std/Script.sol";
import {Deployer} from "src/helper/Deployer.sol";
import {ContractNames} from "resources/ContractNames.sol";
import {ManagerWithMerkleVerification} from "src/base/Roles/ManagerWithMerkleVerification.sol";
import {console} from "forge-std/console.sol";

/**
 *  source .env && forge script script/MerkleRootCreation/Mainnet/CreateLiquidUsualMerkleRoot.s.sol --rpc-url $MAINNET_RPC_URL
 */
contract CreateUSDAIMerkleRootScript is Script, MerkleTreeHelper, ContractNames {
    using FixedPointMathLib for uint256;

    Deployer public deployer;
    ManagerWithMerkleVerification manager;

    function setUp() external {
        vm.createSelectFork("minato");
        setSourceChainName("minato");
        deployer = Deployer(getAddress(sourceChain, "deployerAddress"));
        manager = ManagerWithMerkleVerification(deployer.getAddress(UsdaiVaultManagerName));
    }

    /**
     * @notice Uncomment which script you want to run.
     */
    function run() external {
        uint256 privateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(privateKey);
        address auth = vm.addr(privateKey);

        setAddress(true, minato, "boringVault", deployer.getAddress(UsdaiVaultName));
        setAddress(true, minato, "managerAddress", deployer.getAddress(UsdaiVaultManagerName));
        setAddress(true, minato, "accountantAddress", deployer.getAddress(UsdaiVaultAccountantName));
        setAddress(true, minato, "rawDataDecoderAndSanitizer", deployer.getAddress(UsdaiVaultDecoderAndSanitizerName));

        ManageLeaf[] memory leafs = new ManageLeaf[](128);

        ERC20[] memory supplyAssets = new ERC20[](2);
        supplyAssets[0] = getERC20(sourceChain, "USDC");
        supplyAssets[1] = getERC20(sourceChain, "ASTR");
        ERC20[] memory borrowAssets = new ERC20[](2);
        borrowAssets[0] = getERC20(sourceChain, "USDC");
        borrowAssets[1] = getERC20(sourceChain, "ASTR");
 
        _addAaveV3Leafs(leafs, supplyAssets, borrowAssets, new ERC20[](0));

        _verifyDecoderImplementsLeafsFunctionSelectors(leafs);

        bytes32[][] memory manageTree = _generateMerkleTree(leafs);

        string memory filePath = "./leafs/USDAILeafs.json";

        bytes32 merkleRoot = manageTree[manageTree.length - 1][0];

        _generateLeafs(filePath, leafs, merkleRoot, manageTree);

        manager.setManageRoot(auth, merkleRoot);

        vm.stopBroadcast();
    }
}
