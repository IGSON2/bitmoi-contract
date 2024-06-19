// SPDX-License-Identifier: LGPL-3.0-only
pragma solidity ^0.8.24;

interface IVault {
    function lock(uint256 _amount) external;
    function unlock(uint256 _amount) external;
}
