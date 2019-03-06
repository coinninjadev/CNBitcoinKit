//
//  CNBTransactionMetadata.m
//  CNBitcoinKit
//
//  Created by BJ Miller on 8/21/18.
//  Copyright © 2018 Coin Ninja, LLC. All rights reserved.
//

#import "CNBTransactionMetadata.h"
#import "CNBDerivationPath.h"

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
@end
