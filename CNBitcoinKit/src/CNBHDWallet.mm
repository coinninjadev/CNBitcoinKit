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
#import "CNBTransactionData+Project.h"
#import "CNBTransactionMetadata.h"
#import "CNBDerivationPath.h"
#import "CNBDerivationPath+Project.h"
#import "NSData+CNBitcoinKit.h"
#import "CNBAddressHelper.h"
#import "CNBAddressHelper+Project.h"
#include "Base58Check.hpp"
#import "sodium.h"
#import "CNBWitnessMetadata.h"
#import "CNBSegwitAddress.h"
#import "CNBBaseCoin+Project.h"

using namespace bc;
using namespace wallet;
using namespace chain;
using namespace machine;

@interface CNBHDWallet()
@property (nonatomic, strong) NSArray *mnemonicSeed;
@property (nonatomic) bc::data_chunk seed;
@property (nonatomic) bc::wallet::word_list mnemonic;
@property (nonatomic) bc::wallet::hd_private privateKey;
@property (nonatomic) bc::wallet::hd_public publicKey;
@end

@implementation CNBHDWallet

// MARK: class methods
+ (nonnull NSArray <NSString *>*)allWords {
  std::vector<std::string> bip_39_words = coinninja::wallet::all_bip_39_words();
  size_t length = bip_39_words.size();
  NSMutableArray *words = [[NSMutableArray alloc] initWithCapacity:length];
  for(int i = 0; i < length; i++) {
    NSString *objcWord = [NSString stringWithCString:bip_39_words[i].c_str()
                                            encoding:[NSString defaultCStringEncoding]];
    words[i] = objcWord;
  }
  return words;
}

+ (NSArray <NSString *> *)createMnemonicWordsWithEntropy:(NSData *)entropy {
  bc::data_chunk seedChunk = [entropy dataChunk];

  NSMutableArray<NSString *> *mnemonicArray = [[NSMutableArray alloc] init];

  // create mnemonic word list
  bc::wallet::word_list mnemonic_list = coinninja::wallet::create_mnemonic(seedChunk);
  for (std::string const &_word : mnemonic_list) {
    NSString *word = [NSString stringWithCString:_word.c_str() encoding:[NSString defaultCStringEncoding]];
    [mnemonicArray addObject:word];
  }

  return [mnemonicArray copy];
}

+ (BOOL)addressIsBase58CheckEncoded:(NSString *)address {
  std::string c_addr = [address cStringUsingEncoding:[NSString defaultCStringEncoding]];
  BOOL valid = Base58Check::addressIsBase58CheckEncoded(c_addr);
  return valid;
}

+ (CNBBaseCoin *)defaultBTCCoin {
  return [[CNBBaseCoin alloc] init];
}

/// Default secure pseudo random data, using Libsodium's randombytes_buf fill.
- (NSData *)defaultEntropy {
  const int len = 16; // 16 bytes
  void *buf = malloc(len);
  randombytes_buf(buf, len);
  unsigned char *charBuf = (unsigned char*)buf;

  NSData *data = [NSData dataWithBytes:charBuf length:len];

  sodium_memzero(buf, len); // zero out memory

  delete [] charBuf;

  return data;
}

- (bc::wallet::hd_private &)masterPrivateKey {
  return _privateKey;
}

// MARK: initializers
- (instancetype)init {
  return [self initWithCoin:[CNBHDWallet defaultBTCCoin]];
}

- (instancetype)initWithCoin:(CNBBaseCoin *)coin {
  return [self initWithCoin:coin entropy:[self defaultEntropy]];
}

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

- (instancetype)initWithEntropy:(NSData *)entropy {
	return [self initWithCoin:[CNBHDWallet defaultBTCCoin] entropy:entropy];
}

- (instancetype)initWithCoin:(CNBBaseCoin *)coin entropy:(nonnull NSData *)entropy {
	if (self = [super init]) {
		_coin = coin;
    NSArray *words = [CNBHDWallet createMnemonicWordsWithEntropy:entropy];
    return [self initWithMnemonic:words coin:coin];
	}
	return nil;
}

