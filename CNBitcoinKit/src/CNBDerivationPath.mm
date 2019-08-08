//
//  CNBDerivationPath.m
//  CNBitcoinKit
//
//  Created by Mitchell on 5/14/18.
//  Copyright © 2018 Coin Ninja, LLC. All rights reserved.
//

#import "CNBDerivationPath.h"
#import "CNBDerivationPath+Project.h"

using namespace coinninja::wallet;

@implementation CNBDerivationPath

- (instancetype)initWithPurpose:(CoinDerivation)purpose
                       coinType:(CoinType)coinType
                        account:(NSUInteger)account
                         change:(NSUInteger)change
                          index:(NSUInteger)index {
  if (self = [super init]) {
    self.purpose = purpose;
    self.coinType = coinType;
    self.account = account;
    self.change = change;
    self.index = index;
  }

  return self;
}

- (NSUInteger)purposeValue {
  return (int)self.purpose;
}

- (NSUInteger)coinValue {
  return (int)self.coinType;
}

- (NSString *)description {
  return [NSString stringWithFormat:@"m/%lu'/%lu'/%lu'/%lu/%lu", [self purposeValue], [self coinValue], self.account, self.change, self.index];
}

// MARK: project access level
+ (CNBDerivationPath *)pathFromC_path:(derivation_path)c_path {
  CoinDerivation purposeType = CoinDerivation::BIP49;
  CoinType coinType = CoinType::MainNet;
  NSUInteger offset = 0x80000000; // 0x80000000 is hardened offset
  NSUInteger purposeValue = c_path.get_hardened_purpose() - offset;
  NSUInteger coinValue = c_path.get_hardened_coin() - offset;
  NSUInteger account = c_path.get_hardened_account() - offset;
  NSUInteger change = c_path.get_change();
  NSUInteger index = c_path.get_index();

  switch (purposeValue) {
    case 84:
      purposeType = CoinDerivation::BIP84;
      break;
    default:
      break;
  }

  switch (coinValue) {
    case 1:
      coinType = CoinType::TestNet;
      break;
    default:
      break;
  }

  CNBDerivationPath *path = [[CNBDerivationPath alloc] initWithPurpose:purposeType
                                                              coinType:coinType
                                                               account:account
                                                                change:change
                                                                 index:index];
  return path;
}

- (derivation_path)c_path {
  coinninja::wallet::derivation_path path{
    static_cast<uint32_t>([self purpose]),
    static_cast<uint32_t>([self coinType]),
    static_cast<uint32_t>([self account]),
    static_cast<uint32_t>([self change]),
    static_cast<uint32_t>([self index])
  };
  return path;
}

@end
