//
//  CNBTransactionBuilder.h
//  CNBitcoinKit
//
//  Created by Mitchell on 5/14/18.
//  Copyright © 2018 Coin Ninja, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CNBTransactionData.h"
#import "CNBUnspentTransactionOutput.h"

@class CNBHDWallet;
@class CNBTransactionMetadata;

NS_ASSUME_NONNULL_BEGIN

@interface CNBTransactionBuilder : NSObject

- (void)broadcastWithTransactionData:(CNBTransactionData *)data
                              wallet:(CNBHDWallet *)wallet
                             success:(void (^)(NSString *))success
                             failure:(void (^)(NSError *))failure;

- (CNBTransactionMetadata *)generateTxMetadataWithTransactionData:(CNBTransactionData *)data
                                                           wallet:(CNBHDWallet *)wallet;

@end

NS_ASSUME_NONNULL_END
