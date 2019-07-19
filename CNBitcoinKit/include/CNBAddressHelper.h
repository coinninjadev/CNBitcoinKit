//
//  CNBAddressHelper.h
//  CNBitcoinKit
//
//  Created by BJ Miller on 5/30/19.
//  Copyright © 2019 Coin Ninja, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CNBBaseCoin.h"

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, CNBPaymentOutputType) {
  P2PKH = 0,
  P2SH = 1,
  P2WPKH = 2,
  P2WSH = 3
};

@interface CNBAddressHelper : NSObject

@property (nonatomic, retain, readonly) CNBBaseCoin *coin;

- (instancetype)initWithCoin:(CNBBaseCoin *)coin;
- (CNBPaymentOutputType)addressTypeForAddress:(NSString *)address;

@end

NS_ASSUME_NONNULL_END
