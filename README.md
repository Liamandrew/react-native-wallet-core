# react-native-wallet-core

A react native wrapper around Trust Wallet Core for Android and iOS

## Installation

```sh
npm install react-native-wallet-core
```

## Currencies Supported

Currently the only currency supported with this wrapper is **Ethereum**. There will be more coming in the future.

## Usage

```js
import TrustWalletCore from "react-native-wallet-core";

// Create a new wallet
const { mnemonic, seed } = await TrustWalletCore.createWallet(128, "");

// Import a wallet from mnemonic phrase. Will also load into local memory
const { mnemonic, seed } = await TrustWalletCore.importWalletFromMnemonic("ripple scissors kick mammal hire column oak again sun offer wealth tomorrow wagon turn fatal", "");

// Import a wallet from hexString. Will also load into local memory
const { mnemonic, seed } = await TrustWalletCore.importWalletFromHexString("<HEX_STRING>", "");

// Generate the default address for coin
const address = await TrustWalletCore.getAddressForCoin("ethereum");

// Generate address using custom derivation path
const { address, privateKey } = await TrustWalletCore.deriveAddressForCoin("ethereum", "m/44'/60'/1'/0/0");

// Sign a transaction
const { r, s, v, encoded, hashValue } = await TrustWalletCore.signTransactionForCoin("ethereum", {
    chainID: "0x01",
    amount: "0x0348bca5a16000",
    nonce: "0x00",
    toAddress: "0xC37054b3b48C3317082E7ba872d7753D13da4986",
    privateKeyDerivationPath: "m/44'/60'/1'/0/0", // optional - otherwise default address is used
});

```

## Contributing

See the [contributing guide](CONTRIBUTING.md) to learn how to contribute to the repository and the development workflow.

## License

MIT
