//
//  CNBHDWallet.mm
//  CNBitcoinKit
//
//  Created by BJ Miller on 1/23/18.
//  Copyright © 2018 Coin Ninja, LLC. All rights reserved.
//

#import <CNBitcoinKit/CNBHDWallet.h>
#import "CNBHDWallet.h"
#import "CNBHDWallet+Project.h"
#import "CNBUnspentTransactionOutput.h"
#import "CNBTransactionData.h"
#import "CNBTransactionMetadata.h"
#import "CNBDerivationPath.h"
#import "NSData+CNBitcoinKit.h"
#import "CNBAddressHelper.h"
#import "CNBAddressHelper+Project.h"
#include "usable_address.hpp"
#include "Base58Check.hpp"
#import "sodium.h"
#include "encryption_cipher_keys.hpp"
#include "cipher_keys.hpp"
#include "cipher_key_vendor.hpp"
#import "CNBWitnessMetadata.h"
#import "CNBSegwitAddress.h"
#import "CNBBaseCoin+Project.h"

using namespace bc;
using namespace wallet;
using namespace chain;
using namespace machine;

@interface CNBHDWallet()
@property (nonatomic, strong) NSArray *mnemonicSeed;
@property (nonatomic, strong) CNBBaseCoin *coin;
@property (nonatomic) bc::data_chunk seed;
@property (nonatomic) bc::wallet::word_list mnemonic;
@property (nonatomic) bc::wallet::hd_private privateKey;
@property (nonatomic) bc::wallet::hd_public publicKey;
@end

@implementation CNBHDWallet

// MARK: class methods
+ (nonnull NSArray <NSString *>*)allWords {
  bc::wallet::dictionary bip39Words = bc::wallet::language::en;
  NSMutableArray <NSString *> * words = [[NSMutableArray alloc] init];
  int length = sizeof(bip39Words) / sizeof(bip39Words[0]);
  for(int i = 0; i < length; i++) {
    std::string word = bip39Words[i];
    NSString *objcWord = [NSString stringWithCString:word.c_str()
                                            encoding:[NSString defaultCStringEncoding]];
    [words insertObject:objcWord atIndex:i];
  }

  return words;
}

+ (NSArray <NSString *> *)createMnemonicWords {
  int len = 16; // 16 bytes
  void *buf = malloc(len);
  randombytes_buf(buf, 16);
  unsigned char *charBuf = (unsigned char*)buf;
  bc::data_chunk seedChunk(charBuf, charBuf + len);

  NSMutableArray<NSString *> *mnemonicArray = [[NSMutableArray alloc] init];

  // create mnemonic word list
  bc::wallet::word_list mnemonic_list = bc::wallet::create_mnemonic(seedChunk);
  if(bc::wallet::validate_mnemonic(mnemonic_list)) {
    for (auto i = mnemonic_list.begin(); i != mnemonic_list.end(); ++i) {
      NSString *word = [NSString stringWithCString:(*i).c_str() encoding:[NSString defaultCStringEncoding]];
      [mnemonicArray addObject:word];
    }
  } else {
    NSLog(@"mnemonic invalid!");
  }

  sodium_memzero(buf, len); // zero out memory

  return [NSArray arrayWithArray:mnemonicArray];
}

+ (BOOL)addressIsBase58CheckEncoded:(NSString *)address {
  std::string c_addr = [address cStringUsingEncoding:[NSString defaultCStringEncoding]];
  BOOL valid = Base58Check::addressIsBase58CheckEncoded(c_addr);
  return valid;
}

+ (CNBBaseCoin *)defaultBTCCoin {
  return [[CNBBaseCoin alloc] init];
}

// MARK: initializers
- (instancetype)initWithMnemonic:(NSArray *)mnemonicSeed coin:(CNBBaseCoin *)coin {
	if (self = [super init]) {
		_coin = coin;
		_mnemonicSeed = mnemonicSeed;
		__block std::vector<std::string>wordList;
		[mnemonicSeed enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
			std::string str = [(NSString *)obj cStringUsingEncoding:[NSString defaultCStringEncoding]];
			wordList.push_back(str);
		}];
		_seed = bc::to_chunk(bc::wallet::decode_mnemonic(wordList));
		_mnemonic = wordList;

		[self configureMasterKeysWithCoin:_coin];
	}
	return self;
}

