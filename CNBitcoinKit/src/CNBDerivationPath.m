//
//  CNBDerivationPath.m
//  CNBitcoinKit
//
//  Created by Mitchell on 5/14/18.
//  Copyright © 2018 Coin Ninja, LLC. All rights reserved.
//

#import "CNBDerivationPath.h"

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

@end
