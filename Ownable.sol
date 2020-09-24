pragma solidity ^0.6.12;

// SPDX-License-Identifier: GPL-3.0

/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */
contract President {
    address public president;


    event PresidentshipTransferred(address indexed previousPresident, address indexed newPresident);


    /**
     * @dev The Ownable constructor sets the original `owner` of the contract to the sender
     * account.
     */
    constructor() public {
        president = msg.sender;
    }


    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyPresident() {
        require(msg.sender == president, "Not authorized operation");
        _;
    }



    function transferPresidenceship(address newPresident) public onlyPresident {
        require(newPresident != address(0), "Address shouldn't be zero");
        emit PresidentshipTransferred(president, newPresident);
        president = newPresident;
    }

}