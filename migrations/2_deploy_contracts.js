// requiring the contract
var mpms = artifacts.require("./MPMS.sol");

// exporting as module 
 module.exports = function(deployer) {
  deployer.deploy(mpms);
 };

