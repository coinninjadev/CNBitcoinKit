//
//  NSString+NSData.h
//  CNBitcoinKit
//
//  Created by BJ Miller on 1/15/19.
//  Copyright © 2019 Coin Ninja, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSString (NSData)
- (NSData *)dataFromHexString;
@end

NS_ASSUME_NONNULL_END
