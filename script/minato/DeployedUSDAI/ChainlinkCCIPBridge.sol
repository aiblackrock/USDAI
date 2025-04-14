// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.21;

import "forge-std/Script.sol";
import {ERC20} from "@solmate/tokens/ERC20.sol";
import { ILayerZeroEndpointV2 } from "@layerzerolabs/lz-evm-protocol-v2/contracts/interfaces/ILayerZeroEndpointV2.sol";
import {BoringVault} from "src/base/BoringVault.sol";
import {ChainlinkCCIPTeller} from "src/base/Roles/CrossChain/Bridges/CCIP/ChainlinkCCIPTeller.sol";
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
contract ChainlinkCCIPBridgeScript is Script, MinatoAddresses, ContractNames, MerkleTreeHelper {
    Deployer public deployer;
    BoringVault vault;
    address public sourceTellerAddress;
    address public destinationTellerAddress = address(0xDa109345D0d434dEc1D6E02E6d29B06f5DB9CFC9);
    ChainlinkCCIPTeller sourceTeller;
    ChainlinkCCIPTeller destinationTeller;
    AccountantWithRateProviders accountant;
    RolesAuthority rolesAuthority;

    uint256 public sharesToBridge = 1e5;
    // ERC20 internal constant NATIVE_ERC20 = ERC20(0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE);
    ERC20 internal constant weth = ERC20(0x4200000000000000000000000000000000000006);
    // uint256 public expectedFee = 1e18;
    uint8 public constant MINTER_ROLE = 2;
    uint8 public constant BURNER_ROLE = 3;

    function setUp() public {
        vm.createSelectFork("minato");
        setSourceChainName("minato");
        deployer = Deployer(getAddress(sourceChain, "deployerAddress"));
        
        vault = BoringVault(payable(deployer.getAddress(UsdaiMinatoVaultName)));
        sourceTellerAddress = deployer.getAddress(UsdaiMinatoChainlinkCCIPTellerName);
        sourceTeller = ChainlinkCCIPTeller(sourceTellerAddress);
        accountant = AccountantWithRateProviders(deployer.getAddress(UsdaiMinatoVaultAccountantName));
        rolesAuthority = RolesAuthority(deployer.getAddress(UsdaiMinatoVaultRolesAuthorityName));
    }

    function run() public {
        uint256 privateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(privateKey);

        // bridge setup
        // sourceTeller.addChain(ccipSepoliaChainSelector, true, true, destinationTellerAddress, 1000000);
        // sourceTeller.allowMessagesFromChain(ccipSepoliaChainSelector, destinationTellerAddress);
        // sourceTeller.allowMessagesToChain(ccipSepoliaChainSelector, destinationTellerAddress, 1000000);

        uint256 fee = sourceTeller.previewFee(uint96(sharesToBridge), vm.addr(privateKey), abi.encode(ccipSepoliaChainSelector), weth);
        weth.approve(address(sourceTeller), fee);
        // to sepolia
        sourceTeller.bridge(uint96(sharesToBridge), vm.addr(privateKey), abi.encode(ccipSepoliaChainSelector), weth, fee);
        
        vm.stopBroadcast();
    }
}