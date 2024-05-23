// SPDX-License-Identifier: MIT
pragma solidity >=0.8.4;

/**
 * @title AaveV3Flashloan
 * @author billiedox
 * @notice flash loan token fromo Aave V3
 */


import "./interfaces/aave/IPoolAddressesProvider.sol";
import "./interfaces/aave/FlashLoanSimpleReceiverBase.sol";
import "./interfaces/IERC20.sol";

contract AaveV3Flashloan is FlashLoanSimpleReceiverBase {
    address payable owner;

    constructor(address _addressProvider)
        FlashLoanSimpleReceiverBase(IPoolAddressesProvider(_addressProvider))
    {
    }
    
        //This function is called after your contract has received the flash loaned amount

    function  executeOperation(
        address asset,
        uint256 amount,
        uint256 premium,
        address initiator,
        bytes calldata params
    )  external override returns (bool) {
        
        //Logic goes here
        
        uint256 totalAmount = amount + premium;
        IERC20(asset).approve(address(POOL), totalAmount);

        return true;
    }    

    function requestFlashLoan(
        address _token, 
        uint256 _amount
    ) public {
        address receiverAddress = address(this);
        address asset = _token;
        uint256 amount = _amount;
        bytes memory params = "";
        uint16 referralCode = 0;

        POOL.flashLoanSimple(
            receiverAddress,
            asset,
            amount,
            params,
            referralCode
        );
    }

    receive() external payable {}
}