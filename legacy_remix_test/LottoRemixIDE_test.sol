pragma solidity 0.6.12;

// This import is automatically injected by Remix
import "remix_tests.sol";

// This import is required to use custom transaction context
// Although it may fail compilation in 'Solidity Compiler' plugin
// But it will work fine in 'Solidity Unit Testing' plugin
import "remix_accounts.sol";
import "./LottoMock.sol";
import "../contracts/Lotto.sol";

// this style of inheriting from the class under test allows for impersonating senders but causes issues when checking the contract balance (because the test context adds value)
contract lottoEntranceTestWithInheritance is Lotto {

    /// #value: 5000000000000000
    function enterSuccessfullySingleEntrantInheritVersion() public payable {
        Assert.equal(getQuantityOfEntrants(), uint256(0), "expecting 0 entrants before entering");
        Assert.equal(getLotteryBalance(), uint256(5000000000000000), "expecting 0 lottery balance before entering"); //this seems like an oddity with how the custom txn context is implemented with inheritance

        this.enter{value:5000000000000000}();

        Assert.equal(getLotteryBalance(), uint256(5000000000000000), "expecting lottery balance equal to entrance fee after entering");  //this seems like an oddity with how the custom txn context is implemented with inheritance
        Assert.equal(getQuantityOfEntrants(), uint256(1), "user should have successfully entered the lottery");
    }
}

// this style works for checking contract balance but doesn't let you properly impersonate multiple senders
contract LottoEntranceTestNoInherit {
    Lotto lotto;

    function beforeEach() public {
        lotto = new Lotto();
    }

    /// #value: 5000000000000000
    function enterSuccessfullySingleEntrant() public payable {
        Assert.equal(lotto.getQuantityOfEntrants(), uint256(0), "expecting 0 entrants before entering");
        Assert.equal(lotto.getLotteryBalance(), uint256(0), "expecting 0 lottery balance before entering");

        lotto.enter{value:5000000000000000}();

        Assert.equal(lotto.getLotteryBalance(), uint256(5000000000000000), "expecting lottery balance equal to entrance fee after entering");
        Assert.equal(lotto.getQuantityOfEntrants(), uint256(1), "user should have successfully entered the lottery");
    }

    // when: fee too much -> then: return money, don't enter
    /// #value: 6000000000000000
    function enterEntryFeeExceedsRequirement() public payable {
        Assert.equal(lotto.getQuantityOfEntrants(), uint256(0), "expecting 0 entrants before entering");
        Assert.equal(lotto.getLotteryBalance(), uint256(0), "expecting 0 lottery balance before entering");

        try lotto.enter{value:6000000000000000}() {
            Assert.ok(false, 'succeed unexpected');
        } catch Error(string memory reason) {
            Assert.equal(reason, "Invalid entry fee provided.", "It should fail due to invalid entry fee.");
        } catch (bytes memory /*lowLevelData*/) {
            Assert.ok(false, 'failed unexpected');
        }

        Assert.equal(lotto.getLotteryBalance(), uint256(0), "expecting lottery balance equal to entrance fee after entering");
        Assert.equal(lotto.getQuantityOfEntrants(), uint256(0), "user should not have successfully entered the lottery");
    }

    // when: fee too little -> then: return money, don't enter
    /// #value: 1000
    function enterEntryFeeTooLittle() public payable {
        Assert.equal(lotto.getQuantityOfEntrants(), uint256(0), "expecting 0 entrants before entering");
        Assert.equal(lotto.getLotteryBalance(), uint256(0), "expecting 0 lottery balance before entering");


        try lotto.enter{value:1000}() {
            Assert.ok(false, 'succeed unexpected');
        } catch Error(string memory reason) {
            Assert.equal(reason, "Invalid entry fee provided.", "It should fail due to invalid entry fee.");
        } catch (bytes memory ) {
            Assert.ok(false, 'failed unexpected');
        }

        Assert.equal(lotto.getLotteryBalance(), uint256(0), "expecting lottery balance equal to entrance fee after entering");
        Assert.equal(lotto.getQuantityOfEntrants(), uint256(0), "user should have successfully entered the lottery");
    }

    // when already entered -> then: return money, don't enter
    /// #value: 10000000000000000
    function enterAlreadyEntered() public payable {
        Assert.equal(lotto.getQuantityOfEntrants(), uint256(0), "expecting 0 entrants before entering");
        Assert.equal(lotto.getLotteryBalance(), uint256(0), "expecting 0 lottery balance before entering");
        lotto.enter{value:5000000000000000}();
        Assert.equal(lotto.getLotteryBalance(), uint256(5000000000000000), "expecting lottery balance equal to entrance fee after entering");
        Assert.equal(lotto.getQuantityOfEntrants(), uint256(1), "user should have successfully entered the lottery");


        try lotto.enter{value:5000000000000000}() {
            Assert.ok(false, 'succeed unexpected');
        } catch Error(string memory reason) {
            Assert.equal(reason, "User has already entered. Only one entry allowed per address.", "Expected failure, user has already entered.");
        } catch (bytes memory ) {
            Assert.ok(false, 'failed unexpected');
        }

        Assert.equal(lotto.getLotteryBalance(), uint256(5000000000000000), "Lottery balance should be unchanged after failed entry");
        Assert.equal(lotto.getQuantityOfEntrants(), uint256(1), "User has already entered, only expecting 1 entrant.");
    }
}

