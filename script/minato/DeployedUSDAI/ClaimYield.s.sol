// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.21;

import {Script} from "@forge-std/Script.sol";
import {ERC20} from "@solmate/tokens/ERC20.sol";
import {SafeTransferLib} from "@solmate/utils/SafeTransferLib.sol";
import {BoringVault} from "src/base/BoringVault.sol";
import {AccountantWithFixedRate} from "src/base/Roles/AccountantWithFixedRate.sol";
import {MinatoAddresses} from "test/resources/MinatoAddresses.sol";
import {ContractNames} from "resources/ContractNames.sol";
import {MerkleTreeHelper} from "test/resources/MerkleTreeHelper/MerkleTreeHelper.sol";
import {Deployer} from "src/helper/Deployer.sol";
import {console} from "forge-std/console.sol";

contract ClaimYield is Script, MinatoAddresses, ContractNames, MerkleTreeHelper {
    using SafeTransferLib for ERC20;
    Deployer public deployer;

    function setUp() public {
        vm.createSelectFork("minato");
        setSourceChainName("minato");
        deployer = Deployer(getAddress(sourceChain, "deployerAddress"));
    }

    function run() external {
        // Load private key for authentication
        uint256 privateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(privateKey);

        // Get addresses from address book
        BoringVault boringVault = BoringVault(payable(deployer.getAddress(UsdaiVaultName)));
        AccountantWithFixedRate accountant = AccountantWithFixedRate(deployer.getAddress(UsdaiVaultAccountantName));
        
        // Get yield information
        (uint96 yieldEarned, address distributor) = accountant.fixedRateAccountantState();
        console.log("Yield earned:", yieldEarned);
        console.log("Distributor:", distributor);
        require(yieldEarned > 0, "No yield to claim");
        
        // Determine which asset to claim yield in
        ERC20 yieldAsset = USDC;
        
        // Check allowance before approval
        uint256 allowanceBefore = yieldAsset.allowance(address(boringVault), address(accountant));
        console.log("Allowance before approve:", allowanceBefore);
        
        // Step 1: Authorize accountant to spend tokens from boringVault
        boringVault.manage(
            address(yieldAsset),
            abi.encodeWithSignature("approve(address,uint256)", address(accountant), yieldEarned),
            0 // No ETH value needed
        );
        
        // Check allowance after approval
        uint256 allowanceAfter = yieldAsset.allowance(address(boringVault), address(accountant));
        console.log("Allowance after approve:", allowanceAfter);
        console.log("Intended approval amount:", yieldEarned);
        
        vm.stopBroadcast();
    }
}
