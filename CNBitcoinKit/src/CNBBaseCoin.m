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
										 networkURL:(NSString *)networkURL {
	if (self = [super init]) {
		self.purpose = purpose;
		self.coin = coin;
		self.account = account;
		self.networkURL = networkURL;
	}
	return self;
}

- (instancetype)initWithPurpose:(CoinDerivation)purpose
													 coin:(CoinType)coin
												account:(NSUInteger)account {
	if (self = [self initWithPurpose:purpose
															 coin:coin
														account:account
												 networkURL:@"tcp://mainnet.libbitcoin.net:9091"]) {
	}
	return self;
}

- (instancetype)init
{
	if (self = [self initWithPurpose:BIP49
															coin:0
													 account:0]) {
	}
	return self;
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