//inherit from Lotto to test multiple senders functionality
contract LottoMultipleEntranceTest is Lotto {

    /// #sender: account-0
    /// #value: 5000000000000000
    function firstEntry() public payable {
        Assert.equal(getQuantityOfEntrants(), uint256(0), "expecting 0 entrants before entering");
        Assert.equal(msg.sender, TestsAccounts.getAccount(0), "Invalid sender");

        enter();

        Assert.equal(getQuantityOfEntrants(), uint256(1), "user should have successfully entered the lottery");
    }

    /// #value: 5000000000000000
    /// #sender: account-1
    function secondEntry() public payable {
        Assert.equal(getQuantityOfEntrants(), uint256(1), "Expecting an existing entry.");
        Assert.equal(msg.sender, TestsAccounts.getAccount(1), "Invalid sender");

        //don't call function externally to use sender mocking
        enter();

        Assert.equal(getQuantityOfEntrants(), uint256(2), "second user should have successfully entered the lottery");
    }
}

//test that require inheriting from a mock object to manually change the state of contract under test
contract EnterWinnerAlreadySelected is LottoMock {

    // lottery already completed -> then: return money, don't enter
    /// #value: 5000000000000000
    function enterWinnerAlreadySelected() public payable {
        Assert.equal(getQuantityOfEntrants(), uint256(0), "expecting 0 entrants before entering");
        setWinner();

        try this.enter{value:5000000000000000}() {
            Assert.ok(false, 'succeed unexpected');
        } catch Error(string memory reason) {
            Assert.equal(reason, "Lottery has already completed. A winner was already selected.", "Lottery already completed. User cannot enter.");
        } catch (bytes memory ) {
            Assert.ok(false, 'failed unexpected');
        }

        Assert.equal(getQuantityOfEntrants(), uint256(0),
            "If a winner was already selected, there should not be any new entrants");
    }
}

contract EnterWinnerSelectionInProgress is LottoMock {

    // winner selection in progress -> then: return money, don't enter
    /// #value: 5000000000000000
    function enterWinnerSelectionInProgress() public payable {
        Assert.equal(getQuantityOfEntrants(), uint256(0), "expecting 0 entrants before entering");
        setProvableQueryId(); //TODO is there a better way for this

        try this.enter{value:5000000000000000}() {
            Assert.ok(false, 'succeed unexpected');
        } catch Error(string memory reason) {
            Assert.equal(reason, "Winner selection already in progress. No entries allowed now.", "Cannot enter lottery when winner selection is in progress.");
        } catch (bytes memory) {
            Assert.ok(false, 'failed unexpected');
        }

        Assert.equal(this.getQuantityOfEntrants(), uint256(0), "user should have successfully entered the lottery");
    }
}