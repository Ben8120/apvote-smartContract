var ElectionCon = artifacts.require("./ElectionCon.sol");

module.exports = function(deployer) {
    deployer.deploy(ElectionCon);
};