- (void)configureMasterKeysWithCoin:(CNBBaseCoin *)coin {
	uint64_t net = _coin.coin == 0 ? bc::wallet::hd_private::mainnet : bc::wallet::hd_private::testnet;
	_privateKey = bc::wallet::hd_private(_seed, net);
	_publicKey = _privateKey.to_public();
}

- (instancetype)init {
	return [self initWithCoin:[CNBHDWallet defaultBTCCoin]];
}

- (instancetype)initWithCoin:(CNBBaseCoin *)coin {
	if (self = [super init]) {
		_coin = coin;
    NSArray *words = [CNBHDWallet createMnemonicWords];
    return [self initWithMnemonic:words coin:coin];
	}
	return nil;
}

// MARK: accessors
- (NSArray *)mnemonicWords {
	return self.mnemonicSeed;
}

bc::machine::operation::list witnessProgram(bc::ec_compressed thePublicKey) {
	bc::short_hash keyHash = bc::bitcoin_short_hash(thePublicKey);
	return {bc::machine::operation(bc::machine::opcode(0)), bc::machine::operation(bc::to_chunk(keyHash))};
}

bc::wallet::hd_private childPrivateKey(bc::wallet::hd_private privKey, int index) {
	return privKey.derive_private(index);
}

- (CNBMetaAddress *)receiveAddressForIndex:(NSUInteger)index {
	NSString *address = [self addressForChangeIndex:0 index:index];
  CoinType type = self.coin.coin;
  CoinDerivation purpose = self.coin.purpose;
  CNBDerivationPath *derivationPath = [[CNBDerivationPath alloc] initWithPurpose:purpose coinType:type account:0 change:0 index:index];

  // get uncompressed ec pubkey
  bc::wallet::hd_public pubkey = [self indexPublicKeyForChangeIndex:0 index:index];
  auto compressed = bc::wallet::ec_public(pubkey);
  bc::ec_uncompressed uncompressed;
  compressed.to_uncompressed(uncompressed);
  auto uncompressedChunk = to_chunk(uncompressed);
  auto encodedChunk = encode_base16(uncompressedChunk);
  NSString *encodedStringRepresentation = [NSString stringWithCString:encodedChunk.c_str() encoding:[NSString defaultCStringEncoding]];

  CNBMetaAddress *metaAddress = [[CNBMetaAddress alloc] initWithAddress:address derivationPath:derivationPath uncompressedPublicKey:encodedStringRepresentation];
  return metaAddress;
}

- (CNBMetaAddress *)changeAddressForIndex:(NSUInteger)index {
	NSString *address = [self addressForChangeIndex:1 index:index];
  CoinType type = self.coin.coin;
  CoinDerivation purpose = self.coin.purpose;
  CNBDerivationPath *derivationPath = [[CNBDerivationPath alloc] initWithPurpose:purpose coinType:type account:0 change:1 index:index];
  CNBMetaAddress *metaAddress = [[CNBMetaAddress alloc] initWithAddress:address derivationPath:derivationPath uncompressedPublicKey:nil];
  return metaAddress;
}

// private
- (NSString *)addressForChangeIndex:(NSUInteger)change index:(NSUInteger)index {
  // 1. get index public key
  bc::wallet::hd_public indexPublicKey = [self indexPublicKeyForChangeIndex:change index:index];

	// 2. get compressed public key at end of derivation path
	bc::ec_compressed compressedPublicKey = indexPublicKey.point();

  // 3. return address based on coin purpose
  switch (self.coin.purpose) {
    case BIP49:
      return [self p2wpkhInP2shForCompressedPublicKey:compressedPublicKey];
      break;
    case BIP84:
      return [self p2wpkhForCompressedPublicKey:compressedPublicKey];
      break;

    default:
      return @"";
      break;
  }
}

