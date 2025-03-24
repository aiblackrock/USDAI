// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.21;

import {ERC20} from "@solmate/tokens/ERC20.sol";

contract MinatoAddresses {
    // Liquid Ecosystem
    address public deployerAddress = 0xEd56Ece1D50Ee955a33dB586D79cDaCadC1BE0a5;
    address public dev0Address = 0x8Ab8aEEf444AeE718A275a8325795FE90CF162c4;
    address public dev1Address = 0x8Ab8aEEf444AeE718A275a8325795FE90CF162c4;
    address public liquidV1PriceRouter = 0x693799805B502264f9365440B93C113D86a4fFF5;
    // should be a multisig address!
    address public liquidPayoutAddress = 0x8Ab8aEEf444AeE718A275a8325795FE90CF162c4;

    // should be update
    address public uniswapV3NonFungiblePositionManager = 0x655C406EBFa14EE2006250925e54ec43AD184f8B;

    // should be deployed on minato later by balancer
    // address public balancerVault = 0xBA12222222228d8Ba445958a75a0704d566BF2C8;

    ERC20 public USDC = ERC20(0xE9A198d38483aD727ABC8b0B1e16B2d338CF0391);
}
