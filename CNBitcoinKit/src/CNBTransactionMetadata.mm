//
//  CNBTransactionMetadata.mm
//  CNBitcoinKit
//
//  Created by BJ Miller on 8/21/18.
//  Copyright © 2018 Coin Ninja, LLC. All rights reserved.
//

#import "CNBTransactionMetadata.h"
#import "CNBDerivationPath.h"
#import "CNBTransactionMetadata+Project.h"
#import "CNBDerivationPath+Project.h"

@implementation CNBTransactionMetadata

- (instancetype)initWithTxid:(NSString *)txid encodedTx:(NSString *)encodedTx {
  if (self = [super init]) {
    _txid = txid;
    _encodedTx = encodedTx;
    _changeAddress = nil;
    _voutIndex = nil;
  }
  return self;
}

- (instancetype)initWithTxid:(NSString *)txid
                   encodedTx:(NSString *)encodedTx
               changeAddress:(nonnull NSString *)changeAddress
                  changePath:(nonnull CNBDerivationPath *)changePath
                   voutIndex:(nonnull NSNumber *)voutIndex {
  if (self = [self initWithTxid:txid encodedTx:encodedTx]) {
    _changeAddress = changeAddress;
    _changePath = changePath;
    _voutIndex = voutIndex;
  }
  return self;
}

// project
+ (CNBTransactionMetadata *)metadataFromC_metadata:(coinninja::transaction::transaction_metadata)c_metadata {
  NSString *newTxid = [NSString stringWithCString:c_metadata.get_txid().c_str() encoding:[NSString defaultCStringEncoding]];
  NSString *newEncodedTx = [NSString stringWithCString:c_metadata.get_encoded_tx().c_str() encoding:[NSString defaultCStringEncoding]];

  CNBTransactionMetadata *txMetadata = [[CNBTransactionMetadata alloc] initWithTxid:newTxid encodedTx:newEncodedTx];

  if (c_metadata.get_change_address() != nullptr) {
    std::string change_addr = *(c_metadata.get_change_address());
    NSString *changeAddress = [NSString stringWithCString:change_addr.c_str() encoding:[NSString defaultCStringEncoding]];
    txMetadata.changeAddress = changeAddress;
  }

  if (c_metadata.get_change_path() != nullptr) {
    coinninja::wallet::derivation_path c_path{*(c_metadata.get_change_path())};
    CNBDerivationPath *changePath = [CNBDerivationPath pathFromC_path:c_path];
    txMetadata.changePath = changePath;
  }

  if (c_metadata.get_vout_index() != nullptr) {
    uint c_vout_index{*(c_metadata.get_vout_index())};
    NSNumber *voutIndex = [NSNumber numberWithUnsignedInt:c_vout_index];
    txMetadata.voutIndex = voutIndex;
  }

  return txMetadata;
}

using namespace coinninja::wallet;
- (coinninja::transaction::transaction_metadata)c_metadata {
  std::string c_txid{[[self txid] cStringUsingEncoding:[NSString defaultCStringEncoding]]};
  std::string c_encoded_tx{[[self encodedTx] cStringUsingEncoding:[NSString defaultCStringEncoding]]};

  coinninja::wallet::derivation_path c_change_path{};
  if ([self changePath] != nil) {
    c_change_path = {
      static_cast<uint32_t>([[self changePath] purpose]),
      static_cast<uint32_t>([[self changePath] coinType]),
      static_cast<uint32_t>([[self changePath] account]),
      static_cast<uint32_t>([[self changePath] change]),
      static_cast<uint32_t>([[self changePath] index])
    };
  }

  std::string c_change_address{};
  if ([self changeAddress] != nil) {
    c_change_address = [[self changeAddress] cStringUsingEncoding:[NSString defaultCStringEncoding]];
  }

  uint c_vout_index{0};
  if ([self voutIndex] != nil) {
    c_vout_index = static_cast<uint>([[self voutIndex] unsignedIntegerValue]);
  }

  coinninja::transaction::transaction_metadata c_metadata{
    c_txid, c_encoded_tx, c_change_address, c_change_path, c_vout_index
  };
  return c_metadata;
}

@end
