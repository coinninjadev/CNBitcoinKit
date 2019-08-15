//
//  CNBTransactionBuilder.mm
//  CNBitcoinKit
//
//  Created by Mitchell on 5/14/18.
//  Copyright © 2018 Coin Ninja, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CNBTransactionBuilder.h"
#import "CNBHDWallet+Project.h"
#import "CNBTransactionMetadata.h"
#import "CNBHDWallet.h"
#import "CNBTransactionData+Project.h"
#import "CNBTransactionMetadata+Project.h"
#import "CNBBaseCoin+Project.h"

#ifdef __cplusplus
#include <bitcoin/bitcoin/coinninja/wallet/base_coin.hpp>
#include <bitcoin/bitcoin/coinninja/transaction/transaction_builder.hpp>
#include <bitcoin/bitcoin/coinninja/transaction/transaction_data.hpp>
#include <bitcoin/bitcoin/coinninja/transaction/transaction_metadata.hpp>
#endif

using namespace coinninja::transaction;
using namespace coinninja::wallet;

@implementation CNBTransactionBuilder

- (void)broadcastWithTransactionData:(CNBTransactionData *)data
                              wallet:(CNBHDWallet *)wallet
                             success:(void (^)(NSString * _Nonnull))success
                             failure:(void (^)(NSError * _Nonnull))failure {
  [wallet broadcastTransactionFromData:data success:^(NSString * _Nonnull txid) {
    success(txid);
  } andFailure:^(NSError * _Nonnull error) {
    failure(error);
  }];
}

-(CNBTransactionMetadata *)generateTxMetadataWithTransactionData:(CNBTransactionData *)data wallet:(CNBHDWallet *)wallet {
  transaction_data c_data{[data c_data]};
  bc::wallet::hd_private master_private_key{[wallet masterPrivateKey]};
  base_coin coin{[[wallet coin] c_coin]};
  transaction_builder builder{master_private_key, coin};
  transaction_metadata c_metadata{builder.generate_tx_metadata(c_data)};
  CNBTransactionMetadata *metadata = [CNBTransactionMetadata metadataFromC_metadata:c_metadata];
  return metadata;
}

@end
