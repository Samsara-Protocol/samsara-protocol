const SharesRaffle = artifacts.require('./SharesRaffle.sol');
const DrawRandomNumberMock = artifacts.require('./DrawRandomNumberMock.sol');

const { should, ensuresException } = require('./helpers/utils');
const expect = require('chai').expect;
const { latestTime, duration, increaseTimeTo } = require('./helpers/timer');

const BigNumber = web3.BigNumber;

contract('SharesRaffle', function([owner, buyer1, buyer2, escrowWallet]) {
    const purchaseAmount = new BigNumber(1000);
    const goal = new BigNumber(100e17);

    let raffle, weiRaised, drawRandomNumberContract;
    let openTime, closeTime;

    const newRaffle = goal => {
        // crowdsale starts in 20 seconds
        openTime = latestTime() + duration.seconds(20);
        closeTime = openTime + duration.days(60);

        return DrawRandomNumberMock.new().then(drawRandomNumberMockInstance => {
            drawRandomNumberContract = drawRandomNumberMockInstance;
            return SharesRaffle.new(
                openTime,
                closeTime,
                goal,
                escrowWallet,
                drawRandomNumberContract.address
            );
        });
    };

    beforeEach('setup contract', async () => {
        raffle = await newRaffle(goal);
    });

    describe('initial values', () => {
        it('has an openTime', async () => {
            const raffleOpenTime = await raffle.openTime();
            raffleOpenTime.should.be.bignumber.equal(openTime);
        });

        it('has a closeTime', async () => {
            const raffleCloseTime = await raffle.closeTime();
            raffleCloseTime.should.be.bignumber.equal(closeTime);
        });

        it('has a goal', async () => {
            const raffleGoal = await raffle.goal();
            raffleGoal.should.be.bignumber.equal(goal);
        });

        it('has an escrowWallet', async () => {
            const raffleEscrowWallet = await raffle.escrowWallet();
            raffleEscrowWallet.should.be.bignumber.equal(escrowWallet);
        });

        it('has reference to the drawRandomNumber contract', async () => {
            const drawRandomNumber = await raffle.drawRandomNumber();
            drawRandomNumber.should.be.equal(drawRandomNumberContract.address);
        });
    });

    describe('ticket purchases', async () => {
        it('must not allow entering raffle before and after the raffle timeframe', async () => {
            // The raffle will start 20 seconds in the future
            try {
                await raffle.submitEntry({ value: purchaseAmount });
                assert.fail();
            } catch (error) {
                ensuresException(error);
            }
            weiRaised = await raffle.totalWei();
            weiRaised.should.be.bignumber.equal(0);

            // Move the current time 65 days in the future to be after raffle end
            await increaseTimeTo(latestTime() + duration.days(65));
            try {
                await raffle.submitEntry({ value: purchaseAmount });
                assert.fail();
            } catch (error) {
                ensuresException(error);
            }
            weiRaised = await raffle.totalWei();
            weiRaised.should.be.bignumber.equal(0);
        });

        it('does NOT allow buyers to send an incorrect amount for the purchase', async () => {
            await increaseTimeTo(latestTime() + duration.seconds(50));

            try {
                await raffle.submitEntry({ value: 0 });
                assert.fail();
            } catch (error) {
                ensuresException(error);
            }
            weiRaised = await raffle.totalWei();
            weiRaised.should.be.bignumber.equal(0);
        });

        it('must NOT allow to enter raffle after goal has been reached', async () => {
            // Increase time 50 seconds to ensure we are within raffle period
            await increaseTimeTo(latestTime() + duration.seconds(50));

            // Force goal to be reached
            await raffle.submitEntry({ value: goal });

            try {
                await raffle.submitEntry({ value: 1 });
                assert.fail();
            } catch (error) {
                ensuresException(error);
            }
            weiRaised = await raffle.totalWei();
            weiRaised.should.be.bignumber.equal(goal);
        });

        it('allows user to enter raffle for one wei', async () => {
            await increaseTimeTo(latestTime() + duration.seconds(50));

            await raffle.submitEntry({
                value: 1,
                from: buyer1
            });
            weiRaised = await raffle.totalWei();
            weiRaised.should.be.bignumber.equal(1);
        });

        it('allows user to enter raffle for greater amount', async () => {
            await increaseTimeTo(latestTime() + duration.seconds(50));

            await raffle.submitEntry({ value: 10 });
            weiRaised = await raffle.totalWei();
            weiRaised.should.be.bignumber.equal(10);
        });

        it('allows user to enter raffle multiple times', async () => {
            await increaseTimeTo(latestTime() + duration.seconds(50));

            await raffle.submitEntry({
                value: 1,
                from: buyer1
            });
            weiRaised = await raffle.totalWei();
            weiRaised.should.be.bignumber.equal(1);

            await raffle.submitEntry({
                value: 1,
                from: buyer1
            });
            weiRaised = await raffle.totalWei();
            weiRaised.should.be.bignumber.equal(2);
        });

        it('transfer funds to escrowWallet - no funds should be in the raffle contract', async () => {
            await increaseTimeTo(latestTime() + duration.seconds(50));
            const escrowWalletBalanceBefore = await web3.eth.getBalance(
                escrowWallet
            );

            await raffle.submitEntry({ value: 10 });
            weiRaised = await raffle.totalWei();
            weiRaised.should.be.bignumber.equal(10);

            // Ensure there is no wei left in the raffle contract
            const weiInsideRaffleContract = await web3.eth.getBalance(
                raffle.address
            );
            weiInsideRaffleContract.should.be.bignumber.equal(0);

            // All fund should be in escrow wallet
            const escrowWalletBalanceAfter = await web3.eth.getBalance(
                escrowWallet
            );
            escrowWalletBalanceAfter.should.be.bignumber.equal(
                escrowWalletBalanceBefore.add(weiRaised)
            );
        });
    });

    describe('raffle finalization', () => {
        it('cannot finalize once it has already been finalized', async () => {
            await increaseTimeTo(latestTime() + duration.seconds(50));

            await raffle.submitEntry({
                value: 1,
                from: buyer1
            });

            await raffle.submitEntry({
                value: 1,
                from: buyer1
            });

            await increaseTimeTo(latestTime() + duration.days(65));
            await raffle.finalize();

            const isFinalized = await raffle.isFinalized();
            isFinalized.should.be.true;

            // Try finalizing again
            try {
                await raffle.finalize();
                assert.fail();
            } catch (e) {
                ensuresException(e);
            }
        });

        it('is NOT finalized before reaching the goal or before the end time', async () => {
            await increaseTimeTo(latestTime() + duration.seconds(50));

            await raffle.submitEntry({ value: 1 });

            try {
                await raffle.finalize();
                assert.fail();
            } catch (e) {
                ensuresException(e);
            }
            const isFinalized = await raffle.isFinalized();
            isFinalized.should.be.false;
        });

        it('there is no winner when no one has participated in the raffle', async () => {
            await increaseTimeTo(latestTime() + duration.days(65));
            await raffle.finalize();

            const winner = await raffle.raffleWinner();
            winner.should.be.equal(
                '0x0000000000000000000000000000000000000000'
            );

            const isFinalized = await raffle.isFinalized();
            isFinalized.should.be.false;
        });

        it('finalizes and has a winner if only 1 person enters', async () => {
            await increaseTimeTo(latestTime() + duration.seconds(50));

            await raffle.submitEntry({
                value: 21,
                from: buyer2
            });
            await raffle.submitEntry({
                value: 9,
                from: buyer2
            });
            await raffle.submitEntry({
                value: 1000,
                from: buyer2
            });

            await increaseTimeTo(latestTime() + duration.days(65));
            await raffle.finalize();

            const winner = await raffle.raffleWinner();
            winner.should.be.equal(buyer2);

            const isFinalized = await raffle.isFinalized();
            isFinalized.should.be.true;
        });

        it('finalizes and has a winner if only 1 person enters only once', async () => {
            await increaseTimeTo(latestTime() + duration.seconds(50));

            await raffle.submitEntry({
                value: 31,
                from: buyer2
            });
            await increaseTimeTo(latestTime() + duration.days(65));
            await raffle.finalize();

            const winner = await raffle.raffleWinner();
            winner.should.be.equal(buyer2);

            const isFinalized = await raffle.isFinalized();
            isFinalized.should.be.true;
        });

        it('finalizes and has a winner', async () => {
            await increaseTimeTo(latestTime() + duration.seconds(50));

            await raffle.submitEntry({
                value: 1,
                from: buyer1
            });
            await raffle.submitEntry({
                value: 4,
                from: buyer1
            });
            await raffle.submitEntry({
                value: 10,
                from: buyer1
            });
            await raffle.submitEntry({
                value: 1000,
                from: buyer2
            });

            await increaseTimeTo(latestTime() + duration.days(65));
            await raffle.finalize();

            const isFinalized = await raffle.isFinalized();
            isFinalized.should.be.true;
        });

        it('finalizes and has a winner if first entry wins', async () => {
            await increaseTimeTo(latestTime() + duration.seconds(50));

            await raffle.submitEntry({
                value: 31,
                from: buyer1
            });
            await raffle.submitEntry({
                value: 4,
                from: buyer2
            });
            await raffle.submitEntry({
                value: 10,
                from: buyer2
            });
            await raffle.submitEntry({
                value: 1000,
                from: buyer2
            });

            await increaseTimeTo(latestTime() + duration.days(65));
            await raffle.finalize();

            const winner = await raffle.raffleWinner();
            winner.should.be.equal(buyer1);

            const isFinalized = await raffle.isFinalized();
            isFinalized.should.be.true;
        });
    });
});
