// SPDX-License-Identifier: LGPL-3.0-only
pragma solidity ^0.8.24;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./Vault.sol";
// import "hardhat/console.sol";

contract AdAuction is Ownable {
    string[] public _adSpots;
    Vault private _vault;

    modifier onlyValidAdSpot(string calldata _adSpot) {
        for (uint i = 0; i < _adSpots.length; i++) {
            require(
                keccak256(abi.encodePacked(_adSpots[i])) ==
                    keccak256(abi.encodePacked(_adSpot)),
                "Ad spot does not exist"
            );
        }
        _;
    }

    constructor(address _vaultaddr) Ownable((msg.sender)) {
        _vault = Vault(_vaultaddr);
    }

    function createAdStop(string calldata _adSpot) external onlyOwner {
        _adSpots.push(_adSpot);
    }

    function deleteAdLocation(string calldata _adSpot) external onlyOwner {
        // _vault.unlock(_adSpot); highest bidder는 unlock 되지 않음

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

    function bidAtAuction(
        string calldata _adSpot,
        uint256 _amount
    ) external onlyValidAdSpot(_adSpot) {
        _vault.lock(_adSpot, msg.sender, _amount);
    }

    function pickHighestBidder(string memory _adSpot) external onlyOwner {
        _vault.unlock(_adSpot);
    }
}
