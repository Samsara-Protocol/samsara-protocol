const BigNumber = web3.BigNumber;

const should = require('chai')
    .use(require('chai-as-promised'))
    .use(require('chai-bignumber')(BigNumber))
    .should();

function isException(error) {
    let strError = error.toString();
    return (
        strError.includes('invalid opcode') ||
        strError.includes('invalid JUMP') ||
        strError.includes('revert')
    );
}

function ensuresException(error) {
    assert(isException(error), error.toString());
}

module.exports = {
    should,
    ensuresException
};
