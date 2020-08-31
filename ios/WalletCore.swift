import Foundation
import TrustWalletCore

enum Coins: String {
    case ethereum
}

@objc(WalletCore)
class WalletCore: NSObject {
    private let ERROR_INVALID_MNEMONIC = "ERROR_INVALID_MNEMONIC"
    private let ERROR_INVALID_HEXSTRING = "ERROR_INVALID_HEXSTRING"
    private let ERROR_NO_WALLET_LOADED = "ERROR_NO_WALLET_LOADED"
    private let ERROR_UNSUPPORTED_COIN = "ERROR_UNSUPPORTED_COIN"
    private let ERROR_INVALID_SIGNING_PARAMS = "ERROR_INVALID_SIGNING_PARAMS"
    private var _wallet: HDWallet? = nil

    func setWallet(wallet: HDWallet) -> Void {
        _wallet = wallet
    }

    func getWalletResponse(wallet: HDWallet) -> NSDictionary {
        return [
            "mnemonic": wallet.mnemonic,
            "seed": wallet.seed.hexString
        ]
    }

    func getAddressResponse(address: String, privateKey: String) -> NSDictionary {
        return [
            "address": address,
            "privateKey": privateKey
        ]
    }

    func getEscapedDerivationPath(derivationPath: String) -> String {
        return derivationPath.replacingOccurrences(of: "(?<=\\d)'", with: "\'", options: .regularExpression)
    }

    @objc
    func constantsToExport() -> [AnyHashable : Any]! {
        return [
            "coins": [
                Coins.ethereum.rawValue
            ]
        ]
    }

    @objc
    static func requiresMainQueueSetup() -> Bool {
      return false
    }

    @objc
    func cleanup() -> Void {
        _wallet = nil
    }

    @objc
    func createWallet(_ strength: Int32, passphrase: String, resolve: RCTPromiseResolveBlock, reject: RCTPromiseRejectBlock) -> Void {
        let wallet = HDWallet(strength: strength, passphrase: passphrase)

        resolve(getWalletResponse(wallet: wallet))
    }

    @objc
    func importWalletFromMnemonic(_ mnemonic: String, passphrase: String, resolve: RCTPromiseResolveBlock, reject: RCTPromiseRejectBlock) -> Void {
        if (!HDWallet.isValid(mnemonic: mnemonic)) {
            reject(ERROR_INVALID_MNEMONIC, "The mnemonic proved in invalid", nil)
            return
        }

        let wallet = HDWallet(mnemonic: mnemonic, passphrase: passphrase)

        setWallet(wallet: wallet)

        resolve(getWalletResponse(wallet: wallet))
    }

    @objc
    func importWalletFromHexString(_ hexString: String, passphrase: String, resolve: RCTPromiseResolveBlock, reject: RCTPromiseRejectBlock) -> Void {
        let data = Data(hexString: hexString)

        if (data == nil) {
            reject(ERROR_INVALID_HEXSTRING, "The hexString provided is invalid", nil)
            return
        }

        let wallet = HDWallet(data: data!, passphrase: passphrase)

        setWallet(wallet: wallet)

        resolve(getWalletResponse(wallet: wallet))
    }

    @objc
    func getAddressForCoin(_ coin: String, resolve: RCTPromiseResolveBlock, reject: RCTPromiseRejectBlock) -> Void {
        if (_wallet == nil) {
            reject(ERROR_NO_WALLET_LOADED, "A valid wallet has not been loaded yet with importWallet", nil)
            return
        }

        // TODO: Move out the logic to separate file
        switch coin {
        case Coins.ethereum.rawValue:
            let address = _wallet!.getAddressForCoin(coin: .ethereum)
            resolve(address)
            break;

        default:
            reject(ERROR_UNSUPPORTED_COIN, "This coin is currently not supported", nil)
            break;
        }
    }

