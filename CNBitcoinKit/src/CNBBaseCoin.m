//
//  CNBBaseCoin.m
//  CNBitcoinKit
//
//  Created by BJ Miller on 4/11/18.
//  Copyright © 2018 Coin Ninja, LLC. All rights reserved.
//

#import "CNBBaseCoin.h"

@implementation CNBBaseCoin

// Designated initializer
- (instancetype)initWithPurpose:(CoinDerivation)purpose
													 coin:(CoinType)coin
												account:(NSUInteger)account
										 networkURL:(NSString * _Nullable)networkURL {
  if (self = [super init]) {
    _purpose = purpose;
    _coin = coin;
    _account = account;
    _networkURL = networkURL;
  }
  return self;
}

- (instancetype)initWithPurpose:(CoinDerivation)purpose
													 coin:(CoinType)coin
												account:(NSUInteger)account {
  return [self initWithPurpose:purpose coin:coin account:account networkURL:nil];
}

- (instancetype)init {
  return [self initWithPurpose:BIP49 coin:MainNet account:0 networkURL:nil];
}

- (NSString  * _Nullable)bech32HRP {
  switch (self.coin) {
    case MainNet:
      return @"bc";
      break;
    case TestNet:
      return @"tb";
      break;

    default:
      return nil;
      break;
  }
}

@end
