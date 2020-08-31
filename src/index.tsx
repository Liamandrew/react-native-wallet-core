import { NativeModules } from 'react-native';

type WalletCoreType = {
  multiply(a: number, b: number): Promise<number>;
};

const { WalletCore } = NativeModules;

export default WalletCore as WalletCoreType;
