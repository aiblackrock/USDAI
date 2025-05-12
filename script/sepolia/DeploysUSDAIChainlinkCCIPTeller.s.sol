// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.21;

import {Deployer} from "src/helper/Deployer.sol";
import {RolesAuthority, Authority} from "@solmate/auth/authorities/RolesAuthority.sol";
import {ContractNames} from "resources/ContractNames.sol";
// import {MainnetAddresses} from "test/resources/MainnetAddresses.sol";
import {SepoliaAddresses} from "test/resources/SepoliaAddresses.sol";
import {ChainlinkCCIPTeller} from
    "src/base/Roles/CrossChain/Bridges/CCIP/ChainlinkCCIPTeller.sol";
import "forge-std/Script.sol";
import "forge-std/StdJson.sol";
import {MerkleTreeHelper} from "test/resources/MerkleTreeHelper/MerkleTreeHelper.sol";
import {console} from "forge-std/console.sol";
/**
 *  source .env && forge script script/DeployLayerZeroTeller.s.sol:DeployLayerZeroTellerScript --with-gas-price 15000000000 --broadcast --verify
 * @dev Optionally can change `--with-gas-price` to something more reasonable
 */
contract DeployChainlinkCCIPTellerScript is Script, ContractNames, SepoliaAddresses, MerkleTreeHelper {
    uint256 public privateKey;

    // Contracts to deploy
    RolesAuthority public rolesAuthority;
    Deployer public deployer;
    ChainlinkCCIPTeller public chainlinkCCIPTeller;
    address internal weth = 0x097D90c9d3E0B50Ca60e1ae45F6A81010f9FB534;
    address internal boringVault; 
    address internal accountant;

    uint8 public constant MINTER_ROLE = 2;
    uint8 public constant BURNER_ROLE = 3;

    function setUp() external {
        privateKey = vm.envUint("PRIVATE_KEY");
        vm.createSelectFork("sepolia");
        setSourceChainName(sepolia);
        deployer = Deployer(getAddress(sourceChain, "deployerAddress"));
        boringVault = deployer.getAddress(sUsdaiVaultName);
        accountant = deployer.getAddress(sUsdaiVaultAccountantName);
        rolesAuthority = RolesAuthority(deployer.getAddress(sUsdaiVaultRolesAuthorityName));
    }

    function run() external {
        bytes memory creationCode;
        bytes memory constructorArgs;
        vm.startBroadcast(privateKey);

        creationCode = type(ChainlinkCCIPTeller).creationCode;
        constructorArgs = abi.encode(dev1Address, boringVault, accountant, weth, ccipRouter);
        chainlinkCCIPTeller = ChainlinkCCIPTeller(
            deployer.deployContract(sUsdaiChainlinkCCIPTellerName, creationCode, constructorArgs, 0)
        );
        chainlinkCCIPTeller.setAuthority(rolesAuthority);
        rolesAuthority.setUserRole(address(chainlinkCCIPTeller), MINTER_ROLE, true);
        rolesAuthority.setUserRole(address(chainlinkCCIPTeller), BURNER_ROLE, true);

        vm.stopBroadcast();
    }
}
