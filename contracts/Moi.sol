// SPDX-License-Identifier: LGPL-3.0-only
pragma solidity ^0.8.24;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/introspection/ERC165.sol";

contract Moi is ERC20, ERC165 {
    bytes4 public constant _INTERFACE_ID_ERC20 = type(IERC20).interfaceId;

    constructor(uint256 _totalSupply) ERC20("Moi token", "MOI") {
        _mint(msg.sender, _totalSupply);
    }
}
