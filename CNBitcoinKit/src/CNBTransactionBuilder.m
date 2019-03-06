//
//  CNBTransactionBuilder.m
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
  return [wallet buildTransactionMetadataWithTransactionData:data];
}

@end