// private
- (NSString *)p2wpkhInP2shForCompressedPublicKey:(bc::ec_compressed)compressedPublicKey {
  // 1. wrap in p2sh
  bc::chain::script P2WPKH = bc::chain::script(witnessProgram(compressedPublicKey));

  // 2. wrap witness program in P2SH
  bc::short_hash witnessProgramHash = bc::bitcoin_short_hash(P2WPKH.to_data(0));
  bc::chain::script P2SH_P2WPKH = bc::chain::script::to_pay_script_hash_pattern(witnessProgramHash);

  // 3. return NSString representation of cStr
  std::string encoded_payment_address = [self isTestNet] ?
  bc::wallet::payment_address(P2WPKH, bc::wallet::payment_address::testnet_p2sh).encoded() :
  bc::wallet::payment_address(P2WPKH).encoded();

  NSString *word = [NSString stringWithCString:encoded_payment_address.c_str() encoding:[NSString defaultCStringEncoding]];
  return word;
}

// private
- (NSString *)p2wpkhForCompressedPublicKey:(bc::ec_compressed)compressedPublicKey {

  // 1. get RIPEMD160 hash
  bc::short_hash key_hash = bc::bitcoin_short_hash(compressedPublicKey);
  std::vector<uint8_t> scriptPubKey(key_hash.begin(), key_hash.end());

  // 2. convert to data
  NSData *data = [NSData dataWithBytes:scriptPubKey.data() length:scriptPubKey.size()];

  // 3. create Segwit Address
  NSInteger version = 0; // OP_0
  CNBWitnessMetadata *metadata = [[CNBWitnessMetadata alloc] initWithWitVer:version witProg:data];
  NSString *address = [CNBSegwitAddress encodeSegwitAddressWithHRP:self.coin.bech32HRP witnessMetadata:metadata];

  return address;
}

// private
- (bc::wallet::hd_private)indexPrivateKeyForChangeIndex:(NSUInteger)change index:(NSUInteger) index {
  // 1. setup indexes for convenience
  NSUInteger hardenedOffset = bc::wallet::hd_first_hardened_key;
  int hardenedPurposeIndex = (int)(self.coin.purpose + hardenedOffset);
  int hardenedCoinIndex = (int)(self.coin.coin + hardenedOffset);
  int hardenedAccountIndex = (int)(self.coin.account + hardenedOffset);
  int changeIndex = (int)change;
  int indexIndex = (int)index;

  // 2. generate keys
  bc::wallet::hd_private purposePrivateKey = childPrivateKey(self.privateKey, hardenedPurposeIndex);
  bc::wallet::hd_private coinPrivateKey = childPrivateKey(purposePrivateKey, hardenedCoinIndex);
  bc::wallet::hd_private accountPrivateKey = childPrivateKey(coinPrivateKey, hardenedAccountIndex);
  bc::wallet::hd_private changePrivateKey = childPrivateKey(accountPrivateKey, changeIndex);
  bc::wallet::hd_private indexPrivateKey = childPrivateKey(changePrivateKey, indexIndex);

  return indexPrivateKey;
}

- (bc::wallet::hd_public)indexPublicKeyForChangeIndex:(NSUInteger)change index:(NSUInteger)index {
  bc::wallet::hd_public indexPublicKey = [self indexPrivateKeyForChangeIndex:change index:index].to_public();
  return indexPublicKey;
}

- (BOOL)isTestNet {
	return self.coin.coin == 1;
}

- (void)setCoin:(CNBBaseCoin *)coin {
	_coin = coin;
	[self configureMasterKeysWithCoin:_coin];
}

