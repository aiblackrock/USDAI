// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.21;

import {DeployArcticArchitectureWithoutFixedRate, ERC20, Deployer} from "script/ArchitectureDeployments/DeployArcticArchitectureWithoutFixedRate.sol";
import {AddressToBytes32Lib} from "src/helper/AddressToBytes32Lib.sol";
import {MinatoAddresses} from "test/resources/MinatoAddresses.sol";

// Import Decoder and Sanitizer to deploy.
// import {EtherFiLiquidEthDecoderAndSanitizer} from
//     "src/base/DecodersAndSanitizers/EtherFiLiquidEthDecoderAndSanitizer.sol";
// import {AaveV3DecoderAndSanitizer} from "src/base/DecodersAndSanitizers/Protocols/AaveV3DecoderAndSanitizer.sol";
import {SakeDecoderAndSanitizer} from "src/base/DecodersAndSanitizers/Protocols/SakeDecoderAndSanitizer.sol";

/**
 *  source .env && forge script script/ArchitectureDeployments/Avalanche/DeployYakMilkBtc.s.sol:DeployYakMilkBtcScript --with-gas-price 25000000000 --broadcast --etherscan-api-key $SNOWTRACE_KEY --verify
 * @dev Optionally can change `--with-gas-price` to something more reasonable
 */
contract DeploysUSDAIScript is DeployArcticArchitectureWithoutFixedRate, MinatoAddresses{
    using AddressToBytes32Lib for address;

    uint256 public privateKey;

    // Deployment parameters
    string public boringVaultName = "sSuperUSD boring vault";
    string public boringVaultSymbol = "sSuperUSD";
    uint8 public boringVaultDecimals = 6;
    address public owner = dev0Address;

    function setUp() external {
        privateKey = vm.envUint("PRIVATE_KEY");
        vm.createSelectFork("minato");
    }

    function run() external {
        // Configure the deployment.
        configureDeployment.deployContracts = true;
        configureDeployment.setupRoles = true;
        configureDeployment.setupDepositAssets = true;
        configureDeployment.setupWithdrawAssets = true;
        configureDeployment.finishSetup = true;
        configureDeployment.setupTestUser = true;
        configureDeployment.saveDeploymentDetails = true;
        // from MinatoAddresses
        configureDeployment.deployerAddress = deployerAddress;
        // ignore it since there is no balancer vault on minato
        // configureDeployment.balancerVault = balancerVault;

        // Save deployer.
        deployer = Deployer(configureDeployment.deployerAddress);

        // Define names to determine where contracts are deployed.
        names.rolesAuthority = sUsdaiVaultRolesAuthorityName;
        names.lens = sUsdaiArcticArchitectureLensName;
        names.boringVault = sUsdaiVaultName;
        names.manager = sUsdaiVaultManagerName;
        names.accountant = sUsdaiVaultAccountantName;
        names.teller = sUsdaiVaultTellerName;
        names.rawDataDecoderAndSanitizer = sUsdaiVaultDecoderAndSanitizerName;
        names.delayedWithdrawer = sUsdaiVaultDelayedWithdrawer;

        // Define Accountant Parameters.
        accountantParameters.payoutAddress = liquidPayoutAddress;
        accountantParameters.base = USDAI;
        // Decimals are in terms of `base`.
        accountantParameters.startingExchangeRate = 1e6;
        //  4 decimals
        accountantParameters.platformFee = 0.02e4;
        accountantParameters.performanceFee = 0;
        accountantParameters.allowedExchangeRateChangeLower = 0.995e4;
        accountantParameters.allowedExchangeRateChangeUpper = 1.005e4;
        // Minimum time(in seconds) to pass between updated without triggering a pause.
        accountantParameters.minimumUpateDelayInSeconds = 1 days / 4;

        // Define Decoder and Sanitizer deployment details.
        bytes memory creationCode = type(SakeDecoderAndSanitizer).creationCode;
        bytes memory constructorArgs =
            abi.encode(deployer.getAddress(names.boringVault));

        // Setup extra deposit assets.

        // Setup withdraw assets.

        bool allowPublicDeposits = true;
        bool allowPublicWithdraws = false;
        uint64 shareLockPeriod = 0;
        address delayedWithdrawFeeAddress = liquidPayoutAddress;

        vm.startBroadcast(privateKey);

        _deploy(
            DeployParams({
            deploymentFileName: "sUSDAIMinatoDeployment.json",
            owner: owner,
            boringVaultName: boringVaultName,
            boringVaultSymbol: boringVaultSymbol,
            boringVaultDecimals: boringVaultDecimals,
            decoderAndSanitizerCreationCode: creationCode,
            decoderAndSanitizerConstructorArgs: constructorArgs,
            delayedWithdrawFeeAddress: delayedWithdrawFeeAddress,
            allowPublicDeposits: allowPublicDeposits,
            allowPublicWithdraws: allowPublicWithdraws,
            shareLockPeriod: shareLockPeriod,
            developmentAddress: dev1Address
        })
        );

        vm.stopBroadcast();
    }
}
