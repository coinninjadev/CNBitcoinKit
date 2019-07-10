//
//  CNBAddressHelper.h
//  CNBitcoinKit
//
//  Created by BJ Miller on 5/30/19.
//  Copyright © 2019 Coin Ninja, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CNBBaseCoin.h"

#ifdef __cplusplus
  #include <bitcoin/bitcoin.hpp>
#endif

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, CNBPaymentOutputType) {
  P2PKH = 0,
  P2SH = 1,
  P2WPKH = 2,
  P2WSH = 3
};

@interface CNBAddressHelper : NSObject

- (instancetype)initWithCoin:(CNBBaseCoin *)coin;

- (bc::wallet::payment_address)paymentAddressFromString:(NSString *)address;
- (CNBPaymentOutputType)addressTypeFor:(bc::wallet::payment_address)address;
- (NSUInteger)bytesPerChangeOutput;
- (NSUInteger)bytesPerInput;
- (NSUInteger)totalBytesWithInputCount:(NSUInteger)inputCount
                        paymentAddress:(bc::wallet::payment_address)paymentAddress
                  includeChangeAddress:(BOOL)includeChangeAddress;

@end

NS_ASSUME_NONNULL_END
