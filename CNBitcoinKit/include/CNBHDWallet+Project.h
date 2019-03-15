//
//  CNBHDWallet+Project.h
//  CNBitcoinKit
//
//  Created by Mitchell on 5/16/18.
//  Copyright © 2018 Coin Ninja, LLC. All rights reserved.
//

#ifndef CNBHDWallet_Project_h
#define CNBHDWallet_Project_h

#endif /* CNBHDWallet_Project_h */

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

@end

NS_ASSUME_NONNULL_END