    @objc
    func deriveAddressForCoin(_ coin: String, derivationPath: String, resolve: RCTPromiseResolveBlock, reject: RCTPromiseRejectBlock) -> Void {
        if (_wallet == nil) {
            reject(ERROR_NO_WALLET_LOADED, "A valid wallet has not been loaded yet with importWallet", nil)
            return
        }

        let escapedDerivationPath = getEscapedDerivationPath(derivationPath: derivationPath)

        let key = _wallet!.getKey(derivationPath: escapedDerivationPath)

        // TODO: Move out the logic to separate file
        switch coin {
        case Coins.ethereum.rawValue:
            let address = CoinType.ethereum.deriveAddress(privateKey: key)
            resolve(getAddressResponse(address: address, privateKey: key.data.hexString))
            break;

        default:
            reject(ERROR_UNSUPPORTED_COIN, "This coin is currently not supported", nil)
            break;
        }
    }

    @objc
    func signTransactionForCoin(_ coin: String, input: NSDictionary, resolve: RCTPromiseResolveBlock, reject: RCTPromiseRejectBlock) -> Void {
        if (_wallet == nil) {
            reject(ERROR_NO_WALLET_LOADED, "A valid wallet has not been loaded yet with importWallet", nil)
            return
        }

        // TODO: Move out the logic to separate file
        switch coin {
        case Coins.ethereum.rawValue:
            // Defaults
            let chainID = input["chainID"] as? String ?? "01"
            let gasPrice = input["gasPrice"] as? String ?? "d693a400" // decimal 3600000000
            let gasLimit = input["gasLimit"] as? String ?? "5208" // decimal 21000
            let nonce = input["nonce"] as? String ?? "00"

            // Required
            let toAddress = input["toAddress"] as? String
            let amount = input["amount"] as? String

            // Optional
            let privateKeyDerivationPath = input["privateKeyDerivationPath"] as? String

            if (toAddress == nil) {
                reject(ERROR_INVALID_SIGNING_PARAMS, "Missing toAddress in signing input", nil)
                return
            }

            if (amount == nil) {
                reject(ERROR_INVALID_SIGNING_PARAMS, "Missing amount in signing input", nil)
                return
            }

            if (input["privateKeyDerivationPath"] != nil && privateKeyDerivationPath == nil) {
                reject(ERROR_INVALID_SIGNING_PARAMS, "privateKeyDerivationPath must be a string", nil)
                return
            }

            var privateKey = _wallet!.getKeyForCoin(coin: .ethereum).data

            if (privateKeyDerivationPath != nil) {
                let escapedDerivationPath = getEscapedDerivationPath(derivationPath: privateKeyDerivationPath!)
                privateKey = _wallet!.getKey(derivationPath: escapedDerivationPath).data
            }

            let amountData = Data(hexString: amount!)

            if (amountData == nil) {
                reject(ERROR_INVALID_HEXSTRING, "The hexString provided for amount is invalid", nil)
                return
            }

            let nonceData = Data(hexString: nonce)

            if (nonceData == nil) {
               reject(ERROR_INVALID_HEXSTRING, "The hexString provided for nonce is invalid", nil)
               return
            }

            let chainIDData = Data(hexString: chainID)

            if (chainIDData == nil) {
                reject(ERROR_INVALID_HEXSTRING, "The hexString provided for chainID is invalid", nil)
                return
            }

            let gasPriceData = Data(hexString: gasPrice)

            if (gasPriceData == nil) {
                reject(ERROR_INVALID_HEXSTRING, "The hexString provided for gasPrice is invalid", nil)
                return
            }

            let gasLimitData = Data(hexString: gasLimit)

            if (gasLimitData == nil) {
                reject(ERROR_INVALID_HEXSTRING, "The hexString provided for gasLimit is invalid", nil)
                return
            }

            let input = EthereumSigningInput.with {
                $0.chainID = chainIDData!
                $0.gasPrice = gasPriceData!
                $0.gasLimit = gasLimitData!
                $0.toAddress = toAddress!
                $0.amount = amountData!
                $0.nonce = nonceData!
                $0.privateKey = privateKey
            }

            let output: EthereumSigningOutput = AnySigner.sign(input: input, coin: .ethereum)

            resolve([
                "r": output.r.hexString,
                "s": output.s.hexString,
                "v": output.v.hexString,
                "encoded": output.encoded.hexString,
                "hashValue": output.hashValue
            ])
            break;

        default:
            reject(ERROR_UNSUPPORTED_COIN, "This coin is currently not supported", nil)
            break;
        }


    }
}
