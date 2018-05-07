pragma solidity 0.4.23;

import "./OraclizeAPI.sol";
import "./Raffle.sol";


contract DrawRandomNumber is usingOraclize {
    event NewRandomNumberBytes(bytes);
    event NewRandomNumberUint(uint);
    event LogProof(bytes proof);

    struct Data {
        address raffleContractAddress;
        uint256 maxRange;
        bool isValid;
        uint256 randomNumber;
    }

    mapping (bytes32 => Data) public raffleData;

    // the callback function is called by Oraclize when the result is ready
    // the oraclize_randomDS_proofVerify modifier prevents an invalid proof to execute this function code:
    // the proof validity is fully verified on-chain
    function __callback(bytes32 _queryId, string _result, bytes _proof) public
    {
        require(msg.sender == oraclize_cbAddress() && raffleData[_queryId].isValid);

        // this is an efficient way to get the uint out in the [0, maxRange) range
        uint256 randomNumber = uint(keccak256(_result)) % raffleData[_queryId].maxRange;

        NewRandomNumberBytes(bytes(_result)); // this is the resulting random number (bytes)
        NewRandomNumberUint(randomNumber); // this is the resulting random number (uint)
        LogProof(_proof);

        raffleData[_queryId].randomNumber = randomNumber;
        Raffle(raffleData[_queryId].raffleContractAddress).setWinnerAndFinalize(randomNumber);
    }

    function generateRandomNum(uint256 _maxRange, address _raffleContractAddress) public payable returns(bytes32) {
        oraclize_setProof(proofType_Ledger); // sets the Ledger authenticity proof
        uint n = 4; // number of random bytes we want the datasource to return
        uint delay = 0; // number of seconds to wait before the execution takes place
        uint callbackGas = 200000; // amount of gas we want Oraclize to set for the callback function

        // this function internally generates the correct oraclize_query and returns its queryId
        bytes32 queryId = oraclize_newRandomDSQuery(delay, n, callbackGas);

        raffleData[queryId].raffleContractAddress = _raffleContractAddress;
        raffleData[queryId].maxRange = _maxRange;
        raffleData[queryId].isValid = true;

        return queryId;
    }
}
