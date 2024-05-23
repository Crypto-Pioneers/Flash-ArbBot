// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

/**
 * @title EqualizerFlashloan
 * @author billiedox
 * @notice flash loan token from Equalizer
 */

import "./interfaces/equalizer/IERC3156FlashBorrower.sol";
import "./interfaces/equalizer/IERC3156FlashLender.sol";

contract EqualizerFlashloan is IERC3156FlashBorrower {
    
    address public equalizerProvider;

    constructor(
        address _equalizerProvider
    ) {
        equalizerProvider = _equalizerProvider;
    }

    function onFlashLoan (
        address _initiator,
        address _token,
        uint256 _amount,
        uint256 _fee,
        bytes calldata
    ) external override returns (bytes32) {
        return keccak256('ERC3156FlashBorrower.onFlashLoan');
    }

    function requestFlashLoan (
        address _borrowToken,
        uint _amount,
        bytes calldata data
    ) public {
        require(_amount > 0, "Amount cannot be 0");
        require(_borrowToken != address(0), "Invalid token address");
        IERC3156FlashLender(equalizerProvider).flashLoan(
            IERC3156FlashBorrower(address(this)),
            _borrowToken,
            _amount,
            data
        );
    }


}