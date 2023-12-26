// SPDX-License-Identifier: MIT
pragma solidity 0.8.4;  //Do not change the solidity version as it negativly impacts submission grading

import "hardhat/console.sol";
import "./ExampleExternalContract.sol";
pragma solidity ^0.8.0;

// Interface for the external contract
interface IExampleExternalContract {
    function complete() external payable;
    function withdraw(uint256 tokenId) external;
}

contract Staker {
    // Define the Stake event
    event Stake(address indexed staker, uint256 amount);

    // Define a mapping to track balances
    mapping(address => uint256) public balances;

    // Define the threshold and deadline
    uint256 public threshold;
    uint256 public deadline;

    // Define the external contract
    IExampleExternalContract public exampleExternalContract;

    constructor(uint256 _threshold, uint256 _deadline, address _exampleExternalContract) {
        threshold = _threshold;
        deadline = _deadline;
        exampleExternalContract = IExampleExternalContract(_exampleExternalContract);
    }

    // Define the stake function
    function stake() public payable {
        // Update the sender's balance
        balances[msg.sender] += msg.value;

        // Emit the Stake event
        emit Stake(msg.sender, msg.value);
    }

    function execute() public {
        // Check if the deadline has passed and the threshold is met
        require(block.timestamp >= deadline, "Deadline has not passed");
        require(address(this).balance >= threshold, "Threshold not met");

        // Call the complete function in the external contract
        exampleExternalContract.complete{value: address(this).balance}();
    }

    function withdraw() public {
        // Check if the deadline has passed and the threshold is not met
        require(block.timestamp >= deadline, "Deadline has not passed");
        require(address(this).balance < threshold, "Threshold met, cannot withdraw");

        // Require that the sender has a balance
        require(balances[msg.sender] > 0, "No balance to withdraw");

        // Update the user's balance prior to sending them the funds to prevent reentrancy attacks
        uint256 balance = balances[msg.sender];
        balances[msg.sender] = 0;

        // Send the funds to the user
        (bool sent, ) = msg.sender.call{value: balance}("");
        require(sent, "Failed to send Ether");
    }
}