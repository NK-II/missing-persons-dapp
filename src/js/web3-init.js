let web3;
let contract;

const contractAddress ="0xF2C9DD7c157D610c9941660648aD805960fC36C8" "REPLACE_WITH_DEPLOYED_CONTRACT_ADDRESS"; // e.g., 0x123...abc
const contractABI = [];

async function loadContract() {
  const response = await fetch("contract/MPMS_ABI.json");
  const data = await response.json();
  return new web3.eth.Contract(data.abi, contractAddress);
}

window.addEventListener("load", async () => {
  if (window.ethereum) {
    web3 = new Web3(window.ethereum);
    await window.ethereum.request({ method: "eth_requestAccounts" });
    contract = await loadContract();
    console.log("Web3 connected, contract loaded");
  } else {
    alert("Please install MetaMask to use this DApp");
  }
});
