#import <React/RCTBridgeModule.h>

@interface RCT_EXTERN_MODULE(WalletCore, NSObject)

RCT_EXTERN_METHOD(cleanup)

RCT_EXTERN_METHOD(createWallet:(NSInteger *)strength passphrase: (NSString *)passphrase resolve:(RCTPromiseResolveBlock)resolve reject:(RCTPromiseRejectBlock)reject)

RCT_EXTERN_METHOD(importWalletFromMnemonic:(NSString *) mnemonic passphrase: (NSString *)passphrase resolve:(RCTPromiseResolveBlock)resolve reject:(RCTPromiseRejectBlock)reject)

RCT_EXTERN_METHOD(importWalletFromHexString:(NSString *) hexString passphrase: (NSString *)passphrase resolve:(RCTPromiseResolveBlock)resolve reject:(RCTPromiseRejectBlock)reject)

RCT_EXTERN_METHOD(getAddressForCoin:(NSString *) coin resolve:(RCTPromiseResolveBlock)resolve reject:(RCTPromiseRejectBlock)reject)

RCT_EXTERN_METHOD(deriveAddressForCoin:(NSString *) coin derivationPath:(NSString *) derivationPath resolve:(RCTPromiseResolveBlock)resolve reject:(RCTPromiseRejectBlock)reject)

RCT_EXTERN_METHOD(signTransactionForCoin:(NSString *) coin input:(NSDictionary *)input resolve:(RCTPromiseResolveBlock)resolve reject:(RCTPromiseRejectBlock)reject)

@end
