const Lotto = artifacts.require("Lotto");

module.exports = async function (deployer, network, accounts) {
  // deployment steps
  await deployer.deploy(Lotto);
};