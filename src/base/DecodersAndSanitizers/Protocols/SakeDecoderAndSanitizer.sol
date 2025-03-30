// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.21;

import {AaveV3DecoderAndSanitizer} from "src/base/DecodersAndSanitizers/Protocols/AaveV3DecoderAndSanitizer.sol";
import {BaseDecoderAndSanitizer} from "src/base/DecodersAndSanitizers/BaseDecoderAndSanitizer.sol";

contract SakeDecoderAndSanitizer is AaveV3DecoderAndSanitizer {
    /**
     * @notice Constructor for SakeDecoderAndSanitizer
     * @param _boringVault The address of the BoringVault contract
     */
    constructor(address _boringVault) BaseDecoderAndSanitizer(_boringVault) {}
}