//
//  CNBHDWallet+Project.h
//  CNBitcoinKit
//
//  Created by Mitchell on 5/16/18.
//  Copyright © 2018 Coin Ninja, LLC. All rights reserved.
//

#ifndef CNBHDWallet_Project_h
#define CNBHDWallet_Project_h

#ifdef __cplusplus
#include <bitcoin/bitcoin.hpp>
#endif

#import "CNBHDWallet.h"
@class CNBUnspentTransactionOutput;
@class CNBTransactionData;
@class CNBTransactionMetadata;

NS_ASSUME_NONNULL_BEGIN

@interface CNBHDWallet (Project)

- (CNBTransactionMetadata *)buildTransactionMetadataWithTransactionData:(CNBTransactionData *)data;
- (void)broadcastTransactionFromData:(CNBTransactionData *)data
                             success:(void(^)(NSString *))success
                          andFailure:(void(^)(NSError * _Nonnull))failure;

- (NSData *)defaultEntropy;

- (bc::wallet::hd_private &)masterPrivateKey;
@end

NS_ASSUME_NONNULL_END

#endif /* CNBHDWallet_Project_h */
