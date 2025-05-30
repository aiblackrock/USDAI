// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.21;

import {BaseDecoderAndSanitizer, DecoderCustomTypes} from "src/base/DecodersAndSanitizers/BaseDecoderAndSanitizer.sol";

contract KyoDecoderAndSanitizer is BaseDecoderAndSanitizer {
    address public immutable kyoRouter;

    // Kyo ExactInputSingleParams struct
    struct ExactInputSingleParams {
        address tokenIn;
        address tokenOut;
        uint24 fee;
        address recipient;
        uint256 deadline;
        uint256 amountIn;
        uint256 amountOutMinimum;
        uint160 sqrtPriceLimitX96;
    }

    constructor(address _boringVault, address _kyoRouter) BaseDecoderAndSanitizer(_boringVault) {
        kyoRouter = _kyoRouter;
    }

    /**
     * @notice Decoder and sanitizer for Kyo exactInputSingle swap
     * @param params The swap parameters
     * @return addressesFound The addresses that need to be validated
     */
    function exactInputSingle(ExactInputSingleParams calldata params) 
        external 
        view 
        returns (bytes memory addressesFound) 
    {
        // Validate that the recipient is either the boring vault or a valid address
        require(
            params.recipient == boringVault || params.recipient != address(0), 
            "KyoDecoderAndSanitizer: Invalid recipient"
        );

        // Return all relevant addresses that need to be in the merkle tree
        addressesFound = abi.encodePacked(
            params.tokenIn,    // Input token address
            params.tokenOut,   // Output token address  
            params.recipient  // Recipient address
        );
    }
}
