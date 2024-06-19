// SPDX-License-Identifier: LGPL-3.0-only
pragma solidity ^0.8.24;

import "./interface/IVault.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract Vault is Ownable {
    struct Bidding {
        address bidder;
        uint256 amount;
    }

    IERC20 internal token;

    mapping(string => Bidding[]) public _biddingsBySpot;

    constructor(address _adAuction, address _moiToken) Ownable(_adAuction) {
        require(
            IERC20.totalSupply.selector ==
                IERC20(_moiToken).totalSupply.selector,
            "Not a valid ERC20 token"
        );
        token = IERC20(_moiToken);
    }

    function lock(
        string memory _adSpot,
        address _bidder,
        uint _amount
    ) external onlyOwner {
        require(token.transfer(address(this), _amount), "Transfer failed");
        _biddingsBySpot[_adSpot].push(Bidding(_bidder, _amount));
        if (_biddingsBySpot[_adSpot][0].amount < _amount) {
            _biddingsBySpot[_adSpot][0] = _biddingsBySpot[_adSpot][
                _biddingsBySpot[_adSpot].length - 1
            ];
        }
    }

    function unlock(
        string memory _adSpot
    ) external onlyOwner returns (address) {
        address highestBidder = _biddingsBySpot[_adSpot][0].bidder;
        for (uint i = 1; i < _biddingsBySpot[_adSpot].length; i++) {
            address to = _biddingsBySpot[_adSpot][i].bidder;
            uint256 amount = (_biddingsBySpot[_adSpot][i].amount * 90) / 100;
            token.transfer(to, amount);
        }
        delete _biddingsBySpot[_adSpot];

        return highestBidder;
    }
}
