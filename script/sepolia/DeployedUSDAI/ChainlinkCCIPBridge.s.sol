// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.21;

import "forge-std/Script.sol";
import {ERC20} from "@solmate/tokens/ERC20.sol";
import { ILayerZeroEndpointV2 } from "@layerzerolabs/lz-evm-protocol-v2/contracts/interfaces/ILayerZeroEndpointV2.sol";
import {BoringVault} from "src/base/BoringVault.sol";
import {ChainlinkCCIPTeller} from "src/base/Roles/CrossChain/Bridges/CCIP/ChainlinkCCIPTeller.sol";
import {AccountantWithRateProviders} from "src/base/Roles/AccountantWithRateProviders.sol";
import {SepoliaAddresses} from "test/resources/SepoliaAddresses.sol";
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
contract ChainlinkCCIPBridgeScript is Script, SepoliaAddresses, ContractNames, MerkleTreeHelper {
    Deployer public deployer;
    BoringVault vault;
    address public sourceTellerAddress;
    address public destinationTellerAddress = address(0x0dF7c4bBC416b5049E6ACe09aaD43964236FE978);
    ChainlinkCCIPTeller sourceTeller;
    ChainlinkCCIPTeller destinationTeller;
    AccountantWithRateProviders accountant;
    RolesAuthority rolesAuthority;

    uint256 public sharesToBridge = 1e5;
    // ERC20 internal constant NATIVE_ERC20 = ERC20(0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE);
    ERC20 internal constant weth = ERC20(0x097D90c9d3E0B50Ca60e1ae45F6A81010f9FB534);
    uint256 public expectedFee = 1e18;
    uint8 public constant MINTER_ROLE = 2;
    uint8 public constant BURNER_ROLE = 3;

    function setUp() public {
        vm.createSelectFork("sepolia");
        setSourceChainName("sepolia");
        deployer = Deployer(getAddress(sourceChain, "deployerAddress"));
        
        vault = BoringVault(payable(deployer.getAddress(UsdaiVaultName)));
        sourceTellerAddress = deployer.getAddress(UsdaiChainlinkCCIPTellerName);
        sourceTeller = ChainlinkCCIPTeller(sourceTellerAddress);
        accountant = AccountantWithRateProviders(deployer.getAddress(UsdaiVaultAccountantName));
        rolesAuthority = RolesAuthority(deployer.getAddress(UsdaiVaultRolesAuthorityName));
    }

    function run() public {
        uint256 privateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(privateKey);

        // bridge setup
        // sourceTeller.addChain(ccipPlumeChainSelector, true, true, destinationTellerAddress, 1000000);
        // sourceTeller.allowMessagesFromChain(ccipPlumeChainSelector, destinationTellerAddress);
        // sourceTeller.allowMessagesToChain(ccipPlumeChainSelector, destinationTellerAddress, 1000000);

        // rolesAuthority.setPublicCapability(
        //     address(sourceTeller), sourceTeller.bridge.selector, true
        // );

        uint256 fee = sourceTeller.previewFee(uint96(sharesToBridge), vm.addr(privateKey), abi.encode(ccipPlumeChainSelector), weth);
        // to minato
        weth.approve(address(sourceTeller), 100e18);
        sourceTeller.bridge{value: fee}(uint96(sharesToBridge), vm.addr(privateKey), abi.encode(ccipPlumeChainSelector), weth, fee);
        
        vm.stopBroadcast();
    }
}