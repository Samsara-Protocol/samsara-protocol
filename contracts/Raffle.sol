pragma solidity 0.4.23;

import "./SafeMath.sol";
import "./DrawRandomNumber.sol";


// @dev Raffle smart contract - contains all business logic
contract Raffle {
    using SafeMath for uint256;

    uint256 public openTime;
    uint256 public closeTime;
    uint256 public ticketPrice;
    uint256 public goal;
    address public escrowWallet;

    address[] public ticketHolders;
    bool public isFinalized;
    address public raffleWinner;
    bytes32 public randomNumQueryId;

    mapping (address => uint256[]) public buyerTickets;
    DrawRandomNumber public drawRandomNumber;

    event LogTicketsPurchased(address indexed buyer, uint256 numberOfTickets, uint256 price, uint256 timestamp);
    event LogWinner(address indexed winnerAddress, string typeOfWinning, uint256 timestamp);

    constructor
        (
            uint256 _openTime,
            uint256 _closeTime,
            uint256 _ticketPrice,
            uint256 _goal,
            address _escrowWallet,
            address _drawRandomNumber
        )
        public
    {
        require(
            _openTime != 0 &&
            _closeTime != 0 &&
            _closeTime > _openTime &&
            _ticketPrice != 0 &&
            _goal != 0 &&
            _escrowWallet != address(0) &&
            _drawRandomNumber != address(0)
        );

        openTime = _openTime;
        closeTime = _closeTime;
        ticketPrice = _ticketPrice;
        goal = _goal;
        escrowWallet = _escrowWallet;

        drawRandomNumber = DrawRandomNumber(_drawRandomNumber);
    }

    modifier withinRafflePeriod() {
        require(now <= closeTime && now >= openTime);
        _;
    }

    modifier onlyDrawRandomNumberContract() {
        require(msg.sender == address(drawRandomNumber));
        _;
    }

    modifier isElegibleToBeFinalized() {
        require(weiRaised() >= goal || now > closeTime);
        require(!isFinalized && raffleWinner == address(0));
        _;
    }

    function purchaseTickets(uint256 numberOfTickets)
        public
        withinRafflePeriod
        payable
    {
        require(msg.value == numberOfTickets.mul(ticketPrice));
        require(!isFinalized && msg.value > 0);

        for (uint256 i; i < numberOfTickets; i++) {
            ticketHolders.push(msg.sender);
            buyerTickets[msg.sender].push(ticketHolders.length);
        }

        emit LogTicketsPurchased(msg.sender, numberOfTickets, msg.value, now);

        //forward funds to escrow
        escrowWallet.transfer(msg.value);
    }

    function weiRaised() public view returns(uint256) {
        return ticketHolders.length.mul(ticketPrice);
    }

    function ticketsSold() public view returns(uint256) {
        return ticketHolders.length;
    }

    function ticketsPurchasesBy(address buyer) public view returns(uint256[]) {
        return buyerTickets[buyer];
    }

    function allTicketHolders() public view returns(address[]) {
        return ticketHolders;
    }

    function setWinnerAndFinalize(uint256 randomNumber)
        public
        onlyDrawRandomNumberContract
    {
        require(raffleWinner == address(0));

        // random number returns between 0 and ticketsSold - 1
        raffleWinner = ticketHolders[randomNumber];
        emit LogWinner(raffleWinner, "Main Prize", now);
        isFinalized = true;
    }

    function requestRandomNumber() public isElegibleToBeFinalized {
        if (ticketsSold() > 0)
            randomNumQueryId = drawRandomNumber.generateRandomNum(ticketsSold(), this);
    }

}
