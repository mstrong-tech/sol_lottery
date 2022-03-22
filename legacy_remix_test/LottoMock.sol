pragma solidity 0.6.12;

import "../contracts/Lotto.sol";

contract LottoMock is Lotto {
    function setWinner() public {
        winner = msg.sender;
    }
    
    function setProvableQueryId() public {
        provableQueryId = bytes32("abc");
    }
}