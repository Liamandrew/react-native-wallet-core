# react-native-wallet-core

A React Native wrapper around the Trust Wallet Core wallet library for Android and iOS.

For more information about the underlying library, please read the comprehensive documentation provided by Trust Wallet [here.](https://developer.trustwallet.com/wallet-core)

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
```

## Full Documentation

<br />

>**createWallet(strength, passphrase)**

Creates a new wallet.

* `strength` *number* - Strength of the secret seed. Possible options are 128 or 256.
* `passphrase` *string (optional)* - Used to scramble the seed
* **Returns**
    *  `mnemonic` *string* - the recovery phrase of the wallet
    *  `seed` *string* - hex seed of the wallet. Can also be used to import.

```typescript
const { mnemonic, seed } = await TrustWalletCore.createWallet(128, "");
```

<br />

>**importWalletFromMnemonic(mnemonic, passphrase)**

Import a wallet from a mnemonic recovery phrase. This will also load the wallet into local memory so that it can be used for creating addresses and/or signing transactions.

* `mnemonic` *string* - Recovery phrase
* `passphrase` *string (optional)* - The passphrase used when creating the wallet (if applicable)
* **Returns**
    *  `mnemonic` *string* - the recovery phrase of the wallet
    *  `seed` *string* - hex seed of the wallet. Can also be used to import.

```typescript
const { mnemonic, seed } = await TrustWalletCore.importWalletFromMnemonic("ripple scissors kick mammal hire column oak again sun offer wealth tomorrow wagon turn fatal", "");
```

<br />

>**importWalletFromHexString(hexString, passphrase)**

Import a wallet from a hexString seed. This will also load the wallet into local memory so that it can be used for creating addresses and/or signing transactions.

* `hexString` *string* - The hex string seed
* `passphrase` *string (optional)* - The passphrase used when creating the wallet (if applicable)
* **Returns**
    *  `mnemonic` *string* - the recovery phrase of the wallet
    *  `seed` *string* - hex seed of the wallet. Can also be used to import.

```typescript
const { mnemonic, seed } = await TrustWalletCore.importWalletFromHexString("<HEX_STRING>", "");
```

<br />

>**getAddressForCoin(coin)**

Generate and retrieve the default address for a coin. The address is generated using the default derivation path of a coin.

* `coin` *string* - The coin type
* **Returns**
    *  `address` *string* - The public key of the address

```typescript
const address = await TrustWalletCore.getAddressForCoin("ethereum");
```

<br />

>**deriveAddressForCoin(coin, derivationPath)**

Generate an address using a custom derivation path.

* `coin` *string* - The coin type
* `derivationPath` *string* - Derivation path to be used when generating the address
* **Returns**
    *  `address` *string* - The public key of the address
    *  `privateKey` *string* - The private key of the address

```typescript
const { address, privateKey } = await TrustWalletCore.deriveAddressForCoin("ethereum", "m/44'/60'/1'/0/0");
```

<br />

>**signTransactionForCoin(coin, input)**

Generate and retrieve the default address for a coin. The address is generated using the default derivation path of a coin.

* `coin` *string* - The coin type
* `input` *object*
    * `toAddress` *string* - Destination of the funds (Public Key).
    * `amount` *string* - The amount to include in the transaction. Should be a hex string.
    * `privateKeyDerivationPath` *string (optional)* - Provide a derivation path if you want to use an address that is **NOT** the default address.
    * `chainID` *string (optional)* - Ethereum Network selector. Should be a hex string. (Default is 01)
    * `gasPrice` *string (optional)* - Should be a hex string. (Default is d693a400)
    * `gasLimit` *string (optional)* - Should be a hex string. (Default is 5208)
    * `nonce` *string (optional)* - The count of the number of outgoing transactions. Should be a hex string. (Default is 00)
* **Returns**
    *  `r` *string*
    *  `s` *string*
    *  `v` *string*
    *  `encoded` *string*
    *  `hashValue` *string*

```typescript
const { r, s, v, encoded, hashValue } = await TrustWalletCore.signTransactionForCoin("ethereum", {
    chainID: "0x01",
    amount: "0x0348bca5a16000",
    nonce: "0x00",
    toAddress: "0xC37054b3b48C3317082E7ba872d7753D13da4986",
    privateKeyDerivationPath: "m/44'/60'/1'/0/0", // optional - otherwise default address is used
});
```

<br />

>**cleanup()**

Cleanup any previously loaded wallet from local memory.

```typescript
await TrustWalletCore.cleanup();
```

## Contributing

See the [contributing guide](CONTRIBUTING.md) to learn how to contribute to the repository and the development workflow.

## License

MIT
