# Sample Hardhat Project

This project demonstrates a basic Hardhat use case. It comes with a sample contract, a test for that contract, and a Hardhat Ignition module that deploys that contract.


## Step 1 - Creating Hardhat project

Try this command

```shell
npx hardhat init
```

### Important File
When Hardhat is run, it searches for the closest hardhat.config.js file.
The Empty hardhat.config.js is enough for Hardhat to work. The entirety of your setup is contained in this file.

## Step 2 - Compile smart contract

Try this command

```shell
npx hardhat compile
```

This command creates or updates the ``artifacts/`` and ``cache/`` directories.

### 1.  ``artifacts/`` 
📌 Purpose: Stores compiled smart contracts and metadata.

### Files Inside ``artifacts/``
- ``artifacts/contracts/MyContract.sol/MyContract.json``

This file contains:
- __ABI (Application Binary Interface)__ – Required for interacting with the contract.
- __Bytecode__ – The compiled contract code that gets deployed on Ethereum.
- __Metadata__ – Compiler version, source files, dependencies.

✅ __Why is it important?__

- ABI is needed to interact with the contract from the frontend (React, Next.js, etc.).
- Bytecode is required for deployment.

### 2. ``cache/`` Folder
📌 Purpose: Speeds up compilation by storing cached contract data.

### Files Inside ``cache/``
Stores temporary build artifacts to prevent recompiling unchanged contracts.

If you delete it, Hardhat will recompile everything from scratch next time.

✅ Why is it important?
- Makes compiling faster.
- Helps with incremental builds.


## Step 3 - Test smart contract

Try this command

```shell
npx hardhat test
```

Hardhart provides local environment to test smart contract. For example it provides multiple accounts so by using it, we could test to send token from one account(i.e one wallet) to another.

## Step 4 - Deploy smart contract

### Deploy on testnet
#### First, start a local Ethereum blockchain for development and testing purposes. It is part of the Hardhat development environment for smart contracts.

Try this command
```shell
npx hardhat node
```
- Starts a local Ethereum network that mimics a real blockchain.
- Provides pre-funded accounts for testing.
- Saves state, so transactions persist as long as it's running.

#### Next deploy contract by using ignition

Try this command
```shell
npx hardhat ignition deploy ignition/modules/NFT.js --network <network_name>
```
If a version of the contract has already been deployed on that __network__.

Try this command
```shell
npx hardhat ignition deploy ignition/modules/NFT.js --network <network_name> --rest
```

About the network name, you can retrieve that from harthat.config.js file.

### Deploy real net
Try this command
```shell
npx hardhat run
```


Try running some of the following tasks:

```shell
npx hardhat help
npx hardhat test
REPORT_GAS=true npx hardhat test
npx hardhat node
npx hardhat ignition deploy ./ignition/modules/Lock.js
```
