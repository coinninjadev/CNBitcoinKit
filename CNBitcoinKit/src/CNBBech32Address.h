//
//  CNBBech32Address.h
//  CNBitcoinKit
//
//  Created by BJ Miller on 7/9/19.
//  Copyright © 2019 Coin Ninja, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@class CNBBech32Metadata;

NS_ASSUME_NONNULL_BEGIN

@interface CNBBech32Address : NSObject

+ (NSString *)encodeBech32AddressWithHRP:(NSString *)hrpString values:(NSData *)values;
+ (CNBBech32Metadata *)decodeBech32Address:(NSString *)addressString;

@end

NS_ASSUME_NONNULL_END
