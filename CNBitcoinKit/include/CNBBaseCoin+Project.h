//
//  CNBBaseCoin+Project.h
//  CNBitcoinKit
//
//  Created by BJ Miller on 7/9/19.
//  Copyright © 2019 Coin Ninja, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CNBBaseCoin.h"

#ifdef __cplusplus
#include <bitcoin/bitcoin/coinninja/wallet/base_coin.hpp>
#endif

NS_ASSUME_NONNULL_BEGIN

@interface CNBBaseCoin (Project)

- (NSString  * _Nullable)bech32HRP;

+ (CNBBaseCoin *)coinFromC_Coin:(coinninja::wallet::base_coin)c_coin;
- (coinninja::wallet::base_coin)c_coin;

@end

NS_ASSUME_NONNULL_END
