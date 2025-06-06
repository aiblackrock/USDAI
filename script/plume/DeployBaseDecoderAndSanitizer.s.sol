// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.21;

import {ChainValues} from "test/resources/ChainValues.sol";
import {MerkleTreeHelper} from "test/resources/MerkleTreeHelper/MerkleTreeHelper.sol";
import {Deployer} from "src/helper/Deployer.sol";
import {PlumeAddresses} from "test/resources/PlumeAddresses.sol";
import {ContractNames} from "resources/ContractNames.sol";
import {BaseDecoderAndSanitizer} from "src/base/DecodersAndSanitizers/BaseDecoderAndSanitizer.sol";

import {BoringDrone} from "src/base/Drones/BoringDrone.sol";

import "forge-std/Script.sol";
import "forge-std/StdJson.sol";

/**
 *  source .env && forge script script/DeployDecoderAndSanitizer.s.sol:DeployDecoderAndSanitizerScript --broadcast --etherscan-api-key $ETHERSCAN_KEY --verify --with-gas-price 30000000000
 * @dev Optionally can change `--with-gas-price` to something more reasonable
 */

contract DeployBaseDecoderAndSanitizerScript is Script, ContractNames, PlumeAddresses, MerkleTreeHelper {
    uint256 public privateKey;
    Deployer public deployer = Deployer(deployerAddress);

    function setUp() external {
        privateKey = vm.envUint("PRIVATE_KEY");
        vm.createSelectFork("plume");
        setSourceChainName("plume"); 
    }

    function run() external {
        bytes memory creationCode; bytes memory constructorArgs;
        vm.startBroadcast(privateKey);

        creationCode = type(BaseDecoderAndSanitizer).creationCode;
        constructorArgs = abi.encode(
            deployer.getAddress(UsdaiVaultName)
        );
        deployer.deployContract(UsdaiBaseDecoderAndSanitizerName, creationCode, constructorArgs, 0);

        vm.stopBroadcast();
    }
}
