//
//  CNBEncryptionCipherKeys.m
//  CNBitcoinKit
//
//  Created by BJ Miller on 1/22/19.
//  Copyright © 2019 Coin Ninja, LLC. All rights reserved.
//

#import "CNBEncryptionCipherKeys.h"

@implementation CNBEncryptionCipherKeys

- (instancetype)initWithEncryptionKey:(NSData *)encryptionKey
                              hmacKey:(NSData *)hmacKey
                   ephemeralPublicKey:(NSData *)ephemeralPublicKey {
  if (self = [super initWithEncryptionKey:encryptionKey hmacKey:hmacKey]) {
    _ephemeralPublicKey = ephemeralPublicKey;
  }
  return self;
}

@end
