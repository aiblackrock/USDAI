// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.21;

import "forge-std/Script.sol";
import {ERC20} from "@solmate/tokens/ERC20.sol";
import { ILayerZeroEndpointV2 } from "@layerzerolabs/lz-evm-protocol-v2/contracts/interfaces/ILayerZeroEndpointV2.sol";
import {BoringVault} from "src/base/BoringVault.sol";
import {LayerZeroTeller} from "src/base/Roles/CrossChain/Bridges/LayerZero/LayerZeroTeller.sol";
import {AccountantWithRateProviders} from "src/base/Roles/AccountantWithRateProviders.sol";
import {MinatoAddresses} from "test/resources/MinatoAddresses.sol";
import {Deployer} from "src/helper/Deployer.sol";
import {ContractNames} from "resources/ContractNames.sol";
import {MerkleTreeHelper} from "test/resources/MerkleTreeHelper/MerkleTreeHelper.sol";
import {RolesAuthority, Authority} from "@solmate/auth/authorities/RolesAuthority.sol";
import {console} from "forge-std/console.sol";

/**
 * @title USDAI Deposit Integration Test
 * @notice This script demonstrates how to deposit USDC and ASTR into the USDAI vault on Minato
 * @dev Run with: forge script script/USDAIIntegrationTest/Deposit.sol --rpc-url $MINATO_RPC_URL
 */
contract sUSDAILayerZeroBridgeScript is Script, MinatoAddresses, ContractNames, MerkleTreeHelper {
    Deployer public deployer;
    BoringVault vault;
    address public sourceTellerAddress;
    address public destinationTellerAddress = address(0x17e900a2D8fBBfAC7114329e4eefA263C8EbdBf2);
    LayerZeroTeller sourceTeller;
    LayerZeroTeller destinationTeller;
    AccountantWithRateProviders accountant;
    RolesAuthority rolesAuthority;

    uint256 public sharesToBridge = 1e5;
    ERC20 internal constant NATIVE_ERC20 = ERC20(0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE);
    uint256 public expectedFee = 1e18;
    uint8 public constant MINTER_ROLE = 2;
    uint8 public constant BURNER_ROLE = 3;

    function setUp() public {
        vm.createSelectFork("minato");
        setSourceChainName("minato");
        deployer = Deployer(getAddress(sourceChain, "deployerAddress"));
        
        vault = BoringVault(payable(deployer.getAddress(sUsdaiVaultName)));
        sourceTellerAddress = deployer.getAddress(sUsdaiLayerZeroTellerName);
        sourceTeller = LayerZeroTeller(sourceTellerAddress);
        accountant = AccountantWithRateProviders(deployer.getAddress(sUsdaiVaultAccountantName));
        rolesAuthority = RolesAuthority(deployer.getAddress(sUsdaiVaultRolesAuthorityName));
    }

    function run() public {
        uint256 privateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(privateKey);

        // bridge setup
        sourceTeller.addChain(layerZeroSepoliaEndpointId, true, true, destinationTellerAddress, 1000000);
        sourceTeller.allowMessagesFromChain(layerZeroSepoliaEndpointId, destinationTellerAddress);
        sourceTeller.allowMessagesToChain(layerZeroSepoliaEndpointId, destinationTellerAddress, 1000000);

        // sourceTeller.setAuthority(rolesAuthority);
        // rolesAuthority.setUserRole(address(sourceTeller), MINTER_ROLE, true);
        // rolesAuthority.setUserRole(address(sourceTeller), BURNER_ROLE, true);
        // rolesAuthority.setPublicCapability(
        //     address(sourceTeller), sourceTeller.bridge.selector, true
        // );

        uint256 fee = sourceTeller.previewFee(uint96(sharesToBridge), vm.addr(privateKey), abi.encode(layerZeroSepoliaEndpointId), NATIVE_ERC20);
        // to sepolia
        sourceTeller.bridge{value: fee}(uint96(sharesToBridge), vm.addr(privateKey), abi.encode(layerZeroSepoliaEndpointId), NATIVE_ERC20, expectedFee);
        
        vm.stopBroadcast();
    }
}