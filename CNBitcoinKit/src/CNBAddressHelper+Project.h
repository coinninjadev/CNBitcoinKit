//
//  CNBAddressHelper+Project.h
//  CNBitcoinKit
//
//  Created by BJ Miller on 7/10/19.
//  Copyright © 2019 Coin Ninja, LLC. All rights reserved.
//

#ifndef CNBAddressHelper_Project_h
#define CNBAddressHelper_Project_h

#import "CNBAddressHelper.h"

#ifdef __cplusplus
#include <bitcoin/bitcoin.hpp>
#include <bitcoin/bitcoin/coinninja/address/address_helper.hpp>
#endif

NS_ASSUME_NONNULL_BEGIN

@interface CNBAddressHelper (Project)
- (bc::wallet::payment_address)paymentAddressFromString:(NSString *)address;
- (NSUInteger)totalBytesWithInputCount:(NSUInteger)inputCount
                        paymentAddress:(NSString *)paymentAddress
                  includeChangeAddress:(BOOL)includeChangeAddress;
@end

NS_ASSUME_NONNULL_END

#endif /* CNBAddressHelper_Project_h */
