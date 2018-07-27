pragma solidity 0.4.23;


interface RaffleInterface {
    function setWinnerAndFinalize(uint256 randomNumber) external;
}