// MARK: accessors
- (NSArray *)mnemonicWords {
	return self.mnemonicSeed;
}

- (CNBMetaAddress *)receiveAddressForIndex:(NSUInteger)index {
  auto c_coin{[[self coin] c_coin]};
  derivation_path c_path{
    static_cast<uint32_t>(c_coin.get_purpose()),
    static_cast<uint32_t>(c_coin.get_coin()),
    static_cast<uint32_t>(c_coin.get_account()),
    static_cast<uint32_t>(0),
    static_cast<uint32_t>(index)
  };
  coinninja::address::usable_address usable_address{self.privateKey, c_path};
  auto receive_metadata{usable_address.build_receive_address()};
  NSString *address = [NSString stringWithCString:receive_metadata.get_address().c_str() encoding:[NSString defaultCStringEncoding]];
  CNBDerivationPath *path = [CNBDerivationPath pathFromC_path:c_path];
  NSString *uncompressedPubKey = [NSString stringWithCString:receive_metadata.get_uncompressed_public_key().c_str() encoding:[NSString defaultCStringEncoding]];
  return [[CNBMetaAddress alloc] initWithAddress:address derivationPath:path uncompressedPublicKey:uncompressedPubKey];
}

- (CNBMetaAddress *)changeAddressForIndex:(NSUInteger)index {
  auto c_coin{[[self coin] c_coin]};
  derivation_path c_path{
    static_cast<uint32_t>(c_coin.get_purpose()),
    static_cast<uint32_t>(c_coin.get_coin()),
    static_cast<uint32_t>(c_coin.get_account()),
    static_cast<uint32_t>(1),
    static_cast<uint32_t>(index)
  };
  coinninja::address::usable_address usable_address{self.privateKey, c_path};
  auto change_metadata{usable_address.build_change_address()};
  NSString *address = [NSString stringWithCString:change_metadata.get_address().c_str() encoding:[NSString defaultCStringEncoding]];
  CNBDerivationPath *path = [CNBDerivationPath pathFromC_path:c_path];
  return [[CNBMetaAddress alloc] initWithAddress:address derivationPath:path uncompressedPublicKey:nil];
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
//  bc::chain::transaction transaction = [self transactionFromData:data];
//  CNBTransactionMetadata *metadata = [self buildTransactionMetadataWithTransactionData:data];
//  NSString *encodedTx = [metadata encodedTx];
//  NSString *txid = [metadata txid];
//
//  // set up obelisk client and connection
//  bc::client::connection_type connection = {};
//  connection.retries = 3;
//  connection.timeout_seconds = 8;
//  if (self.coin.networkURL == nil) {
//    NSError *error = [NSError errorWithDomain:@"com.coinninja.cnbitcoinkit" code:0 userInfo:@{NSLocalizedDescriptionKey: @"No coin URL provided"}];
//    failure(error);
//    return;
//  }
//  std::string url = [self.coin.networkURL cStringUsingEncoding:[NSString defaultCStringEncoding]];
//  connection.server = bc::config::endpoint(url);
//  bc::client::obelisk_client client(connection);
//
//  // check connection
//  if (!client.connect(connection)) {
//    NSError *error = [NSError errorWithDomain:@"com.coinninja.cnbitcoinkit" code:8 userInfo:@{NSLocalizedDescriptionKey: @"Failed to connect to Bitcoin network"}];
//    failure(error);
//  }
//
//  // lambdas for call-backs
//  const auto on_done = [success, encodedTx, txid](const bc::code& ec) {
//    success(txid);
//  };
//
//  const auto on_error = [failure, encodedTx, txid](const bc::code& ec) {
//    NSString *errorString = [NSString stringWithCString:ec.message().c_str() encoding:[NSString defaultCStringEncoding]];
//    NSNumber *value = [[NSNumber alloc] initWithInt:ec.value()];
//    NSString *categoryName = [NSString stringWithCString:ec.category().name() encoding:[NSString defaultCStringEncoding]];
//    NSString *errorCondition = [NSString stringWithCString:ec.default_error_condition().message().c_str() encoding:[NSString defaultCStringEncoding]];
//    NSError *error = [NSError errorWithDomain:@"com.coinninja.cnbitcoinkit"
//                                         code:value.intValue
//                                     userInfo:@{NSLocalizedDescriptionKey: [NSString stringWithFormat:@"Failed to broadcast transaction: %@", errorString],
//                                                @"encoded_tx": encodedTx,
//                                                @"txid": txid,
//                                                kLibbitcoinErrorCode: value,
//                                                kLibbitcoinErrorMessage: errorString,
//                                                @"error_category_name": categoryName,
//                                                @"error_condition": errorCondition
//                                                }
//                      ];
//    failure(error);
//  };
//
//  // broadcast tx and wait
//
//  if (transaction.is_valid()) {
//    client.transaction_pool_broadcast(on_error, on_done, transaction);
//    client.wait();
//  }
}