- (void)broadcastTransactionFromData:(CNBTransactionData *)data
                                 success:(void(^)(NSString *))success
                              andFailure:(void(^)(NSError * _Nonnull))failure {
  bc::chain::transaction transaction = [self transactionFromData:data];
  CNBTransactionMetadata *metadata = [self buildTransactionMetadataWithTransactionData:data];
  NSString *encodedTx = [metadata encodedTx];
  NSString *txid = [metadata txid];

  // set up obelisk client and connection
  bc::client::connection_type connection = {};
  connection.retries = 3;
  connection.timeout_seconds = 8;
  std::string url = [self.coin.networkURL cStringUsingEncoding:[NSString defaultCStringEncoding]];
  connection.server = bc::config::endpoint(url);
  bc::client::obelisk_client client(connection);

  // check connection
  if (!client.connect(connection)) {
    NSError *error = [NSError errorWithDomain:@"com.coinninja.cnbitcoinkit" code:8 userInfo:@{NSLocalizedDescriptionKey: @"Failed to connect to Bitcoin network"}];
    failure(error);
  }

  // lambdas for call-backs
  const auto on_done = [success, encodedTx, txid](const bc::code& ec) {
    success(txid);
  };

  const auto on_error = [failure, encodedTx, txid](const bc::code& ec) {
    NSString *errorString = [NSString stringWithCString:ec.message().c_str() encoding:[NSString defaultCStringEncoding]];
    NSNumber *value = [[NSNumber alloc] initWithInt:ec.value()];
    NSString *categoryName = [NSString stringWithCString:ec.category().name() encoding:[NSString defaultCStringEncoding]];
    NSString *errorCondition = [NSString stringWithCString:ec.default_error_condition().message().c_str() encoding:[NSString defaultCStringEncoding]];
    NSError *error = [NSError errorWithDomain:@"com.coinninja.cnbitcoinkit"
                                         code:value.intValue
                                     userInfo:@{NSLocalizedDescriptionKey: [NSString stringWithFormat:@"Failed to broadcast transaction: %@", errorString],
                                                @"encoded_tx": encodedTx,
                                                @"txid": txid,
                                                kLibbitcoinErrorCode: value,
                                                kLibbitcoinErrorMessage: errorString,
                                                @"error_category_name": categoryName,
                                                @"error_condition": errorCondition
                                                }
                      ];
    failure(error);
  };

  // broadcast tx and wait

  if (transaction.is_valid()) {
    client.transaction_pool_broadcast(on_error, on_done, transaction);
    client.wait();
  }
}

- (bc::chain::output)createPayToKeyOutputWithAddress:(bc::wallet::payment_address)address amount:(uint64_t)amount {
  return bc::chain::output(amount, bc::chain::script().to_pay_key_hash_pattern(address.hash()));
}

- (bc::chain::output)createPayToScriptOutputWithAddress:(bc::wallet::payment_address)address amount:(uint64_t)amount {
  return bc::chain::output(amount, bc::chain::script(bc::chain::script().to_pay_script_hash_pattern(address.hash())));
}

bc::machine::operation::list to_pay_witness_key_hash_pattern(bc::data_chunk hash) {
  auto pattern = bc::machine::operation::list
  {
    { opcode::push_size_0 },
    { hash }
  };
  return pattern;
}

- (bc::chain::output)createPayToSegwitOutputWithAddress:(NSString *)address amount:(uint64_t)amount {
  NSString *hrp = [self.coin bech32HRP];
  NSData *witprog = [[CNBSegwitAddress decodeSegwitAddressWithHRP:hrp address:address] witprog];
  bc::data_chunk witprog_data_chunk = [witprog dataChunk];
  return bc::chain::output(amount, to_pay_witness_key_hash_pattern(witprog_data_chunk));
}

- (bc::chain::output)outputWithAddress:(NSString *)addressString amount:(uint64_t)amount {
  CNBAddressHelper *helper = [[CNBAddressHelper alloc] initWithCoin:self.coin];
  CNBPaymentOutputType type = [helper addressTypeForAddress:addressString];
  switch (type) {
    case P2PKH: {
      bc::wallet::payment_address paymentAddress = [helper paymentAddressFromString:addressString];
      return [self createPayToKeyOutputWithAddress:paymentAddress amount:amount];
    }
    case P2SH: {
      bc::wallet::payment_address paymentAddress = [helper paymentAddressFromString:addressString];
      return [self createPayToScriptOutputWithAddress:paymentAddress amount:amount];
    }
    case P2WPKH:
    case P2WSH: {
      return [self createPayToSegwitOutputWithAddress:addressString amount:amount];
    }
    default: {
      throw "Illegal payment address";
    }
  }
}

#pragma mark - Signing

- (bc::wallet::hd_private)coinNinjaSigningKey {
    return childPrivateKey(self.privateKey, 42);
}

- (NSString *)coinNinjaVerificationKeyHexString {
    bc::wallet::hd_public coinNinjaVerificationKey = self.coinNinjaSigningKey.to_public();
    
    bc::ec_compressed key = coinNinjaVerificationKey.point();
    NSData *data = [NSData dataWithBytes:key.data() length:key.size()];
    return [data hexString];
}

- (NSString *)signatureSigningData:(NSData *)data {
    return [[self signData:data] hexString];
}

