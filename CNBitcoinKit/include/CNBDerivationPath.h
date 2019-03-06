//
//  CNBDerivationPath.h
//  CNBitcoinKit
//
//  Created by Mitchell on 5/14/18.
//  Copyright © 2018 Coin Ninja, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CNBBaseCoin.h"

NS_ASSUME_NONNULL_BEGIN

@interface CNBDerivationPath : NSObject

@property (nonatomic, assign) CoinDerivation purpose;
@property (nonatomic, assign) CoinType coinType;
@property (nonatomic, assign) NSUInteger account;
@property (nonatomic, assign) NSUInteger change;
@property (nonatomic, assign) NSUInteger index;

- (instancetype)initWithPurpose:(CoinDerivation)purpose
                       coinType:(CoinType)coinType
                        account:(NSUInteger)account
                         change:(NSUInteger)change
                          index:(NSUInteger)index;

- (NSUInteger)purposeValue;
- (NSUInteger)coinValue;

@end

NS_ASSUME_NONNULL_END
