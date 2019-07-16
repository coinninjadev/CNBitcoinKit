//
//  CNBBech32Metadata.h
//  CNBitcoinKit
//
//  Created by BJ Miller on 7/9/19.
//  Copyright © 2019 Coin Ninja, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface CNBBech32Metadata : NSObject
@property (nonatomic, retain) NSString *hrp;
@property (nonatomic, retain) NSData *data;
@end

NS_ASSUME_NONNULL_END
