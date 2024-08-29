// SPDX-License-Identifier: LGPL-3.0-only
pragma solidity ^0.8.24;

import "./interface/IVault.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract Vault is Ownable {
    IERC20 internal token;
    address public adAuction;
    uint public _round;

    mapping(string => mapping(address => uint))[] public _biddingsBySpot;
    mapping(uint => mapping(string => bool)) public _finalizedChecker;

    event Submitted(
        uint indexed round,
        string adSpot,
        address indexed bidder,
        uint amount
    );

    event Canceled(uint indexed round, string adSpot, address indexed bidder);

    event Encreased(
        uint indexed round,
        string adSpot,
        address indexed bidder,
        uint amount
    );

    event Decreased(
        uint indexed round,
        string adSpot,
        address indexed bidder,
        uint amount
    );

    event Finalized(uint round, string adSpot, address indexed bidder);

    modifier onlyAdAuction() {
        require(msg.sender == adAuction, "Only AdAuction contract can call");
        _;
    }

    constructor(address _moiToken) Ownable(msg.sender) {
        require(
            IERC20.totalSupply.selector ==
                IERC20(_moiToken).totalSupply.selector,
            "Not a valid ERC20 token"
        );
        token = IERC20(_moiToken);
        _biddingsBySpot.push();
    }

    function setAdAuction(address _adAuction) public onlyOwner {
        adAuction = _adAuction;
    }

    function newRound() public onlyOwner {
        _biddingsBySpot.push();
        _round++;
    }

    function submitBid(
        string memory _adSpot,
        address _bidder,
        uint _amount
    ) public onlyAdAuction {
        require(
            token.balanceOf(_bidder) >= _amount,
            "Insufficient token balance"
        );
        _biddingsBySpot[_round][_adSpot][_bidder] += _amount;
        emit Submitted(_round, _adSpot, _bidder, _amount);
    }

    function cancelBid(
        string memory _adSpot,
        address _bidder
    ) public onlyAdAuction {
        delete _biddingsBySpot[_round][_adSpot][_bidder];
        emit Canceled(_round, _adSpot, _bidder);
    }

    function encreaseBid(
        string memory _adSpot,
        address _bidder,
        uint _amount
    ) public onlyAdAuction {
        require(_biddingsBySpot[_round][_adSpot][_bidder] >= 0, "not locked");
        _biddingsBySpot[_round][_adSpot][_bidder] += _amount;
        emit Encreased(_round, _adSpot, _bidder, _amount);
    }

    function decreaseBid(
        string memory _adSpot,
        address _bidder,
        uint _amount
    ) public onlyAdAuction {
        require(
            _biddingsBySpot[_round][_adSpot][_bidder] >= _amount,
            "overdrawn amount"
        );
        _biddingsBySpot[_round][_adSpot][_bidder] -= _amount;
        emit Decreased(_round, _adSpot, _bidder, _amount);
    }

    function finalizeBidPayment(
        uint _targetRound,
        string memory _adSpot,
        address _approvedTopBidder
    ) public onlyOwner returns (bool) {
        require(!_finalizedChecker[_targetRound][_adSpot], "Already finalized");

        uint _bidderAmt = _biddingsBySpot[_targetRound][_adSpot][
            _approvedTopBidder
        ];

        require(
            token.balanceOf(_approvedTopBidder) >= _bidderAmt,
            "Insufficient token balance"
        );
        require(
            token.allowance(_approvedTopBidder, address(this)) >= _bidderAmt,
            "approve token first"
        );
        require(
            token.transferFrom(_approvedTopBidder, address(this), _bidderAmt),
            "transfer failed"
        );

        emit Finalized(_targetRound, _adSpot, _approvedTopBidder);
        _finalizedChecker[_targetRound][_adSpot] = true;
        return true;
    }
}
