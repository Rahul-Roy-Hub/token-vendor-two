pragma solidity 0.8.20; //Do not change the solidity version as it negatively impacts submission grading
// SPDX-License-Identifier: MIT

import "@openzeppelin/contracts/access/Ownable.sol";
import "./YourToken.sol";

contract Vendor is Ownable {
    event BuyTokens(address buyer, uint256 amountOfETH, uint256 amountOfTokens);

    YourToken public yourToken;
    uint256 public constant tokensPerEth = 100;

    constructor(address tokenAddress) Ownable(msg.sender) {
        yourToken = YourToken(tokenAddress);
    }

    // Payable function to buy tokens with ETH
    // - Calculates tokens based on msg.value * tokensPerEth
    // - Checks if vendor has enough tokens
    // - Transfers tokens to buyer
    // - Emits BuyTokens event
    function buyTokens() public payable {
        require(msg.value > 0, "Must send ETH to buy tokens");
        
        uint256 amountOfTokens = msg.value * tokensPerEth;
        require(yourToken.balanceOf(address(this)) >= amountOfTokens, "Insufficient token balance in vendor");
        
        yourToken.transfer(msg.sender, amountOfTokens);
        
        emit BuyTokens(msg.sender, msg.value, amountOfTokens);
    }

    // Owner-only function to withdraw all ETH from vendor
    // - Checks if contract has ETH balance
    // - Transfers all ETH to owner
    // - Only callable by contract owner
    function withdraw() public onlyOwner {
        uint256 balance = address(this).balance;
        require(balance > 0, "No ETH to withdraw");
        
        (bool success, ) = payable(owner()).call{value: balance}("");
        require(success, "Withdrawal failed");
    }

    // Function to sell tokens back to vendor for ETH
    // - Checks if user has enough tokens
    // - Calculates ETH amount based on tokensPerEth
    // - Transfers tokens from user to vendor using transferFrom
    // - Sends ETH to user
    // - Requires user to approve vendor first
    function sellTokens(uint256 _amount) public {
        require(_amount > 0, "Amount must be greater than 0");
        require(yourToken.balanceOf(msg.sender) >= _amount, "Insufficient token balance");
        
        uint256 ethAmount = _amount / tokensPerEth;
        require(address(this).balance >= ethAmount, "Insufficient ETH balance in vendor");
        
        yourToken.transferFrom(msg.sender, address(this), _amount);
        (bool success, ) = payable(msg.sender).call{value: ethAmount}("");
        require(success, "ETH transfer failed");
    }
}
