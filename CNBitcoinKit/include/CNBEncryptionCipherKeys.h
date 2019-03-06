//
//  CNBEncryptionCipherKeys.h
//  CNBitcoinKit
//
//  Created by BJ Miller on 1/22/19.
//  Copyright © 2019 Coin Ninja, LLC. All rights reserved.
//

#import "CNBCipherKeys.h"
#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface CNBEncryptionCipherKeys : CNBCipherKeys

@property (nonatomic, strong) NSData *ephemeralPublicKey;

- (instancetype)initWithEncryptionKey:(NSData *)encryptionKey
                              hmacKey:(NSData *)hmacKey
                   ephemeralPublicKey:(NSData *)ephemeralPublicKey;

@end

NS_ASSUME_NONNULL_END