#pragma mark - Signing

- (NSString *)coinNinjaVerificationKeyHexString {
  using namespace coinninja::wallet;
  const std::string verification_string{key_factory::coinninja_verification_key_hex_string(self.privateKey)};
  return [NSString stringWithCString:verification_string.c_str() encoding:[NSString defaultCStringEncoding]];
}

- (NSString *)signatureSigningData:(NSData *)data {
  using namespace coinninja::wallet;
  const std::string signing{data_signing::signature_signing_data([data dataChunk], self.privateKey)};
  return [NSString stringWithCString:signing.c_str() encoding:[NSString defaultCStringEncoding]];
}

- (NSData *)signData:(NSData *)data {
  using namespace coinninja::wallet;
  const bc::data_chunk signed_data{data_signing::sign_data([data dataChunk], self.privateKey)};
  NSData *signedData = [NSData dataWithBytes:signed_data.data() length:signed_data.size()];
  return signedData;
}

- (BOOL)verifySignedData:(NSData *)data signature:(NSData *)signature {
  using namespace coinninja::wallet;
  bool verified = data_signing::verify_signed_data([data dataChunk], [signature dataChunk], self.privateKey);
  return verified;
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

// MARK: ECDH
- (CNBEncryptionCipherKeys *)encryptionCipherKeysForPublicKey:(NSData *)publicKeyData withEntropy:(NSData *)entropy {
  using namespace coinninja::encryption;
  encryption_cipher_keys keys{cipher_key_vendor::encryption_cipher_keys_for_uncompressed_public_key([publicKeyData dataChunk], [entropy dataChunk])};

  NSData *encryptionKey = [NSData dataWithBytes:keys.get_encryption_key().data() length:hash_size];
  NSData *hmacKey = [NSData dataWithBytes:keys.get_hmac_key().data() length:hash_size];
  NSData *ephPubKey = [NSData dataWithBytes:keys.get_ephemeral_public_key().data() length:keys.get_ephemeral_public_key().size()];

  CNBEncryptionCipherKeys *cipherKeys = [[CNBEncryptionCipherKeys alloc] initWithEncryptionKey:encryptionKey
                                                                                       hmacKey:hmacKey
                                                                            ephemeralPublicKey:ephPubKey];
  return cipherKeys;
}

- (CNBCipherKeys *)decryptionCipherKeysForDerivationPathOfPrivateKey:(CNBDerivationPath *)path
                                                           publicKey:(NSData *)publicKeyData {
  using namespace coinninja::encryption;
  auto c_path{[path c_path]};
  const auto index_private_key{key_factory::index_private_key(self.privateKey, c_path)};
  cipher_keys keys{cipher_key_vendor::decryption_cipher_keys(index_private_key, [publicKeyData dataChunk])};

  NSData *encryptionKey = [NSData dataWithBytes:keys.get_encryption_key().data() length:hash_size];
  NSData *hmacKey = [NSData dataWithBytes:keys.get_hmac_key().data() length:hash_size];
  CNBCipherKeys *cipherKeys = [[CNBCipherKeys alloc] initWithEncryptionKey:encryptionKey hmacKey:hmacKey];
  return cipherKeys;
}

@end
