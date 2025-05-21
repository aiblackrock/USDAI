// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.21;

import {BaseDecoderAndSanitizer, DecoderCustomTypes} from "src/base/DecodersAndSanitizers/BaseDecoderAndSanitizer.sol";

interface IMorphoRouter {
    function adapters(uint256) external view returns (address);
}

interface IMorphoAdapter {
    function depositToken() external view returns (address);
}

contract MorphoDecoderAndSanitizer is BaseDecoderAndSanitizer {
    address public immutable morphoRouter;

    constructor(address _boringVault, address _morphoRouter) BaseDecoderAndSanitizer(_boringVault) {
        morphoRouter = _morphoRouter;
    }

    function deposit(uint256 adapterId, uint256)
        external
        view
        virtual
        returns (bytes memory addressesFound)
    {
        address adapter = IMorphoRouter(morphoRouter).adapters(adapterId);
        address depositToken = IMorphoAdapter(adapter).depositToken();
        addressesFound = abi.encodePacked(depositToken);
    }
    
    function withdraw(uint256 adapterId)
        external
        view
        virtual
        returns (bytes memory addressesFound)
    {
        address adapter = IMorphoRouter(morphoRouter).adapters(adapterId);
        address depositToken = IMorphoAdapter(adapter).depositToken();
        addressesFound = abi.encodePacked(depositToken);
    }
}
