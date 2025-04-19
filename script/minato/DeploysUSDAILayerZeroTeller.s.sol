// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.21;

import {Deployer} from "src/helper/Deployer.sol";
import {RolesAuthority, Authority} from "@solmate/auth/authorities/RolesAuthority.sol";
import {ContractNames} from "resources/ContractNames.sol";
// import {MainnetAddresses} from "test/resources/MainnetAddresses.sol";
import {MinatoAddresses} from "test/resources/MinatoAddresses.sol";
import {LayerZeroTeller} from
    "src/base/Roles/CrossChain/Bridges/LayerZero/LayerZeroTeller.sol";
import "forge-std/Script.sol";
import "forge-std/StdJson.sol";
import {MerkleTreeHelper} from "test/resources/MerkleTreeHelper/MerkleTreeHelper.sol";
import {console} from "forge-std/console.sol";
/**
 *  source .env && forge script script/DeployLayerZeroTeller.s.sol:DeployLayerZeroTellerScript --with-gas-price 15000000000 --broadcast --verify
 * @dev Optionally can change `--with-gas-price` to something more reasonable
 */
contract DeployLayerZeroTellerScript is Script, ContractNames, MinatoAddresses, MerkleTreeHelper {
    uint256 public privateKey;

    // Contracts to deploy
    RolesAuthority public rolesAuthority;
    Deployer public deployer;
    LayerZeroTeller public layerZeroTeller;
    address internal weth = 0x4200000000000000000000000000000000000006;
    address internal boringVault; 
    address internal accountant;
    address internal lzEndPoint = 0x6Ac7bdc07A0583A362F1497252872AE6c0A5F5B8;
    uint8 public constant MINTER_ROLE = 2;
    uint8 public constant BURNER_ROLE = 3;

    function setUp() external {
        privateKey = vm.envUint("PRIVATE_KEY");
        vm.createSelectFork("minato");
        setSourceChainName(minato);
        deployer = Deployer(getAddress(sourceChain, "deployerAddress"));
        boringVault = deployer.getAddress(sUsdaiMinatoVaultName);
        accountant = deployer.getAddress(sUsdaiMinatoVaultAccountantName);
        rolesAuthority = RolesAuthority(deployer.getAddress(sUsdaiMinatoVaultRolesAuthorityName));
    }

    function run() external {
        bytes memory creationCode;
        bytes memory constructorArgs;
        vm.startBroadcast(privateKey);

        creationCode = type(LayerZeroTeller).creationCode;
        constructorArgs = abi.encode(dev1Address, boringVault, accountant, weth, lzEndPoint, dev1Address, address(0));
        layerZeroTeller = LayerZeroTeller(
            deployer.deployContract(sUsdaiMinatoLayerZeroTellerName, creationCode, constructorArgs, 0)
        );
        layerZeroTeller.setAuthority(rolesAuthority);
        rolesAuthority.setUserRole(address(layerZeroTeller), MINTER_ROLE, true);
        rolesAuthority.setUserRole(address(layerZeroTeller), BURNER_ROLE, true);
        layerZeroTeller.setChainGasLimit(layerZeroSepoliaEndpointId, 1000000);

        vm.stopBroadcast();
    }
}
