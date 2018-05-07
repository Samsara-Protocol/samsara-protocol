pragma solidity 0.4.23;

import "./Raffle.sol";


contract DrawRandomNumberMock {
    struct Data {
        address raffleContractAddress;
        uint256 maxRange;
        bool isValid;
        uint256 randomNumber;
    }

    mapping (bytes32 => Data) public raffleData;

    // mock __callback
    function __callback(bytes32 _queryId, string _result) public
    {
        require(raffleData[_queryId].isValid);

        // this is an efficient way to get the uint out in the [0, maxRange) range
        uint256 randomNumber = uint(keccak256(_result)) % raffleData[_queryId].maxRange;

        raffleData[_queryId].randomNumber = randomNumber;
        Raffle(raffleData[_queryId].raffleContractAddress).setWinnerAndFinalize(randomNumber);
    }

    // mock generateRandomNum
    function generateRandomNum(uint256 _maxRange, address _raffleContractAddress) public payable returns(bytes32) {
        uint256 hardCodedResult = 30;
        // create a mock query id
        bytes32 queryId = keccak256(hardCodedResult);

        raffleData[queryId].raffleContractAddress = _raffleContractAddress;
        raffleData[queryId].maxRange = _maxRange;
        raffleData[queryId].isValid = true;

        __callback(queryId, '30');

        return queryId;
    }
}
