// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.21;

import {BaseDecoderAndSanitizer, DecoderCustomTypes} from "src/base/DecodersAndSanitizers/BaseDecoderAndSanitizer.sol";

contract AcrossDecoderAndSanitizer is BaseDecoderAndSanitizer {
    constructor(address _boringVault) BaseDecoderAndSanitizer(_boringVault) {}
    function depositV3(
        address depositor,
        address recipient,
        address inputToken,
        address outputToken,
        uint256,
        uint256,
        uint256,
        address exclusiveRelayer,
        uint32,
        uint32,
        uint32,
        bytes calldata 
    )
        external
        pure
        virtual
        returns (bytes memory addressesFound)
    {
        // Collect all address-type arguments into the output
        addressesFound = abi.encodePacked(
            depositor,
            recipient,
            inputToken,
            outputToken,
            exclusiveRelayer
        );
    }
}
