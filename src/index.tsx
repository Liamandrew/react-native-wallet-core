import { NativeModules } from 'react-native';

type WalletResponseType = {
  mnemonic: string;
  seed: string;
};

type AddressResponseType = {
  address: string;
  privateKey: string;
};

type SignedTransactionType = {
  r: string;
  s: string;
  v: string;
  encoded: string;
  hashValue: string;
};

type WalletCoreType = {
  cleanup(): void;
  createWallet(
    strength: number,
    passphrase: string
  ): Promise<WalletResponseType>;
  importWalletFromMnemonic(
    mnemonic: string,
    passphrase: string
  ): Promise<WalletResponseType>;
  importWalletFromHexString(
    mnemonic: string,
    passphrase: string
  ): Promise<WalletResponseType>;
  getAddressForCoin(coin: string): Promise<string>;
  deriveAddressForCoin(
    coin: string,
    derivationPath: string
  ): Promise<AddressResponseType>;
  signTransactionForCoin(
    coin: string,
    input: {}
  ): Promise<SignedTransactionType>;
};

const { WalletCore } = NativeModules;

export default WalletCore as WalletCoreType;
