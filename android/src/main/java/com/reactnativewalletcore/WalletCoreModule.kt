package com.reactnativewalletcore

import com.facebook.react.bridge.*
import com.google.protobuf.ByteString
import wallet.core.jni.CoinType
import wallet.core.jni.EthereumSigner
import wallet.core.jni.HDWallet
import wallet.core.jni.PrivateKey
import wallet.core.jni.proto.Ethereum
import java.math.BigInteger
import kotlin.experimental.and


class WalletCoreModule(reactContext: ReactApplicationContext) : ReactContextBaseJavaModule(reactContext) {

    init {
        System.loadLibrary("TrustWalletCore")
    }

    private val errorInvalidMnemonic = "ERROR_INVALID_MNEMONIC"
    private val errorInvalidHexstring = "ERROR_INVALID_HEXSTRING"
    private val errorNoWalletLoaded = "ERROR_NO_WALLET_LOADED"
    private val errorUnsupportedCoin = "ERROR_UNSUPPORTED_COIN"
    private val errorInvalidSigningParam = "ERROR_INVALID_SIGNING_PARAM"

    private val coinEthereum = "ethereum"

    private var wallet: HDWallet? = null

    override fun getName(): String {
        return "WalletCore"
    }

    private fun getAddressResponse(address: String, privateKey: String): WritableMap? {
        val map = Arguments.createMap()
        map.putString("address", address)
        map.putString("privateKey", privateKey)

        return map
    }

    private fun getWalletResponse(wallet: HDWallet): WritableMap? {
        val map = Arguments.createMap()
        map.putString("mnemonic", wallet.mnemonic())
        map.putString("seed", wallet.seed().toHexString())

        return map
    }

    private fun setWallet(wallet: HDWallet) {
        this.wallet = wallet
    }

    private fun ByteArray.toHexString(withPrefix: Boolean = true): String {
        val stringBuilder = StringBuilder()
        if(withPrefix) {
            stringBuilder.append("0x")
        }
        for (element in this) {
            stringBuilder.append(String.format("%02x", element and 0xFF.toByte()))
        }
        return stringBuilder.toString()
    }

    @ReactMethod
    fun cleanup() {
        this.wallet = null
    }

    @ReactMethod
    fun createWallet(strength: Int, passphrase: String, promise: Promise) {
        val wallet = HDWallet(strength, passphrase)

        promise.resolve(getWalletResponse(wallet))
    }

    @ReactMethod
    fun importWalletFromMnemonic(mnemonic: String, passphrase: String, promise: Promise) {
        if (!HDWallet.isValid(mnemonic)) {
            promise.reject(errorInvalidMnemonic, "The mnemonic proved in invalid")
            return
        }

        val wallet = HDWallet(mnemonic, passphrase)
        setWallet(wallet)

        promise.resolve(getWalletResponse(wallet))
    }

    @ReactMethod
    fun importWalletFromHexString(hexString: String, passphrase: String, promise: Promise) {
      val bytes = BigInteger(hexString).toByteArray()

      if (bytes.isEmpty()) {
          promise.reject(errorInvalidHexstring, "The hexString provided is invalid")
          return
      }

      val wallet = HDWallet(bytes, passphrase)
      setWallet(wallet)

      promise.resolve(getWalletResponse(wallet))
    }

    @ReactMethod
    fun getAddressForCoin(coin: String, promise: Promise) {
      if (wallet == null) {
          promise.reject(errorNoWalletLoaded, "A valid wallet has not been loaded yet with importWallet")
          return
      }

      when (coin) {
          coinEthereum -> {
            val address = wallet!!.getAddressForCoin(CoinType.ETHEREUM)

            promise.resolve(address)
          }
          else -> promise.reject(errorUnsupportedCoin, "This coin is currently not supported")
      }
    }

    @ReactMethod
    fun deriveAddressForCoin(coin: String, derivationPath: String?, promise: Promise) {
      if (wallet == null) {
        promise.reject(errorNoWalletLoaded, "A valid wallet has not been loaded yet with importWallet")
        return
      }

      val privateKey = wallet!!.getKey(derivationPath)

      when (coin) {
        coinEthereum -> {
          val address = CoinType.ETHEREUM.deriveAddress(privateKey)

          promise.resolve(getAddressResponse(address, Numeric.toHexString(privateKey.data())))
        }
        else -> promise.reject(errorUnsupportedCoin, "This coin is currently not supported")
      }
    }

    @ReactMethod
    fun signTransactionForCoin(coin: String?, input: ReadableMap, promise: Promise) {
      if (wallet == null) {
        promise.reject(errorNoWalletLoaded, "A valid wallet has not been loaded yet with importWallet")
        return
      }
      when (coin) {
        coinEthereum -> {
          var chainID = "01"

          if (input.hasKey("chainID")) {
            chainID = input.getString("chainID") as String
          }

          val gasPrice = "d693a400"
          if (input.hasKey("gasPrice")) {
            chainID = input.getString("gasPrice") as String
          }

          val gasLimit = "5208"
          if (input.hasKey("gasLimit")) {
            chainID = input.getString("gasLimit") as String
          }

          val nonce = "00"
          if (input.hasKey("nonce")) {
            chainID = input.getString("nonce") as String
          }

          val toAddress: String? = if (input.hasKey("toAddress")) {
            input.getString("toAddress")
          } else {
            promise.reject(errorInvalidSigningParam, "Missing toAddress in signing input")
            return
          }

          val amount: String? = if (input.hasKey("amount")) {
            input.getString("amount")
          } else {
            promise.reject(errorInvalidSigningParam, "Missing amount in signing input")
            return
          }

          var privateKeyDerivationPath: String? = null
          if (input.hasKey("privateKeyDerivationPath")) {
            privateKeyDerivationPath = input.getString("privateKeyDerivationPath")
          }

          var privateKey: PrivateKey = wallet!!.getKeyForCoin(CoinType.ETHEREUM)
          if (privateKeyDerivationPath != null) {
            privateKey = wallet!!.getKey(privateKeyDerivationPath)
          }

          val signingInput = Ethereum.SigningInput.newBuilder().apply {
            this.chainId = ByteString.copyFrom(Numeric.hexStringToByteArray(chainID))
            this.gasPrice = ByteString.copyFrom(Numeric.hexStringToByteArray(gasPrice))
            this.gasLimit = ByteString.copyFrom(Numeric.hexStringToByteArray(gasLimit))
            this.amount =ByteString.copyFrom(Numeric.hexStringToByteArray(amount!!))
            this.nonce = ByteString.copyFrom(Numeric.hexStringToByteArray(nonce))
            this.privateKey = ByteString.copyFrom(privateKey.data())
            this.toAddress = toAddress
          }.build()

          val signingOutput = EthereumSigner.sign(signingInput)

          val map = Arguments.createMap()

          map.putString("r", signingOutput.r.toByteArray().toHexString())
          map.putString("s", signingOutput.s.toByteArray().toHexString())
          map.putString("v", signingOutput.v.toByteArray().toHexString())
          map.putString("encoded", signingOutput.encoded.toByteArray().toHexString())
          map.putInt("hashValue", signingOutput.hashCode())

          promise.resolve(map)
        }
        else -> promise.reject(errorUnsupportedCoin, "This coin is currently not supported")
      }
    }

}
