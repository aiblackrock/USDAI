// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.21;

import {BaseDecoderAndSanitizer, DecoderCustomTypes} from "src/base/DecodersAndSanitizers/BaseDecoderAndSanitizer.sol";

contract OpenEdenDecoderAndSanitizer is BaseDecoderAndSanitizer {
    constructor(address _boringVault) BaseDecoderAndSanitizer(_boringVault) {}
    function instantMint(address underlying, address to, uint256) 
        external 
        pure 
        virtual 
        returns (bytes memory addressesFound)
    {
        addressesFound = abi.encodePacked(underlying, to);
    }

    function instantRedeem(address to, uint256) 
        external 
        pure 
        virtual 
        returns (bytes memory addressesFound)
    {
        addressesFound = abi.encodePacked(to);
    }
}
