// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "./interfaces/uniswap/v2/IUniswapV2Callee.sol";
import "./interfaces/uniswap/v2/IUniswapV2Factory.sol";
import "./interfaces/uniswap/v2/IUniswapV2Pair.sol";
import "./interfaces/IERC20.sol";

contract UniV2Flashloan is IUniswapV2Callee {
    address private constant WETH = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;
    address private constant UNISWAP_V2_FACTORY = 0x8909Dc15e40173Ff4699343b6eB8132c65e18eC6;
    IUniswapV2Factory private constant factory = IUniswapV2Factory(UNISWAP_V2_FACTORY);
    IERC20 private constant weth = IERC20(WETH);
    IUniswapV2Pair private pair;
    uint256 public amountToRepay;
    
    function requestFlashLoan(
        address _borrowToken,
        uint256 _amount,
        bytes calldata _data
    ) public {
        pair = IUniswapV2Pair(factory.getPair(WETH, _borrowToken));
        bytes memory data = abi.encode(_borrowToken, msg.sender);
        pair.swap(0, _amount, address(this), data);
    }

    function uniswapV2Call(
        address _sender,
        uint256 _amount0,
        uint256 _amount1,
        bytes calldata data
    ) external override {
        require(msg.sender == address(pair), "Invalid caller");
        require(_sender == address(this), "Invalid sender");

        (address borrowToken, address caller) = abi.decode(data, (address, address));
        uint256 fee = (_amount1 * 3) / 997 + 1;
        amountToRepay = _amount1 + fee;

        // logic

        IERC20(borrowToken).transfer(address(pair), amountToRepay);
    }
}