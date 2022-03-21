# solidity-lottery
### Running Tests
This project contains two sets of tests, one using the
[Unit Testing Plugin for Remix IDE](https://remix-ide.readthedocs.io/en/latest/unittesting.html)
(tests located in `legacy_remix_test/`)
while the other uses the [Truffle Suite](https://github.com/trufflesuite/truffle) (tests located in `test/`)
#### In truffle
1. Install [nvm](https://github.com/nvm-sh/nvm)
2. Switch to the correct node version 

`nvm use`
3. Install the npm dependencies

`npm install`
4. Install Truffle globally

`npm install -g truffle`
5. Start the truffle blockchain environment locally

`truffle develop`
6. In a second command prompt, start the provable bridge within the truffle development environment

`npm run bridge`

7. The previous command will give a result similar to this:

```
Please add this line to your contract constructor:

OAR = OraclizeAddrResolverI(0x6f485C8BF6fc43eA212E93BBF8ce046C7f1cb475);
```
Following those instructions, copy the second line into line `Lotto.sol` constructor and ensure it's uncommented

8. In the first terminal window, where you previously ran `truffle develop`, run `test`

##### In REMIX IDE

1. Go to [https://remix.ethereum.org/](https://remix.ethereum.org/)
2. Copy Files
    1. Copy `contracts/Lotto.sol` into a remix workspace at `contracts/Lotto.sol`
    2. Copy `legacy_remix_test/LottoRemixIDE_test.sol` into a remix workspace at `tests/LottoRemixIDE_test.sol`
    3. Copy `legacy_remix_test/LottoMock.sol` into a remix workspace at `tests/LottoMock.sol`
3. Run tests: Navigate to `tests/LottoRemixIDE_test.sol` in a remix workspace. On the left side of the IDE there is a unit testing panel (two checkmarks). Click `run` within that panel.

# Future Enhancements

1. Convert into a Trufflebox for truffle and a separate repo for remix to simplify use
2. Switch to using Chainlink as an Oracle
3. Restrict who can kick-off the winner selection functionality (or put on a timer)