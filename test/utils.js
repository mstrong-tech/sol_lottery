/* eslint no-await-in-loop: "off" */

const Web3 = require('web3');

const sleep = (ms) => new Promise((res) => setTimeout(res, ms));

module.exports.waitForEvent = async (eventName, contract) => {
  let events = await contract.getPastEvents(eventName, { fromBlock: 0, toBlock: 'latest' });
  let secondCounter = 0;
  while (events.length < 1) {
    console.log(`waiting for event ${secondCounter}`);
    await sleep(1000);
    secondCounter += 1;
    events = await contract.getPastEvents(eventName, { fromBlock: 0, toBlock: 'latest' });
    if (secondCounter > 30) {
      assert(false, `Timed out waiting for event: ${eventName}`);
    }
  }
};

module.exports.validEntryValue = Web3.utils.toWei('5000000', 'gwei');
