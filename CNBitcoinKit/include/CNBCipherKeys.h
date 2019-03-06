//
//  CNBCipherKeys.h
//  CNBitcoinKit
//
//  Created by BJ Miller on 1/18/19.
//  Copyright © 2019 Coin Ninja, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface CNBCipherKeys : NSObject

@property (nonatomic, strong) NSData *encryptionKey;
@property (nonatomic, strong) NSData *hmacKey;

- (instancetype)initWithEncryptionKey:(NSData *)encryptionKey
                              hmacKey:(NSData *)hmacKey;

@end

NS_ASSUME_NONNULL_END
