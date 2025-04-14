// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.21;

contract ContractNames {
    string public constant SevenSeasRolesAuthorityName = "Seven Seas RolesAuthority Version 0.0";
    string public constant ArcticArchitectureLensName = "Arctic Architecture Lens V0.0";
    string public constant AtomicQueueName = "Atomic Queue V0.11";
    string public constant AtomicSolverName = "Atomic Solver V4.11";
    string public constant IncentiveDistributorName = "Incentive Distributor V0.1";
    string public constant PaymentSplitterName = "Payment Splitter V0.0";
    string public constant PaymentSplitterRolesAuthorityName = "Payment Splitter Roles Authority V0.0";

    // Migration
    string public constant CellarMigrationAdaptorName = "Cellar Migration Adaptor V0.1";
    string public constant CellarMigrationAdaptorName2 = "Cellar Migration Adaptor 2 V0.0";
    string public constant ParitySharePriceOracleName = "Parity Share Price Oracle V0.0";
    string public constant CellarMigratorWithSharePriceParityName = "Cellar Migrator With Share Price Parity V0.0";

    // Vaults
    string public constant EtherFiLiquidUsdRolesAuthorityName = "EtherFi Liquid USD RolesAuthority Version 0.0";
    string public constant EtherFiLiquidUsdName = "EtherFi Liquid USD V0.0";
    string public constant EtherFiLiquidUsdManagerName = "EtherFi Liquid USD Manager With Merkle Verification V0.0";
    string public constant EtherFiLiquidUsdAccountantName = "EtherFi Liquid USD Accountant With Rate Providers V0.0";
    string public constant EtherFiLiquidUsdTellerName = "EtherFi Liquid USD Teller With Multi Asset Support V0.0";
    string public constant EtherFiLiquidUsdDecoderAndSanitizerName = "EtherFi Liquid USD Decoder and Sanitizer V0.5";
    string public constant EtherFiLiquidUsdDelayedWithdrawer = "EtherFi Liquid USD Delayed Withdrawer V0.0";
    string public constant EtherFiLiquidUsdPancakeSwapDecoderAndSanitizerName =
        "EtherFi Liquid USD PancakeSwap Decoder and Sanitizer V0.0";

    string public constant LombardBtcRolesAuthorityName = "Lombard BTC RolesAuthority Version 0.0";
    string public constant LombardBtcName = "Lombard BTC V0.1";
    string public constant LombardBtcManagerName = "Lombard BTC Manager With Merkle Verification V0.0";
    string public constant LombardBtcAccountantName = "Lombard BTC Accountant With Rate Providers V0.1";
    string public constant LombardBtcTellerName = "Lombard BTC Teller With Multi Asset Support V0.1";
    string public constant LombardBtcDecoderAndSanitizerName = "Lombard BTC Decoder and Sanitizer V0.1";
    string public constant LombardBtcAerodromeDecoderAndSanitizerName =
        "Lombard BTC Aerodrome Decoder and Sanitizer V0.0";
    string public constant LombardBtcDelayedWithdrawer = "Lombard BTC Delayed Withdrawer V0.0";

    string public constant EtherFiLiquidEthRolesAuthorityName = "EtherFi Liquid ETH RolesAuthority Version 0.0";
    string public constant EtherFiLiquidEthName = "EtherFi Liquid ETH V0.1";
    string public constant EtherFiLiquidEthManagerName = "EtherFi Liquid ETH Manager With Merkle Verification V0.1";
    string public constant EtherFiLiquidEthAccountantName = "EtherFi Liquid ETH Accountant With Rate Providers V0.1";
    string public constant EtherFiLiquidEthTellerName = "EtherFi Liquid ETH Teller With Multi Asset Support V0.1";
    string public constant EtherFiLiquidEthDecoderAndSanitizerName = "EtherFi Liquid ETH Decoder and Sanitizer V0.10";
    string public constant EtherFiLiquidEthDelayedWithdrawer = "EtherFi Liquid ETH Delayed Withdrawer V0.0";
    string public constant EtherFiLiquidEthPancakeSwapDecoderAndSanitizerName =
        "EtherFi Liquid ETH PancakeSwap Decoder and Sanitizer V0.0";
    string public constant EtherFiLiquidEthCamelotDecoderAndSanitizerName =
        "EtherFi Liquid ETH Camelot Decoder and Sanitizer V0.0";
    string public constant EtherFiLiquidEthAerodromeDecoderAndSanitizerName =
        "EtherFi Liquid ETH Aerodrome Decoder and Sanitizer V0.0";
    string public constant EtherFiLiquidEthQueueName = "EtherFi Liquid ETH Queue V0.0";
    string public constant EtherFiLiquidEthQueueSolverName = "EtherFi Liquid ETH Queue Solver V0.0";

    string public constant TestVaultEthRolesAuthorityName = "Test ETH Vault RolesAuthority Version 0.0";
    string public constant TestVaultEthName = "Test ETH Vault V0.0";
    string public constant TestVaultEthManagerName = "Test ETH Vault Manager With Merkle Verification V0.0";
    string public constant TestVaultEthAccountantName = "Test ETH Vault Accountant With Rate Providers V0.0";
    string public constant TestVaultEthTellerName = "Test ETH Vault Teller With Multi Asset Support V0.0";
    string public constant TestVaultEthDecoderAndSanitizerName = "Test ETH Vault Decoder and Sanitizer V0.0";
    string public constant TestVaultEthDelayedWithdrawer = "Test ETH Vault Delayed Withdrawer V0.0";

    string public constant EtherFiLiquidBtcRolesAuthorityName = "EtherFi Liquid BTC RolesAuthority Version 0.0";
    string public constant EtherFiLiquidBtcName = "EtherFi Liquid BTC V0.0";
    string public constant EtherFiLiquidBtcManagerName = "EtherFi Liquid BTC Manager With Merkle Verification V0.0";
    string public constant EtherFiLiquidBtcAccountantName = "EtherFi Liquid BTC Accountant With Rate Providers V0.0";
    string public constant EtherFiLiquidBtcTellerName = "EtherFi Liquid BTC Teller With Multi Asset Support V0.0";
    string public constant EtherFiLiquidBtcDecoderAndSanitizerName = "EtherFi Liquid BTC Decoder and Sanitizer V0.1";
    string public constant EtherFiLiquidBtcDelayedWithdrawer = "EtherFi Liquid BTC Delayed Withdrawer V0.0";

    string public constant EtherFiBtcRolesAuthorityName = "ether.fi BTC RolesAuthority Version 0.0";
    string public constant EtherFiBtcName = "ether.fi BTC V0.0";
    string public constant EtherFiBtcManagerName = "ether.fi BTC Manager With Merkle Verification V0.0";
    string public constant EtherFiBtcAccountantName = "ether.fi BTC Accountant With Rate Providers V0.0";
    string public constant EtherFiBtcTellerName = "ether.fi BTC Teller With Multi Asset Support V0.0";
    string public constant EtherFiBtcDecoderAndSanitizerName = "ether.fi BTC Decoder and Sanitizer V0.1";
    string public constant EtherFiBtcDelayedWithdrawer = "ether.fi BTC Delayed Withdrawer V0.0";

    string public constant EtherFiLiquidUsualRolesAuthorityName = "EtherFi Liquid Usual RolesAuthority Version 0.0";
    string public constant EtherFiLiquidUsualName = "EtherFi Liquid Usual V0.0";
    string public constant EtherFiLiquidUsualManagerName = "EtherFi Liquid Usual Manager With Merkle Verification V0.0";
    string public constant EtherFiLiquidUsualAccountantName = "EtherFi Liquid Usual Accountant With Rate Providers V0.0";
    string public constant EtherFiLiquidUsualTellerName = "EtherFi Liquid Usual Teller With Multi Asset Support V0.0";
    string public constant EtherFiLiquidUsualDecoderAndSanitizerName = "EtherFi Liquid Usual Decoder and Sanitizer V0.5";
    string public constant EtherFiLiquidUsualDelayedWithdrawer = "EtherFi Liquid Usual Delayed Withdrawer V0.0";
    string public constant EtherFiLiquidUsualPancakeSwapDecoderAndSanitizerName =
        "EtherFi Liquid Usual PancakeSwap Decoder and Sanitizer V0.0";

    string public constant AvalancheVaultRolesAuthorityName = "Avalanche Vault RolesAuthority Version 0.0";
    string public constant AvalancheVaultName = "Avalanche Vault V0.0";
    string public constant AvalancheVaultManagerName = "Avalanche Vault Manager With Merkle Verification V0.0";
    string public constant AvalancheVaultAccountantName = "Avalanche Vault Accountant With Rate Providers V0.0";
    string public constant AvalancheVaultTellerName = "Avalanche Vault Teller With Multi Asset Support V0.0";
    string public constant AvalancheVaultDecoderAndSanitizerName = "Avalanche Vault Decoder and Sanitizer V0.1";
    string public constant AvalancheVaultDelayedWithdrawer = "Avalanche Vault Delayed Withdrawer V0.0";

    string public constant BridgingTestVaultEthRolesAuthorityName = "Bridging Test ETH Vault RolesAuthority V1.3";
    string public constant BridgingTestVaultEthName = "Bridging Test ETH Vault V1.3";
    string public constant BridgingTestVaultEthManagerName =
        "Bridging Test ETH Vault Manager With Merkle Verification V1.3";
    string public constant BridgingTestVaultEthAccountantName =
        "Bridging Test ETH Vault Accountant With Rate Providers V1.3";
    string public constant BridgingTestVaultEthTellerName =
        "Bridging Test ETH Vault Teller With Multi Asset Support V1.3";
    string public constant BridgingTestVaultEthDecoderAndSanitizerName =
        "Bridging Test ETH Vault Decoder and Sanitizer V1.5"; // was 1.4
    string public constant BridgingTestVaultEthDelayedWithdrawer = "Bridging Test ETH Vault Delayed Withdrawer V1.3";
    string public constant BridgingTestVaultEthAerodromeDecoderAndSanitizerName =
        "Bridging Test ETH Vault Aerodrome Decoder and Sanitizer V0.0";
    string public constant BridgingTestVaultDroneName = "btv-drone V0.1";

    string public constant StakedETHFIRolesAuthorityName = "Staked ETHFI RolesAuthority Version 0.0";
    string public constant StakedETHFIName = "Staked ETHFI V0.1";
    string public constant StakedETHFIManagerName = "Staked ETHFI Manager With Merkle Verification V0.0";
    string public constant StakedETHFIAccountantName = "Staked ETHFI Accountant With Rate Providers V0.0";
    string public constant StakedETHFITellerName = "Staked ETHFI Teller With Multi Asset Support V0.0";
    string public constant StakedETHFIDecoderAndSanitizerName = "Staked ETHFI Decoder and Sanitizer V0.1";
    string public constant StakedETHFIDelayedWithdrawer = "Staked ETHFI Delayed Withdrawer V0.0";

    string public constant CanaryBtcRolesAuthorityName = "Lombard Earn RolesAuthority Version 0.0";
    string public constant CanaryBtcName = "Lombard Earn V0.0";
    string public constant CanaryBtcManagerName = "Lombard Earn Manager With Merkle Verification V0.0";
    string public constant CanaryBtcAccountantName = "Lombard Earn Accountant With Rate Providers V0.0";
    string public constant CanaryBtcTellerName = "Lombard Earn Teller With Multi Asset Support V0.0";
    string public constant CanaryBtcDecoderAndSanitizerName = "Lombard Earn Decoder and Sanitizer V0.0";
    string public constant CanaryBtcDelayedWithdrawer = "Lombard Earn Delayed Withdrawer V0.0";
    string public constant LombardPancakeSwapDecoderAndSanitizerName = "Lombard PancakeSwap Decoder and Sanitizer V0.0";

    string public constant CbBtcDefiVaultRolesAuthorityName = "CB BTC DeFi Vault RolesAuthority Version 0.0";
    string public constant CbBtcDefiVaultName = "CB BTC DeFi Vault V0.0";
    string public constant CbBtcDefiVaultManagerName = "CB BTC DeFi Vault Manager With Merkle Verification V0.0";
    string public constant CbBtcDefiVaultAccountantName = "CB BTC DeFi Vault Accountant With Rate Providers V0.0";
    string public constant CbBtcDefiVaultTellerName = "CB BTC DeFi Vault Teller With Multi Asset Support V0.0";
    string public constant CbBtcDefiVaultDecoderAndSanitizerName = "CB BTC DeFi Vault Decoder and Sanitizer V0.0";
    string public constant CbBtcDefiVaultDelayedWithdrawer = "CB BTC DeFi Vault Delayed Withdrawer V0.0";

    string public constant TestCCIPTellerName = "Test CCIP Teller V0.0";

    string public constant Btc_FiRolesAuthorityName = "BTC-Fi RolesAuthority Version 0.0";
    string public constant Btc_FiName = "BTC-Fi V0.0";
    string public constant Btc_FiManagerName = "BTC-Fi Manager With Merkle Verification V0.0";
    string public constant Btc_FiAccountantName = "BTC-Fi Accountant With Rate Providers V0.0";
    string public constant Btc_FiTellerName = "BTC-Fi Teller With Multi Asset Support V0.0";
    string public constant Btc_FiDecoderAndSanitizerName = "BTC-Fi Decoder and Sanitizer V0.1";
    string public constant Btc_FiDelayedWithdrawer = "BTC-Fi Delayed Withdrawer V0.0";

    string public constant SymbioticLRTVaultRolesAuthorityName = "Symbiotic LRT Vault RolesAuthority V0.0";
    string public constant SymbioticLRTVaultName = "Symbiotic LRT Vault V0.0";
    string public constant SymbioticLRTVaultManagerName = "Symbiotic LRT Vault Manager With Merkle Verification V0.0";
    string public constant SymbioticLRTVaultAccountantName = "Symbiotic LRT Vault Accountant With Rate Providers V0.0";
    string public constant SymbioticLRTVaultTellerName = "Symbiotic LRT Vault Teller With Multi Asset Support V0.0";
    string public constant SymbioticLRTVaultDecoderAndSanitizerName = "Symbiotic LRT Vault Decoder and Sanitizer V0.2";
    string public constant SymbioticLRTVaultDelayedWithdrawer = "Symbiotic LRT Vault Delayed Withdrawer V0.0";
    string public constant SymbioticLRTVaultQueueName = "Symbiotic LRT Vault Queue V0.1";
    string public constant SymbioticLRTVaultQueueSolverName = "Symbiotic LRT Vault Queue Solver V0.1";

    string public constant KarakVaultRolesAuthorityName = "Karak Vault RolesAuthority V0.0";
    string public constant KarakVaultName = "Karak Vault V0.0";
    string public constant KarakVaultManagerName = "Karak Vault Manager With Merkle Verification V0.0";
    string public constant KarakVaultAccountantName = "Karak Vault Accountant With Rate Providers V0.0";
    string public constant KarakVaultTellerName = "Karak Vault Teller With Multi Asset Support V0.0";
    string public constant KarakVaultDecoderAndSanitizerName = "Karak Vault Decoder and Sanitizer V0.0";
    string public constant KarakVaultDelayedWithdrawer = "Karak Vault Delayed Withdrawer V0.0";

    string public constant EtherFiUsdRolesAuthorityName = "EtherFi USD RolesAuthority Version 0.0";
    string public constant EtherFiUsdName = "EtherFi USD V0.0";
    string public constant EtherFiUsdManagerName = "EtherFi USD Manager With Merkle Verification V0.0";
    string public constant EtherFiUsdAccountantName = "EtherFi USD Accountant With Rate Providers V0.0";
    string public constant EtherFiUsdTellerName = "EtherFi USD Teller With Multi Asset Support V0.0";
    string public constant EtherFiUsdDecoderAndSanitizerName = "EtherFi USD Decoder and Sanitizer V0.1";
    string public constant EtherFiUsdDelayedWithdrawer = "EtherFi USD Delayed Withdrawer V0.0";

    string public constant EtherFiEigenRolesAuthorityName = "EtherFi EIGEN RolesAuthority Version 0.0";
    string public constant EtherFiEigenName = "EtherFi EIGEN V0.0";
    string public constant EtherFiEigenManagerName = "EtherFi EIGEN Manager With Merkle Verification V0.0";
    string public constant EtherFiEigenAccountantName = "EtherFi EIGEN Accountant With Rate Providers V0.0";
    string public constant EtherFiEigenTellerName = "EtherFi EIGEN Teller With Multi Asset Support V0.0";
    string public constant EtherFiEigenDecoderAndSanitizerName = "EtherFi EIGEN Decoder and Sanitizer V0.1";
    string public constant EtherFiEigenDelayedWithdrawer = "EtherFi EIGEN Delayed Withdrawer V0.0";

    string public constant YakMilkAvaxVaultRolesAuthorityName = "Yak Milk Avax Vault RolesAuthority V0.0";
    string public constant YakMilkAvaxVaultName = "Yak Milk Avax Vault V0.0";
    string public constant YakMilkAvaxVaultManagerName = "Yak Milk Avax Vault Manager With Merkle Verification V0.0";
    string public constant YakMilkAvaxVaultAccountantName = "Yak Milk Avax Vault Accountant With Rate Providers V0.0";
    string public constant YakMilkAvaxVaultTellerName = "Yak Milk Avax Vault Teller With Multi Asset Support V0.0";
    string public constant YakMilkAvaxVaultDecoderAndSanitizerName = "Yak Milk Avax Vault Decoder and Sanitizer V0.0";
    string public constant YakMilkAvaxVaultDelayedWithdrawer = "Yak Milk Avax Vault Delayed Withdrawer V0.0";

    string public constant YakMilkBtcVaultRolesAuthorityName = "Yak Milk Btc Vault RolesAuthority V0.0";
    string public constant YakMilkBtcVaultName = "Yak Milk Btc Vault V0.0";
    string public constant YakMilkBtcVaultManagerName = "Yak Milk Btc Vault Manager With Merkle Verification V0.0";
    string public constant YakMilkBtcVaultAccountantName = "Yak Milk Btc Vault Accountant With Rate Providers V0.0";
    string public constant YakMilkBtcVaultTellerName = "Yak Milk Btc Vault Teller With Multi Asset Support V0.0";
    string public constant YakMilkBtcVaultDecoderAndSanitizerName = "Yak Milk Btc Vault Decoder and Sanitizer V0.0";
    string public constant YakMilkBtcVaultDelayedWithdrawer = "Yak Milk Btc Vault Delayed Withdrawer V0.0";

    string public constant YakMilkUsdVaultRolesAuthorityName = "Yak Milk Usd Vault RolesAuthority V0.0";
    string public constant YakMilkUsdVaultName = "Yak Milk Usd Vault V0.0";
    string public constant YakMilkUsdVaultManagerName = "Yak Milk Usd Vault Manager With Merkle Verification V0.0";
    string public constant YakMilkUsdVaultAccountantName = "Yak Milk Usd Vault Accountant With Rate Providers V0.0";
    string public constant YakMilkUsdVaultTellerName = "Yak Milk Usd Vault Teller With Multi Asset Support V0.0";
    string public constant YakMilkUsdVaultDecoderAndSanitizerName = "Yak Milk Usd Vault Decoder and Sanitizer V0.0";
    string public constant YakMilkUsdVaultDelayedWithdrawer = "Yak Milk Usd Vault Delayed Withdrawer V0.0";

    string public constant EtherFiElixirUsdRolesAuthorityName = "EtherFi Elixir USD RolesAuthority Version 0.0";
    string public constant EtherFiElixirUsdName = "EtherFi Elixir USD V0.0";
    string public constant EtherFiElixirUsdManagerName = "EtherFi Elixir USD Manager With Merkle Verification V0.0";
    string public constant EtherFiElixirUsdAccountantName = "EtherFi Elixir USD Accountant With Rate Providers V0.0";
    string public constant EtherFiElixirUsdTellerName = "EtherFi Elixir USD Teller With Multi Asset Support V0.0";
    string public constant EtherFiElixirUsdDecoderAndSanitizerName = "EtherFi Elixir USD Decoder and Sanitizer V0.0";
    string public constant EtherFiElixirUsdDelayedWithdrawer = "EtherFi Elixir USD Delayed Withdrawer V0.0";
    string public constant EtherFiElixirUsdPancakeSwapDecoderAndSanitizerName =
        "EtherFi Elixir USD PancakeSwap Decoder and Sanitizer V0.0";

    string public constant SommTestVaultRolesAuthorityName = "Somm Test Vault RolesAuthority V0.0";
    string public constant SommTestVaultName = "Somm Test Vault V0.0";
    string public constant SommTestVaultManagerName = "Somm Test Vault Manager With Merkle Verification V0.0";
    string public constant SommTestVaultAccountantName = "Somm Test Vault Accountant With Rate Providers V0.0";
    string public constant SommTestVaultTellerName = "Somm Test Vault Teller With Multi Asset Support V0.0";
    string public constant SommTestVaultDecoderAndSanitizerName = "Somm Test Vault Decoder and Sanitizer V0.0";
    string public constant SommTestVaultDelayedWithdrawer = "Somm Test Vault Delayed Withdrawer V0.0";
    string public constant SommTestVaultQueueName = "Somm Test Vault Queue V0.0";
    string public constant SommTestVaultQueueSolverName = "Somm Test Vault Queue Solver V0.0";

    string public constant ItbPositionDecoderAndSanitizerName = "ITB Position Decoder and Sanitizer V0.5";

    // Generic Rate Providers
    string public constant PendlePTweETHRateProviderName = "Pendle PT weETH Rate Provider V0.0";
    string public constant PendleYTweETHRateProviderName = "Pendle YT weETH Rate Provider V0.0";
    string public constant PendleLPweETHRateProviderName = "Pendle LP weETH Rate Provider V0.0";
    string public constant PendleZircuitPTweETHRateProviderName = "Pendle Zircuit PT weETH Rate Provider V0.0";
    string public constant PendleZircuitYTweETHRateProviderName = "Pendle Zircuit YT weETH Rate Provider V0.0";
    string public constant PendleZircuitLPweETHRateProviderName = "Pendle Zircuit LP weETH Rate Provider V0.0";
    string public constant AuraRETHWeETHBptRateProviderName = "Aura rETH weETH Bpt Rate Provider V0.0";
    string public constant WstETHRateProviderName = "wstETH Rate Provider V0.0";
    string public constant PendleWeETHMarketSeptemberRateProviderName =
        "Pendle weETH Market September 2024 Rate Provider V0.0";
    string public constant PendleEethPtSeptemberRateProviderName = "Pendle eETH PT September 2024 Rate Provider V0.0";
    string public constant PendleEethYtSeptemberRateProviderName = "Pendle eETH YT September 2024 Rate Provider V0.0";
    string public constant PendleWeETHMarketDecemberRateProviderName =
        "Pendle weETH Market December 2024 Rate Provider V0.0";
    string public constant PendleEethPtDecemberRateProviderName = "Pendle eETH PT December 2024 Rate Provider V0.0";
    string public constant PendleEethYtDecemberRateProviderName = "Pendle eETH YT December 2024 Rate Provider V0.0";
    string public constant WSTETHRateProviderName = "WSTETH Generic Rate Provider V0.0";
    string public constant CBETHRateProviderName = "cbETH Generic Rate Provider V0.0";
    string public constant WBETHRateProviderName = "WBETH Generic Rate Provider V0.0";
    string public constant RETHRateProviderName = "RETH Generic Rate Provider V0.0";
    string public constant METHRateProviderName = "METH Generic Rate Provider V0.0";
    string public constant SWETHRateProviderName = "SWETH Generic Rate Provider V0.0";
    string public constant SFRXETHRateProviderName = "SFRXETH Generic Rate Provider V0.0";
    string public constant WEETHRateProviderName = "weETH Generic Rate Provider V0.0";
    string public constant sdeUSDRateProviderName = "sdeUSD Generic Rate Provider V0.0";

    // USDAI in minato
    string public constant UsdaiMinatoBoringOnChainQueuesRolesAuthorityName = "USDAI Minato Boring OnChain Queues Roles Authority V0.5";
    string public constant UsdaiMinatoVaultRolesAuthorityName = "USDAI Minato Vault RolesAuthority V0.5";
    string public constant UsdaiMinatoArcticArchitectureLensName = "USDAI Minato Arctic Architecture Lens V0.5";
    string public constant UsdaiMinatoVaultName = "USDAI Minato Vault V0.5";
    string public constant UsdaiMinatoVaultManagerName = "USDAI Minato Vault Manager With Merkle Verification V0.5";
    string public constant UsdaiMinatoVaultAccountantName = "USDAI Minato Vault Accountant With Rate Providers V0.5";
    string public constant UsdaiMinatoVaultTellerName = "USDAI Minato Vault Teller With Multi Asset Support V0.5";
    string public constant UsdaiMinatoVaultDecoderAndSanitizerName = "USDAI Minato Vault Decoder and Sanitizer V0.5";
    string public constant UsdaiMinatoVaultDelayedWithdrawer = "USDAI Minato Vault Delayed Withdrawer V0.5";
    string public constant UsdaiMinatoVaultQueueName = "USDAI Minato Vault Queue V0.5";
    string public constant UsdaiMinatoVaultQueueSolverName = "USDAI Minato Vault Queue Solver V0.5";
    string public constant UsdaiMinatoLayerZeroTellerName = "USDAI Minato LayerZero Teller V0.2";
    string public constant UsdaiMinatoChainlinkCCIPTellerName = "USDAI Minato Chainlink CCIP Teller V0.0";

    // sUSDAI in minato
    string public constant sUsdaiMinatoBoringOnChainQueuesRolesAuthorityName = "sUSDAI Minato Boring OnChain Queues Roles Authority V0.5";
    string public constant sUsdaiMinatoVaultRolesAuthorityName = "sUSDAI Minato Vault RolesAuthority V0.5";
    string public constant sUsdaiMinatoArcticArchitectureLensName = "sUSDAI Minato Arctic Architecture Lens V0.5";
    string public constant sUsdaiMinatoVaultName = "sUSDAI Minato Vault V0.5";
    string public constant sUsdaiMinatoVaultManagerName = "sUSDAI Minato Vault Manager With Merkle Verification V0.5";
    string public constant sUsdaiMinatoVaultAccountantName = "sUSDAI Minato Vault Accountant With Rate Providers V0.5";
    string public constant sUsdaiMinatoVaultTellerName = "sUSDAI Minato Vault Teller With Multi Asset Support V0.5";
    string public constant sUsdaiMinatoVaultDecoderAndSanitizerName = "sUSDAI Minato Vault Decoder and Sanitizer V0.5";
    string public constant sUsdaiMinatoVaultDelayedWithdrawer = "sUSDAI Minato Vault Delayed Withdrawer V0.5";
    string public constant sUsdaiMinatoVaultQueueName = "sUSDAI Minato Vault Queue V0.5";
    string public constant sUsdaiMinatoVaultQueueSolverName = "sUSDAI Minato Vault Queue Solver V0.5";
    string public constant sUsdaiMinatoLayerZeroTellerName = "sUSDAI Minato LayerZero Teller V0.5";
    string public constant sUsdaiMinatoChainlinkCCIPTellerName = "sUSDAI Minato Chainlink CCIP Teller V0.0";

    // USDAI in sepolia
    string public constant UsdaiSepoliaBoringOnChainQueuesRolesAuthorityName = "USDAI Sepolia Boring OnChain Queues Roles Authority V0.3";
    string public constant UsdaiSepoliaVaultRolesAuthorityName = "USDAI Sepolia Vault RolesAuthority V0.3";
    string public constant UsdaiSepoliaArcticArchitectureLensName = "USDAI Sepolia Arctic Architecture Lens V0.3";
    string public constant UsdaiSepoliaVaultName = "USDAI Sepolia Vault V0.3";
    string public constant UsdaiSepoliaVaultManagerName = "USDAI Sepolia Vault Manager With Merkle Verification V0.3";
    string public constant UsdaiSepoliaVaultAccountantName = "USDAI Sepolia Vault Accountant With Rate Providers V0.3";
    string public constant UsdaiSepoliaVaultTellerName = "USDAI Sepolia Vault Teller With Multi Asset Support V0.3";
    string public constant UsdaiSepoliaVaultDecoderAndSanitizerName = "USDAI Sepolia Vault Decoder and Sanitizer V0.3";
    string public constant UsdaiSepoliaVaultDelayedWithdrawer = "USDAI Sepolia Vault Delayed Withdrawer V0.3";
    string public constant UsdaiSepoliaVaultQueueName = "USDAI Sepolia Vault Queue V0.3";
    string public constant UsdaiSepoliaVaultQueueSolverName = "USDAI Sepolia Vault Queue Solver V0.3";
    string public constant UsdaiSepoliaLayerZeroTellerName = "USDAI Sepolia LayerZero Teller V1.0";
    string public constant UsdaiSepoliaChainlinkCCIPTellerName = "USDAI Sepolia Chainlink CCIP Teller V0.0";
    // sUSDAI in sepolia
    string public constant sUsdaiSepoliaBoringOnChainQueuesRolesAuthorityName = "sUSDAI Sepolia Boring OnChain Queues Roles Authority V0.1";
    string public constant sUsdaiSepoliaVaultRolesAuthorityName = "sUSDAI Sepolia Vault RolesAuthority V0.1";
    string public constant sUsdaiSepoliaArcticArchitectureLensName = "sUSDAI Sepolia Arctic Architecture Lens V0.1";
    string public constant sUsdaiSepoliaVaultName = "sUSDAI Sepolia Vault V0.1";
    string public constant sUsdaiSepoliaVaultManagerName = "sUSDAI Sepolia Vault Manager With Merkle Verification V0.1";
    string public constant sUsdaiSepoliaVaultAccountantName = "sUSDAI Sepolia Vault Accountant With Rate Providers V0.1";
    string public constant sUsdaiSepoliaVaultTellerName = "sUSDAI Sepolia Vault Teller With Multi Asset Support V0.1";
    string public constant sUsdaiSepoliaVaultDecoderAndSanitizerName = "sUSDAI Sepolia Vault Decoder and Sanitizer V0.1";
    string public constant sUsdaiSepoliaVaultDelayedWithdrawer = "sUSDAI Sepolia Vault Delayed Withdrawer V0.1";
    string public constant sUsdaiSepoliaVaultQueueName = "sUSDAI Sepolia Vault Queue V0.1";
    string public constant sUsdaiSepoliaVaultQueueSolverName = "sUSDAI Sepolia Vault Queue Solver V0.1";
    string public constant sUsdaiSepoliaLayerZeroTellerName = "sUSDAI Sepolia LayerZero Teller V0.1";
    string public constant sUsdaiSepoliaChainlinkCCIPTellerName = "sUSDAI Sepolia Chainlink CCIP Teller V0.0";
}
