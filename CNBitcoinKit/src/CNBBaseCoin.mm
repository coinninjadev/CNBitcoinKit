//
//  CNBBaseCoin.m
//  CNBitcoinKit
//
//  Created by BJ Miller on 4/11/18.
//  Copyright © 2018 Coin Ninja, LLC. All rights reserved.
//

#import "CNBBaseCoin.h"
#import "CNBBaseCoin+Project.h"

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
  return [self initWithPurpose:CoinDerivation::BIP49 coin:CoinType::MainNet account:0 networkURL:nil];
}

- (NSString * _Nullable)bech32HRP {
  std::string hrp{[self c_coin].get_bech32_hrp()};
  if (hrp.size() == 0) {
    return nil;
  } else {
    return [NSString stringWithCString:hrp.c_str() encoding:[NSString defaultCStringEncoding]];
  }
}

// project
+ (CNBBaseCoin *)coinFromC_Coin:(coinninja::wallet::base_coin)c_coin {
  CNBBaseCoin *newCoin = [[CNBBaseCoin alloc] init];

  switch (c_coin.get_purpose()) {
    case coinninja::wallet::coin_derivation_purpose::BIP84:
      newCoin.purpose = CoinDerivation::BIP84;
      break;
    default:
      newCoin.purpose = CoinDerivation::BIP49;
      break;
  }

  switch (c_coin.get_coin()) {
    case coinninja::wallet::coin_derivation_coin::MainNet:
      newCoin.coin = CoinType::MainNet;
      break;
    default:
      newCoin.coin = CoinType::TestNet;
      break;
  }

  newCoin.account = c_coin.get_account();

  return newCoin;
}

- (coinninja::wallet::base_coin)c_coin {
  coinninja::wallet::coin_derivation_purpose purpose_type{coinninja::wallet::coin_derivation_purpose::BIP49};
  coinninja::wallet::coin_derivation_coin coin_type{coinninja::wallet::coin_derivation_coin::MainNet};
  int account{};

  switch ([self purpose]) {
    case CoinDerivation::BIP84:
      purpose_type = coinninja::wallet::coin_derivation_purpose::BIP84;
      break;
    default:
      break;
  }

  switch ([self coin]) {
    case CoinType::TestNet:
      coin_type = coinninja::wallet::coin_derivation_coin::TestNet;
      break;
    default:
      break;
  }

  account = (int)[self account];

  coinninja::wallet::base_coin c_coin{purpose_type, coin_type, account};

  return c_coin;
}

@end
