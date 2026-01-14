# Missing Persons Management System (MPMS) DApp

## Project Overview

The Missing Persons Management System (MPMS) is a Decentralized Application (DApp) built on the Ethereum blockchain. It provides a transparent, secure, and immutable platform for reporting missing persons, assigning investigators, updating case statuses, and scheduling meetings between reporters and investigators/admins.

The core logic is managed by a Solidity smart contract, ensuring that all case data and role assignments are recorded securely on the public ledger.

## Features

  * **Role-Based Access:** Defines three user roles with distinct permissions:
      * **Admin:** Can update case status (Missing/Found) and assign cases to Investigators.
      * **Reporter:** Can file new Missing Person reports and book paid appointments with Investigators/Admins.
      * **Investigator:** Can report a Found Person and view their assigned cases/schedules.
  * **Case Management:** Functions for adding new missing person reports with details (age, height, description, division) and a dynamic urgency level.
  * **Appointment System:** Allows Reporters to book appointments with other roles for in-person follow-ups (requires a payment in Ether).
  * **Data Integrity:** All reports and status updates are logged immutably on the blockchain.

## Technology Stack

| Component                 | Technology                                               | Description                                                                |
| :------------------------ | :------------------------------------------------------- | :------------------------------------------------------------------------- |
| **Smart Contract**        | Solidity (v0.8.0+)                                       | The contract language for the core business logic.                         |
| **Development Framework** | [Truffle Suite](https://trufflesuite.com/)               | Used for compiling, migrating (deploying), and testing the smart contract. |
| **Local Blockchain**      | [Ganache CLI/UI](https://trufflesuite.com/ganache/)      | A personal blockchain for local Ethereum development and testing.          |
| **Front-end**             | HTML5, CSS3, JavaScript (ES6)                            | Standard web technologies for the user interface.                          |
| **Web3 Interface**        | [Web3.js](https://web3js.readthedocs.io/)                | JavaScript library used to interact with the deployed smart contract.      |
| **Development Server**    | [lite-server](https://www.npmjs.com/package/lite-server) | A light-weight development server for serving the front-end code.          |

## Prerequisites

To set up and run this project locally, you need the following installed:

  * **Node.js & npm** (Node Package Manager) - [Download from nodejs.org](https://nodejs.org/en/download/)
  * **Truffle** - Install globally via npm:
    ``` bash
    npm install -g truffle
    
    ```
  * **Ganache** - For a local blockchain network:
      * Ganache CLI: `npm install -g ganache`
      * Ganache UI: [Download from trufflesuite.com](https://trufflesuite.com/ganache/)
  * **MetaMask Browser Extension** - To interact with the DApp (connect your browser to the local Ganache network).

## Installation and Setup

Follow these steps to deploy the smart contract and run the DApp locally.

### 1\. Clone the Repository

``` bash
git clone https://github.com/NK-II/missing-persons-dapp.git
cd MPMS-DApp

```

### 2\. Install Dependencies

Install all required Node modules for the project:

``` bash
npm install

```

### 3\. Start Ganache Local Blockchain

Start your local development blockchain using Ganache (either the UI or the CLI).

``` bash
# If using Ganache CLI
ganache

```

**Note:** Ganache will typically run on `http://127.0.0.1:8545`. Ensure your MetaMask is connected to this Custom RPC.

### 4\. Deploy the Smart Contract (Truffle Migration)

Migrate the Solidity contract to your running Ganache network:

``` bash
truffle migrate

```

If successful, Truffle will output the **deployed contract address**.

### 5\. Update the Front-end Linkage

This is the **critical manual step** that links the web interface to the blockchain.

1.  Locate the compiled ABI in the artifact file: `build/contracts/MPMS.json`. Copy the entire JSON array found under the `"abi"` key.
2.  Open the file: `src/js/web3-init.js`.
3.  **Update the Contract Address:** Replace the placeholder value for `contractAddress` with the actual address reported by the `truffle migrate` command in step 4.
4.  **Update the Contract ABI:** Replace the empty array for `contractABI` with the entire JSON ABI array you copied in step 1.

The `web3-init.js` file should look similar to this (with your values):

``` javascript
// src/js/web3-init.js

// ** Paste the address from your deployment here **
const contractAddress = "0xYourDeployedContractAddressGoesHere..."; 
 
// ** Paste the ABI array from MPMS.json here **
const contractABI = [ /* ... huge JSON array ... */ ]; 
```

## Usage

### 1\. Start the DApp

Use the `lite-server` dev script defined in `package.json` to launch the DApp:

``` bash
npm run dev

```

This will automatically open the DApp in your web browser, typically at `http://localhost:3000`.

### 2\. Interact with the DApp

1.  Ensure your **MetaMask** is unlocked and connected to your Ganache network.
2.  Use one of your Ganache accounts to **Register** on the `Register.html` page, selecting a role (**Admin**, **Reporter**, or **Investigator**).
3.  Navigate to the corresponding HTML page (`Admin.html`, `Reporter.html`, or `Investigator.html`) to perform role-specific actions.

## File Structure

``` 
.
├── build/                 # Compiled smart contract artifacts (.json files)
│   └── contracts/
│       └── MPMS.json
├── contracts/             # Solidity smart contract source code
│   └── mpms.sol           
├── migrations/            # Truffle deployment scripts
│   └── 2_deploy_contracts.js 
├── src/                   # Front-end source code
│   ├── css/               # Stylesheets (bootstrap)
│   ├── js/                # JavaScript logic (admin.js, reporter.js, web3-init.js, etc.)
│   ├── contract/
│   |   └── MPMS_ABI.json // Contract ABI (auto-generated upon compilation)
│   └── ...html            # HTML views (Admin.html, Reporter.html, Register.html)
├── package.json           # Node.js dependencies and scripts
├── package-lock.json      # Locks all dependency versions (ensures consistent setup)
├── truffle-config.js      # Truffle framework configuration
├── bs-config.json         # BrowserSync/lite-server configuration
├── .gitignore             # (Recommended: To exclude node_modules, build logs, etc.)
├── .gitattributes
└── README.md              # This file

```

