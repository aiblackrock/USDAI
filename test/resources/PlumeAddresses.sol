// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.21;

import {ERC20} from "@solmate/tokens/ERC20.sol";

contract PlumeAddresses {
    // Liquid Ecosystem
    address public deployerAddress = 0x62165b41138c5841c0a54137E6470FBfEdd18a2e;
    address public dev0Address = 0x8Ab8aEEf444AeE718A275a8325795FE90CF162c4;
    address public dev1Address = 0x8Ab8aEEf444AeE718A275a8325795FE90CF162c4;
    // address public liquidV1PriceRouter = 0x693799805B502264f9365440B93C113D86a4fFF5;
    // should be a multisig address!
    address public liquidPayoutAddress = 0x8Ab8aEEf444AeE718A275a8325795FE90CF162c4;

    // CCIP token transfers.
    address public ccipRouter = 0x5e5Fd4720E1CE826138D043aF578D69f48af502F;

    // should be update
    // address public uniswapV3NonFungiblePositionManager = 0x655C406EBFa14EE2006250925e54ec43AD184f8B;

    ERC20 public PUSD = ERC20(0x1E0E030AbCb4f07de629DCCEa458a271e0E82624);
    ERC20 public USDAI = ERC20(0x1C6DfA6C99d83aE8b872C32119575ce24407767C);
}
