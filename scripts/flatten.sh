#!/usr/bin/env bash

rm -rf flats/*

truffle-flattener contracts/Raffle.sol > flats/Raffle.sol
truffle-flattener contracts/SharesRaffle.sol > flats/SharesRaffle.sol
truffle-flattener contracts/DrawRandomNumber.sol > flats/DrawRandomNumber.sol
