// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.21;

import {ChainValues} from "test/resources/ChainValues.sol";
import {MerkleTreeHelper} from "test/resources/MerkleTreeHelper/MerkleTreeHelper.sol";
import {Deployer} from "src/helper/Deployer.sol";
import {SepoliaAddresses} from "test/resources/SepoliaAddresses.sol";
import {ContractNames} from "resources/ContractNames.sol";
import {MorphoDecoderAndSanitizer} from "src/base/DecodersAndSanitizers/Protocols/MorphoDecoderAndSanitizer.sol";

import {BoringDrone} from "src/base/Drones/BoringDrone.sol";

import "forge-std/Script.sol";
import "forge-std/StdJson.sol";

/**
 *  source .env && forge script script/DeployDecoderAndSanitizer.s.sol:DeployDecoderAndSanitizerScript --broadcast --etherscan-api-key $ETHERSCAN_KEY --verify --with-gas-price 30000000000
 * @dev Optionally can change `--with-gas-price` to something more reasonable
 */

contract DeployMorphoDecoderAndSanitizerScript is Script, ContractNames, SepoliaAddresses, MerkleTreeHelper {
    uint256 public privateKey;
    Deployer public deployer = Deployer(deployerAddress);
    //Deployer public bobDeployer = Deployer(0xF3d0672a91Fd56C9ef04C79ec67d60c34c6148a0); 

    function setUp() external {
        privateKey = vm.envUint("PRIVATE_KEY");
        vm.createSelectFork("sepolia");
        setSourceChainName("sepolia"); 
    }

    function run() external {
        bytes memory creationCode; bytes memory constructorArgs;
        vm.startBroadcast(privateKey);
    

        //creationCode = type(EtherFiLiquidEthDecoderAndSanitizer).creationCode;
        //constructorArgs = abi.encode(getAddress(sourceChain, "uniswapV3NonFungiblePositionManager"), getAddress(sourceChain, "odosRouterV2"));
        //deployer.deployContract("EtherFi Liquid ETH Decoder And Sanitizer V0.9", creationCode, constructorArgs, 0);


        creationCode = type(MorphoDecoderAndSanitizer).creationCode;
        constructorArgs = abi.encode(
            deployer.getAddress(UsdaiVaultName),
            0x2Ed0a90f247cd7fBe3a6a246b4D9b89a257F7348  // Morpho router address
        );
        deployer.deployContract(UsdaiMorphoDecoderAndSanitizerName, creationCode, constructorArgs, 0);

        vm.stopBroadcast();
    }
}
