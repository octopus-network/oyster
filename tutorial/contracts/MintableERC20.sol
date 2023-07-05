// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract MintableERC20 is ERC20, Ownable {
    constructor() ERC20("Mintable ERC 20", "MERC") {}

    uint256 public constant MAX_TO_MINT = 1000 ether;

    event PurchaseOccurred(address minter, uint256 amount);
    error MustMintOverZero();
    error MintRequestOverMax();
    error FailedToSendEtherToOwner();

    /**Purchases some of the token with native gas currency. */
    function purchaseMint() external payable {
        // Calculate amount to mint
        uint256 amountToMint = msg.value;

        // Check for no errors
        if (amountToMint == 0) revert MustMintOverZero();
        if (amountToMint + totalSupply() > MAX_TO_MINT)
            revert MintRequestOverMax();

        // Send to owner
        (bool success, ) = owner().call{value: msg.value}("");
        if (!success) revert FailedToSendEtherToOwner();

        // Mint to user
        _mint(msg.sender, amountToMint);
        emit PurchaseOccurred(msg.sender, amountToMint);
    }
}
