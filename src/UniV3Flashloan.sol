// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "./interfaces/uniswap/v3/IUniswapV3Pool.sol";
import "./interfaces/uniswap/v3/IUniswapV3Factory.sol";
import "./interfaces/IERC20.sol";

contract UniV3Flashloan {

    struct FlashCallbackData {
        uint256 amount0;
        uint256 amount1;
        address caller;
    }

    IUniswapV3Pool private pool;
    IUniswapV3Factory private uniswapV3Factory;
    address private WETH;
    address private USDT;
    IERC20 private token0;
    IERC20 private token1;

    constructor(
        address _uniswapV3Factory,
        address _wethAddress,
        address _usdtAddress

    ) {
        WETH = _wethAddress;
        USDT = _usdtAddress;
        uniswapV3Factory = IUniswapV3Factory(_uniswapV3Factory);
    }

    function requestFlashLoan(
        address _borrowToken,
        uint256 _amount
    ) public {
        bytes memory data = abi.encode(
            FlashCallbackData({
                amount0: 0,
                amount1: _amount,
                caller: msg.sender
            })
        );

        address poolAddress;
        if (_borrowToken == WETH) {
            poolAddress = uniswapV3Factory.getPool(WETH, _borrowToken, 3000);
        } else {
            poolAddress = uniswapV3Factory.getPool(USDT, _borrowToken, 3000);
        }        
        pool = IUniswapV3Pool(poolAddress);
        token0 = IERC20(pool.token0());
        token1 = IERC20(pool.token1());
        uint256 amt0;
        uint256 amt1;
        if(pool.token0() == _borrowToken) {
            amt0 = _amount;
            amt1 = 0;
        } else {
            amt0 = 0;
            amt1 = _amount;
        }
        pool.flash(address(this), amt0, amt1, data);
    }

    function uniswapV3FlashCallback(
        uint256 fee0,
        uint256 fee1,
        bytes calldata data
    ) external {
        require(msg.sender == address(pool), "Not authorized");

        FlashCallbackData memory decoded = abi.decode(data, (FlashCallbackData));
        if(fee0 > 0) {
            // logic
        }

        if(fee1 > 0) {
            // logic
        }

        // Repay borrow
        if (fee0 > 0) {
            token0.transfer(address(pool), decoded.amount0 + fee0);
        }
        if (fee1 > 0) {
            token1.transfer(address(pool), decoded.amount1 + fee1);
        }
    }



}