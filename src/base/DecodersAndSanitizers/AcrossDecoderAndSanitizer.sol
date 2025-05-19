// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.21;

import {BaseDecoderAndSanitizer, DecoderCustomTypes} from "src/base/DecodersAndSanitizers/BaseDecoderAndSanitizer.sol";

interface IAcrossPool {
    function enabledDepositRoutes(address token, uint256 chainId) external view returns (bool);
}

contract AcrossDecoderAndSanitizer is BaseDecoderAndSanitizer {
    address public immutable acrossPool;

    constructor(address _boringVault, address _acrossPool) BaseDecoderAndSanitizer(_boringVault) {
        acrossPool = _acrossPool;
    }

    function depositV3(
        address depositor,
        address recipient,
        address inputToken,
        address outputToken,
        uint256,
        uint256,
        uint256 destinationChainId,
        address exclusiveRelayer,
        uint32,
        uint32,
        uint32,
        bytes calldata 
    )
        external
        view
        virtual
        returns (bytes memory addressesFound)
    {
        require(
            IAcrossPool(acrossPool).enabledDepositRoutes(inputToken, destinationChainId),
            "Route not enabled"
        );

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
