pragma solidity 0.4.23;

import "./SafeMath.sol";
import "./DrawRandomNumber.sol";


// @dev SharesRaffle smart contract
// the more wei user sends wei to the contract the more chances she has to win the raffle
contract SharesRaffle {
    using SafeMath for uint256;

    uint256 public openTime;
    uint256 public closeTime;
    uint256 public goal;
    address public escrowWallet;
    bytes32 public randomNumQueryId;

    struct Entry {
        address buyer;
        uint256 cap;
    }

    Entry[] public entries;

    uint256 public totalWei;
    bool public isFinalized;
    address public raffleWinner;

    DrawRandomNumber public drawRandomNumber;

    event LogWinner(address indexed winnerAddress, string typeOfWinning, uint256 timestamp);

    constructor
        (
            uint256 _openTime,
            uint256 _closeTime,
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
            _goal != 0 &&
            _escrowWallet != address(0)
        );

        openTime = _openTime;
        closeTime = _closeTime;
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

    function submitEntry()
        public
        withinRafflePeriod
        payable
    {
        require(!isFinalized && msg.value > 0);

        totalWei = totalWei.add(msg.value);
        // Forward funds to escrow
        escrowWallet.transfer(msg.value);

        entries.push(Entry({buyer: msg.sender, cap: totalWei.sub(1)}));

        if (totalWei >= goal) {
            finalize();
        }
    }

    function finalize() public {
        require(now > closeTime || totalWei >= goal);
        require(!isFinalized);

        requestRandomNumber();
    }

    function setWinnerAndFinalize(uint256 winningNumber)
        public
        onlyDrawRandomNumberContract
    {
        require(raffleWinner == address(0));

        raffleWinner = findWinner(winningNumber);
        emit LogWinner(raffleWinner, "Main Prize", now);
        isFinalized = true;
    }

    function findWinner(uint256 winningNumber) internal view returns(address) {
        uint256 range = entries.length / 2;
        uint256 currentIndex = range;
        while (true) {
            if (range / 2 != 0) {
                range = range / 2;
            }
            if (currentIndex == 0) {
                break;
            } else if (entries[currentIndex].cap < winningNumber) {
                // Jump right
                currentIndex += range;
            } else {
                if (entries[currentIndex - 1].cap < winningNumber) {
                    break;
                } else {
                    // Jump left
                    currentIndex -= range;
                }
            }
        }
        return entries[currentIndex].buyer;
    }

    function requestRandomNumber() internal {
        if (totalWei > 0)
            randomNumQueryId = drawRandomNumber.generateRandomNum(entries.length, this);
    }
}
