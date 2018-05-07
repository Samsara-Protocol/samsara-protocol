# Samsara Protocol

This box comes with everything you need to start using smart contracts from a react app. This is as barebones as it gets, so nothing stands in your way.

## Rinkeby Contracts

### DrawRandomNumber Contract Address

`0xfe4e621fc53b27ed020f0d35397dd6a90a3f42df`

[https://rinkeby.etherscan.io/address/0xfe4e621fc53b27ed020f0d35397dd6a90a3f42df](https://rinkeby.etherscan.io/address/0xfe4e621fc53b27ed020f0d35397dd6a90a3f42df)

### Raffle Contract Address

* 10 wei ticket price and 100 wei goal: 0x9694a1a5132397df30ec95502d6fcc3d00ab3f2e
  [https://rinkeby.etherscan.io/address/0x9694a1a5132397df30ec95502d6fcc3d00ab3f2e](https://rinkeby.etherscan.io/address/0x9694a1a5132397df30ec95502d6fcc3d00ab3f2e)
* 0.0001 ETH ticket price and 1 ether goal: 0x9dc353492872014cc9c2985a0824df43b55c8cab
  [https://rinkeby.etherscan.io/address/0x9dc353492872014cc9c2985a0824df43b55c8cab](https://rinkeby.etherscan.io/address/0x9dc353492872014cc9c2985a0824df43b55c8cab)

* 0.1 ETH ticket price and 1 ether goal: 0xf58a9079b3d9f63a7135afca82f81b3d0f119897
  [https://rinkeby.etherscan.io/address/0xf58a9079b3d9f63a7135afca82f81b3d0f119897](https://rinkeby.etherscan.io/address/0xf58a9079b3d9f63a7135afca82f81b3d0f119897)

* 0.1 ETH ticket price and 1 ether goal: 0x7C51030DB238D61848A0d9112c236d7C8ca98b09
  [https://rinkeby.etherscan.io/address/0x7C51030DB238D61848A0d9112c236d7C8ca98b09](https://rinkeby.etherscan.io/address/0x7C51030DB238D61848A0d9112c236d7C8ca98b09)

### Raffle ABI

`[{"constant":true,"inputs":[],"name":"ticketPrice","outputs":[{"name":"","type":"uint256"}],"payable":false,"stateMutability":"view","type":"function"},{"constant":true,"inputs":[],"name":"goal","outputs":[{"name":"","type":"uint256"}],"payable":false,"stateMutability":"view","type":"function"},{"constant":true,"inputs":[],"name":"raffleWinner","outputs":[{"name":"","type":"address"}],"payable":false,"stateMutability":"view","type":"function"},{"constant":true,"inputs":[],"name":"closeTime","outputs":[{"name":"","type":"uint256"}],"payable":false,"stateMutability":"view","type":"function"},{"constant":true,"inputs":[],"name":"isFinalized","outputs":[{"name":"","type":"bool"}],"payable":false,"stateMutability":"view","type":"function"},{"constant":true,"inputs":[],"name":"escrowWallet","outputs":[{"name":"","type":"address"}],"payable":false,"stateMutability":"view","type":"function"},{"constant":true,"inputs":[{"name":"","type":"uint256"}],"name":"ticketHolders","outputs":[{"name":"","type":"address"}],"payable":false,"stateMutability":"view","type":"function"},{"constant":true,"inputs":[],"name":"openTime","outputs":[{"name":"","type":"uint256"}],"payable":false,"stateMutability":"view","type":"function"},{"constant":true,"inputs":[],"name":"drawRandomNumber","outputs":[{"name":"","type":"address"}],"payable":false,"stateMutability":"view","type":"function"},{"inputs":[{"name":"_openTime","type":"uint256"},{"name":"_closeTime","type":"uint256"},{"name":"_ticketPrice","type":"uint256"},{"name":"_goal","type":"uint256"},{"name":"_escrowWallet","type":"address"},{"name":"_drawRandomNumber","type":"address"}],"payable":false,"stateMutability":"nonpayable","type":"constructor"},{"constant":false,"inputs":[{"name":"numberOfTickets","type":"uint256"}],"name":"purchaseTickets","outputs":[],"payable":true,"stateMutability":"payable","type":"function"},{"constant":true,"inputs":[],"name":"weiRaised","outputs":[{"name":"","type":"uint256"}],"payable":false,"stateMutability":"view","type":"function"},{"constant":true,"inputs":[],"name":"ticketsSold","outputs":[{"name":"","type":"uint256"}],"payable":false,"stateMutability":"view","type":"function"},{"constant":true,"inputs":[],"name":"allTicketHolders","outputs":[{"name":"","type":"address[]"}],"payable":false,"stateMutability":"view","type":"function"},{"constant":false,"inputs":[{"name":"randomNumber","type":"uint256"}],"name":"setWinnerAndFinalize","outputs":[],"payable":false,"stateMutability":"nonpayable","type":"function"},{"constant":false,"inputs":[],"name":"requestRandomNumber","outputs":[],"payable":false,"stateMutability":"nonpayable","type":"function"}]`

## Installation

1. Install Truffle globally.

   ```javascript
   npm install -g truffle
   ```

2. Run the development blockchain.

   ```javascript
   npm test
   ```

3. Compile and migrate the smart contracts. Note inside the development console we don't preface commands with `truffle`.

   ```javascript
   truffle compile
   truffle migrate
   ```