- (NSData *)signData:(NSData *)data {
    bc::hash_digest msg = [data hashDigest];
    
    bc::ec_signature signature;
    if (bc::sign(signature, self.coinNinjaSigningKey.secret(), msg)) {
        bc::der_signature derSignature;
        if (bc::encode_signature(derSignature, signature)) {
             return [NSData dataWithBytes:derSignature.data() length:derSignature.size()];
        }
    }
    
    return nil;
}

- (BOOL)verifySignedData:(NSData *)data signature:(NSData *)signature {
    bc::hash_digest msg = [data hashDigest];
    bc::ec_compressed point = self.coinNinjaSigningKey.to_public().point();
    bc::der_signature derSignature = [signature dataChunk];
    
    bc::ec_signature sig;
    if (bc::parse_signature(sig, derSignature, true)) {
        return bc::verify_signature(point, msg, sig);
    }
    
    return false;
}

// MARK: checking for addresses
- (CNBAddressResult *)checkForAddress:(NSString *)address upToIndex:(NSInteger)index {
  CNBAddressResult *result = nil;
  for (NSUInteger idx = 0; idx < index; idx++) {
    CNBMetaAddress *receiveMetaAddress = [self receiveAddressForIndex:idx];
    CNBMetaAddress *changeMetaAddress = [self changeAddressForIndex:idx];
    if ([receiveMetaAddress.address isEqualToString:address]) {
      result = [[CNBAddressResult alloc] initWithAddress:receiveMetaAddress.address isReceiveAddress:true];
      break;
    } else if ([changeMetaAddress.address isEqualToString:address]) {
      result = [[CNBAddressResult alloc] initWithAddress:changeMetaAddress.address isReceiveAddress:false];
      break;
    }
  }
  return result;
}

#pragma mark - Build Transaction Metadata
- (CNBTransactionMetadata *)buildTransactionMetadataWithTransactionData:(CNBTransactionData *)data {
  bc::chain::transaction transaction = [self transactionFromData:data];

  // encode transaction
  NSString *encodedTx = [NSString stringWithUTF8String:bc::encode_base16(transaction.to_data(true, true)).c_str()];

  // get txid
  std::string txhash = bc::encode_hash(transaction.hash());
  NSString *txid = [NSString stringWithCString:txhash.c_str() encoding:[NSString defaultCStringEncoding]];

  // return metadata
  if ([data shouldAddChangeToTransaction]) {
    NSString *changeAddress = nil;
    NSNumber *voutIndex = nil;
    for (int i = (int)transaction.outputs().size() - 1; i >= 0; i--) {
      auto output = transaction.outputs().at(i);
      NSString *possibleChangeAddress = [NSString stringWithCString:output.address().encoded().c_str() encoding:[NSString defaultCStringEncoding]];
      NSString *dataChangeAddress = [[self changeAddressForIndex:[[data changePath] index]] address];
      if ([possibleChangeAddress isEqualToString:dataChangeAddress]) {
        changeAddress = possibleChangeAddress;
        voutIndex = [NSNumber numberWithInt:i];
        break;
      }
    }
    return [[CNBTransactionMetadata alloc] initWithTxid:txid
                                              encodedTx:encodedTx
                                          changeAddress:changeAddress
                                             changePath:[data changePath]
                                              voutIndex:voutIndex];
  } else {
    return [[CNBTransactionMetadata alloc] initWithTxid:txid encodedTx:encodedTx];
  }

}

