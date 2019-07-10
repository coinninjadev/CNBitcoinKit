//
//  CNBAddressHelper+Project.h
//  CNBitcoinKit
//
//  Created by BJ Miller on 7/10/19.
//  Copyright © 2019 Coin Ninja, LLC. All rights reserved.
//

#import "CNBAddressHelper.h"

#ifdef __cplusplus
  #include <bitcoin/bitcoin.hpp>
#endif

NS_ASSUME_NONNULL_BEGIN

@interface CNBAddressHelper (Project)
- (CNBPaymentOutputType)addressTypeFor:(bc::wallet::payment_address)address;
- (bc::wallet::payment_address)paymentAddressFromString:(NSString *)address;
- (NSUInteger)bytesPerChangeOutput;
- (NSUInteger)bytesPerInput;
- (NSUInteger)totalBytesWithInputCount:(NSUInteger)inputCount
                        paymentAddress:(bc::wallet::payment_address)paymentAddress
                  includeChangeAddress:(BOOL)includeChangeAddress;
@end

NS_ASSUME_NONNULL_END
