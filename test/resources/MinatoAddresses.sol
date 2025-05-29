// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.21;

import {ERC20} from "@solmate/tokens/ERC20.sol";

contract MinatoAddresses {
    // Liquid Ecosystem
    address public deployerAddress = 0xfC77dA095A42F42b275A77346F9471354B678496;
    address public dev0Address = 0x8Ab8aEEf444AeE718A275a8325795FE90CF162c4;
    address public dev1Address = 0x8Ab8aEEf444AeE718A275a8325795FE90CF162c4;
    // address public liquidV1PriceRouter = 0x693799805B502264f9365440B93C113D86a4fFF5;
    // should be a multisig address!
    address public liquidPayoutAddress = 0x8Ab8aEEf444AeE718A275a8325795FE90CF162c4;

    // CCIP token transfers.
    address public ccipRouter = 0x443a1bce545d56E2c3f20ED32eA588395FFce0f4;

    // should be update
    // address public uniswapV3NonFungiblePositionManager = 0x655C406EBFa14EE2006250925e54ec43AD184f8B;

    // should be deployed on minato later by balancer
    // address public balancerVault = 0xBA12222222228d8Ba445958a75a0704d566BF2C8;

    ERC20 public USDC = ERC20(0xE9A198d38483aD727ABC8b0B1e16B2d338CF0391);
    ERC20 public ASTR = ERC20(0x26e6f7c7047252DdE3dcBF26AA492e6a264Db655);
    ERC20 public USDAI = ERC20(0x874bCD1AfDfb0864F9362b79B61e37b5c1c9d574);
}
