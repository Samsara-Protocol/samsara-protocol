pragma solidity 0.4.23;


interface DrawRandomNumberInterface {
    function generateRandomNum(uint256 _maxRange, address _raffleContractAddress) external payable returns(bytes32);
}
