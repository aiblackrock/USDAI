/**
 * @title BoringVaultSCVersion
 * @dev This contract extends the standard BoringVault with SuperChainERC20 functionality.
 * Note that SuperChainERC20 is currently in experimental phase and not production-ready.
 * This implementation serves as a test bed for evaluating the proxy upgrade mechanism
 * for the BoringVault contract architecture.
 */

// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.21;

import {Address} from "@openzeppelin/contracts/utils/Address.sol";
import {ERC721Holder} from "@openzeppelin/contracts/token/ERC721/utils/ERC721Holder.sol";
import {ERC1155Holder} from "@openzeppelin/contracts/token/ERC1155/utils/ERC1155Holder.sol";
import {FixedPointMathLib} from "@solmate/utils/FixedPointMathLib.sol";
import {SafeTransferLib} from "@solmate/utils/SafeTransferLib.sol";
import {ERC20} from "@solmate/tokens/ERC20.sol";
import {BeforeTransferHook} from "src/interfaces/BeforeTransferHook.sol";
import {Auth, Authority} from "@solmate/auth/Auth.sol";
import {ERC20Upgradeable} from "@openzeppelin/contracts-upgradeable/token/ERC20/ERC20Upgradeable.sol";
import {Initializable} from "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import {UUPSUpgradeable} from "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {IERC165} from "@openzeppelin/contracts/interfaces/IERC165.sol";
import {IERC7802} from "src/interfaces/IERC7802.sol";

contract BoringVaultSCVersion is Auth, Initializable, ERC20Upgradeable, UUPSUpgradeable, ERC721Holder, ERC1155Holder, IERC7802 {
    using Address for address;
    using SafeTransferLib for ERC20;
    using FixedPointMathLib for uint256;

    // ========================================= STATE =========================================

    /**
     * @notice Contract responsbile for implementing `beforeTransfer`.
     */
    BeforeTransferHook public hook;

    uint8 private _decimals;

    //============================== EVENTS ===============================

    event Enter(address indexed from, address indexed asset, uint256 amount, address indexed to, uint256 shares);
    event Exit(address indexed to, address indexed asset, uint256 amount, address indexed from, uint256 shares);

    //============================== ERRORS ===============================
    error NotSuperchainERC20Bridge();

    //============================== CONSTRUCTOR ===============================
    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() Auth(address(0), Authority(address(0))) {
        _disableInitializers();
    }

    function initialize(
        address _owner,
        Authority _authority,
        string memory _name,
        string memory _symbol,
        uint8 decimals_
    ) public initializer {
        __ERC20_init(_name, _symbol);
        __UUPSUpgradeable_init();
        owner = _owner;
        authority = _authority;
        _decimals = decimals_;
    }

    function _authorizeUpgrade(address newImplementation)
        internal
        override
        requiresAuth
    {}

    //============================== MANAGE ===============================

    /**
     * @notice Allows manager to make an arbitrary function call from this contract.
     * @dev Callable by MANAGER_ROLE.
     */
    function manage(address target, bytes calldata data, uint256 value)
        external
        requiresAuth
        returns (bytes memory result)
    {
        result = target.functionCallWithValue(data, value);
    }

    /**
     * @notice Allows manager to make arbitrary function calls from this contract.
     * @dev Callable by MANAGER_ROLE.
     */
    function manage(address[] calldata targets, bytes[] calldata data, uint256[] calldata values)
        external
        requiresAuth
        returns (bytes[] memory results)
    {
        uint256 targetsLength = targets.length;
        results = new bytes[](targetsLength);
        for (uint256 i; i < targetsLength; ++i) {
            results[i] = targets[i].functionCallWithValue(data[i], values[i]);
        }
    }

    //============================== ENTER ===============================

    /**
     * @notice Allows minter to mint shares, in exchange for assets.
     * @dev If assetAmount is zero, no assets are transferred in.
     * @dev Callable by MINTER_ROLE.
     */
    function enter(address from, ERC20 asset, uint256 assetAmount, address to, uint256 shareAmount)
        external
        requiresAuth
    {
        // Transfer assets in
        if (assetAmount > 0) asset.safeTransferFrom(from, address(this), assetAmount);

        // Mint shares.
        _mint(to, shareAmount);

        emit Enter(from, address(asset), assetAmount, to, shareAmount);
    }

    //============================== EXIT ===============================

    /**
     * @notice Allows burner to burn shares, in exchange for assets.
     * @dev If assetAmount is zero, no assets are transferred out.
     * @dev Callable by BURNER_ROLE.
     */
    function exit(address to, ERC20 asset, uint256 assetAmount, address from, uint256 shareAmount)
        external
        requiresAuth
    {
        // Burn shares.
        _burn(from, shareAmount);

        // Transfer assets out.
        if (assetAmount > 0) asset.safeTransfer(to, assetAmount);

        emit Exit(to, address(asset), assetAmount, from, shareAmount);
    }

    //============================== BEFORE TRANSFER HOOK ===============================
    /**
     * @notice Sets the share locker.
     * @notice If set to zero address, the share locker logic is disabled.
     * @dev Callable by OWNER_ROLE.
     */
    function setBeforeTransferHook(address _hook) external requiresAuth {
        hook = BeforeTransferHook(_hook);
    }

    /**
     * @notice Call `beforeTransferHook` passing in `from` `to`, and `msg.sender`.
     */
    function _callBeforeTransfer(address from, address to) internal view {
        if (address(hook) != address(0)) hook.beforeTransfer(from, to, msg.sender);
    }

    function transfer(address to, uint256 amount) public override returns (bool) {
        _callBeforeTransfer(msg.sender, to);
        return super.transfer(to, amount);
    }

    function transferFrom(address from, address to, uint256 amount) public override returns (bool) {
        _callBeforeTransfer(from, to);
        return super.transferFrom(from, to, amount);
    }

    //============================== SuperChainERC20 ===============================

    /// @notice Allows the SuperchainTokenBridge to mint tokens.
    /// @param _to Address to mint tokens to.
    /// @param _amount Amount of tokens to mint.
    function crosschainMint(address _to, uint256 _amount) external {
        if (msg.sender != 0x4200000000000000000000000000000000000028) revert NotSuperchainERC20Bridge();
 
        _mint(_to, _amount);
 
        emit CrosschainMint(_to, _amount, msg.sender);
    }
 
    /// @notice Allows the SuperchainTokenBridge to burn tokens.
    /// @param _from Address to burn tokens from.
    /// @param _amount Amount of tokens to burn.
    function crosschainBurn(address _from, uint256 _amount) external {
        if (msg.sender != 0x4200000000000000000000000000000000000028) revert NotSuperchainERC20Bridge();
        
        _burn(_from, _amount);
 
        emit CrosschainBurn(_from, _amount, msg.sender);
    }

    // /// @inheritdoc IERC165
    // function supportsInterface(bytes4 _interfaceId) public view virtual returns (bool) {
    //     return _interfaceId == type(IERC7802).interfaceId || _interfaceId == type(IERC20).interfaceId
    //         || _interfaceId == type(IERC165).interfaceId;
    // }

    //============================== RECEIVE ===============================

    receive() external payable {}

    function decimals() public view override returns (uint8) {
        return _decimals;
    }
}