- (bc::chain::transaction)transactionFromData:(CNBTransactionData *)data {
  uint64_t paymentAmount = (uint64_t)[data amount];

  // create transaction
  bc::chain::transaction transaction = bc::chain::transaction();
  transaction.set_version(1u);

  // populate transaction with payment data
  transaction.outputs().push_back([self outputWithAddress:[data paymentAddress] amount:paymentAmount]);

  // calculate change
  if ([data shouldAddChangeToTransaction]) {
    CNBDerivationPath *changePath = [data changePath];
    derivation_path dpath([changePath purposeValue], [changePath coinValue], [changePath account], [changePath change], [changePath index]);
    usable_address change(_privateKey, dpath);
    uint64_t changeAmount = (uint64_t)[data changeAmount];
    transaction.outputs().push_back([self createPayToScriptOutputWithAddress:change.buildPaymentAddress() amount:changeAmount]);
  }

  // for each utxo, populate previous utxo
  for (CNBUnspentTransactionOutput *utxo in data.unspentTransactionOutputs) {
    // P2SH(P2WPKH) input.
    // Previous TX hash.
    std::string prev_tx = [[utxo txId] cStringUsingEncoding:[NSString defaultCStringEncoding]];
    bc::hash_digest prev_tx_hash;
    bc::decode_hash(prev_tx_hash, prev_tx);
    // Previous UXTO index.
    uint32_t index = (uint32_t)[utxo index];
    bc::chain::output_point uxto_to_spend(prev_tx_hash, index);
    // Build P2SH(P2WPKH) input object.
    bc::chain::input p2sh_p2wpkh_input;
    p2sh_p2wpkh_input.set_previous_output(uxto_to_spend);
    uint32_t seq = ([utxo isConfirmed]) ? bc::max_input_sequence - 1 : bc::max_input_sequence - 2;
    p2sh_p2wpkh_input.set_sequence(seq);

    transaction.inputs().push_back(p2sh_p2wpkh_input);
  }

  // set locktime
  transaction.set_locktime((uint32_t)[data locktime]);

  // sign inputs
  for (int i = 0; i < data.unspentTransactionOutputs.count; i++) {
    CNBUnspentTransactionOutput *utxo = data.unspentTransactionOutputs[i];
    CNBDerivationPath *path = [utxo path];
    derivation_path usable_path((int)[path purposeValue], (int)[path coinValue], (int)[path account], (int)[path change], (int)[path index]);
    usable_address signing_address(_privateKey, usable_path);

    bc::chain::script scriptCode = bc::chain::script::to_pay_key_hash_pattern(bc::bitcoin_short_hash(signing_address.buildCompressedPublicKey()));
    bc::endorsement signature;
    bc::chain::script::create_endorsement(signature, signing_address.buildPrivateKey().secret(), scriptCode, transaction, (uint32_t)i, bc::machine::sighash_algorithm::all, bc::machine::script_version::zero, (uint64_t)[utxo amount]);

    bc::data_chunk scriptChunk = bc::to_chunk(signing_address.buildP2WPKH().to_data(true));
    transaction.inputs()[i].set_script(bc::chain::script(scriptChunk, false));
    bc::data_stack witness_data{signature, bc::to_chunk(signing_address.buildCompressedPublicKey())};
    transaction.inputs()[i].set_witness(bc::chain::witness(witness_data));
  }

  return transaction;
}

// MARK: ECDH
- (CNBEncryptionCipherKeys *)encryptionCipherKeysForPublicKey:(NSData *)publicKeyData {
  data_chunk public_key_data([publicKeyData dataChunk]);
  encryption_cipher_keys keys = cipher_key_vendor::encryption_cipher_keys_for_uncompressed_public_key(public_key_data);
  NSData *encryptionKey = [NSData dataWithBytes:keys.get_encryption_key().data() length:hash_size];
  NSData *hmacKey = [NSData dataWithBytes:keys.get_hmac_key().data() length:hash_size];
  NSData *ephPubKey = [NSData dataWithBytes:keys.get_ephemeral_public_key().data() length:keys.get_ephemeral_public_key().size()];

  CNBEncryptionCipherKeys *cipherKeys = [[CNBEncryptionCipherKeys alloc] initWithEncryptionKey:encryptionKey
                                                                                       hmacKey:hmacKey
                                                                            ephemeralPublicKey:ephPubKey
                                         ];
  return cipherKeys;
}

- (CNBCipherKeys *)decryptionCipherKeysForDerivationPathOfPrivateKey:(CNBDerivationPath *)path
                                                           publicKey:(NSData *)publicKeyData {
  bc::wallet::hd_private private_key = [self indexPrivateKeyForChangeIndex:[path change] index:[path index]];
  data_chunk public_key_data([publicKeyData dataChunk]);
  cipher_keys keys = cipher_key_vendor::decryption_cipher_keys(private_key, public_key_data);
  NSData *encryptionKey = [NSData dataWithBytes:keys.get_encryption_key().data() length:hash_size];
  NSData *hmacKey = [NSData dataWithBytes:keys.get_hmac_key().data() length:hash_size];
  CNBCipherKeys *cipherKeys = [[CNBCipherKeys alloc] initWithEncryptionKey:encryptionKey hmacKey:hmacKey];
  return cipherKeys;
}

@end
