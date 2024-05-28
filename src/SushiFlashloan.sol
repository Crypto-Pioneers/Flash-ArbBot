// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

interface IBentoBox {
    function flashLoan(
        address borrower,
        address receiver,
        address token,
        uint256 amount,
        bytes calldata data
    ) external;
}

interface IFlashBorrower {
    function onFlashLoan(
        address sender,
        address token,
        uint256 amount,
        uint256 fee,
        bytes calldata data
    ) external returns (bytes32);
}

contract SushiFlashloan is IFlashBorrower, Ownable {
    address private bentoBoxAddress;
    IBentoBox private bentoBox;

    constructor(address _bentoBoxAddress) {
        bentoBoxAddress = _bentoBoxAddress;
        bentoBox = IBentoBox(bentoBoxAddress);
    }

    function requestFlashLoan(
        address token,
        uint256 amount,
        bytes calldata _data
    ) external onlyOwner {
        bentoBox.flashLoan(address(this), address(this), token, amount, _data);
    }

    function onFlashLoan(
        address sender,
        address token,
        uint256 amount,
        uint256 fee,
        bytes calldata data
    ) external override returns (bytes32) {
        require(msg.sender == bentoBoxAddress, "Unauthorized");

        // Your logic here: arbitrage, liquidation, etc.

        // Repay the flash loan
        uint256 totalRepayment = amount + fee;
        IERC20(token).transfer(bentoBoxAddress, totalRepayment);

        return keccak256("IFlashBorrower.onFlashLoan");
    }
}
