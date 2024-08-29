// SPDX-License-Identifier: LGPL-3.0-only
pragma solidity ^0.8.24;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract Moi is ERC20, Ownable {
    struct Winner {
        address winner;
        uint amount;
    }

    constructor(
        uint256 _totalSupply
    ) ERC20("Moi token", "MOI") Ownable(msg.sender) {
        _mint(msg.sender, _totalSupply);
    }

    function SendReward(bytes calldata encodedWinners) public onlyOwner {
        Winner[] memory winners = abi.decode(encodedWinners, (Winner[]));
        for (uint256 i = 0; i < winners.length; i++) {
            transfer(winners[i].winner, winners[i].amount);
        }
    }
}
