// SPDX-License-Identifier: LGPL-3.0-only
pragma solidity ^0.8.24;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./Vault.sol";
import "hardhat/console.sol";

contract AdAuction is Ownable {
    string[] public _adSpots;
    Vault private _vault;

    function isSpotExist(string calldata _adSpot) public view returns (bool) {
        bool isExist;
        for (uint i = 0; i < _adSpots.length; i++) {
            if (
                keccak256(abi.encodePacked(_adSpots[i])) ==
                keccak256(abi.encodePacked(_adSpot))
            ) {
                isExist = true;
            }
        }
        return isExist;
    }

    constructor(address _vaultaddr) Ownable((msg.sender)) {
        _vault = Vault(_vaultaddr);
    }

    function createAdSpot(string calldata _adSpot) public onlyOwner {
        require(!isSpotExist(_adSpot), "Ad spot already exist");
        _adSpots.push(_adSpot);
    }

    function deleteAdSpot(string calldata _adSpot) public onlyOwner {
        require(isSpotExist(_adSpot), "Ad spot does not exist");

        for (uint i = 0; i < _adSpots.length; i++) {
            if (
                keccak256(abi.encodePacked(_adSpots[i])) ==
                keccak256(abi.encodePacked(_adSpot))
            ) {
                _adSpots[i] = _adSpots[_adSpots.length - 1];
                _adSpots.pop();
                break;
            }
        }
    }

    function submitBid(string calldata _adSpot, uint256 _amount) public {
        require(isSpotExist(_adSpot), "Ad spot does not exist");
        _vault.submitBid(_adSpot, msg.sender, _amount);
    }

    function cancelBid(string calldata _adSpot) public {
        require(isSpotExist(_adSpot), "Ad spot does not exist");
        _vault.cancelBid(_adSpot, msg.sender);
    }

    function encreaseBid(string calldata _adSpot, uint256 _amount) public {
        require(isSpotExist(_adSpot), "Ad spot does not exist");
        _vault.encreaseBid(_adSpot, msg.sender, _amount);
    }

    function decreaseBid(string calldata _adSpot, uint256 _amount) public {
        require(isSpotExist(_adSpot), "Ad spot does not exist");
        _vault.decreaseBid(_adSpot, msg.sender, _amount);
    }
}
