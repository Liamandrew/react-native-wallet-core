import * as React from 'react';
import { StyleSheet, View, Text } from 'react-native';
import TrustWalletCore from 'react-native-wallet-core';

export default function App() {
  const [mnemonic, setMnemonic] = React.useState<string | undefined>();

  React.useEffect(() => {
    const createWallet = async () => {
      const wallet = await TrustWalletCore.createWallet(128, '');

      setMnemonic(wallet.mnemonic);
    };

    createWallet();
  }, []);

  return (
    <View style={styles.container}>
      <Text>Mnemonic: {mnemonic || ''}</Text>
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    alignItems: 'center',
    justifyContent: 'center',
  },
});
