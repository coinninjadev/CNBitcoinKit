//
//  CNBAddressHelper.h
//  CNBitcoinKit
//
//  Created by BJ Miller on 5/30/19.
//  Copyright © 2019 Coin Ninja, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#ifdef __cplusplus
  #include <bitcoin/bitcoin.hpp>
#endif

NS_ASSUME_NONNULL_BEGIN

@interface CNBAddressHelper : NSObject

- (bc::wallet::payment_address)paymentAddressFromString:(NSString *)address;
- (BOOL)addressIsP2KH:(bc::wallet::payment_address)address;
- (BOOL)addressIsP2SH:(bc::wallet::payment_address)address;
- (NSUInteger)bytesPerChangeOutput;
- (NSUInteger)bytesPerInput;
- (NSUInteger)totalBytesWithInputCount:(NSUInteger)inputCount
                        paymentAddress:(bc::wallet::payment_address)paymentAddress
                  includeChangeAddress:(BOOL)includeChangeAddress;

@end

NS_ASSUME_NONNULL_END
