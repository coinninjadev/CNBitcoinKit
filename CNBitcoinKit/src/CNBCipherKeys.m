//
//  CNBCipherKeys.m
//  CNBitcoinKit
//
//  Created by BJ Miller on 1/18/19.
//  Copyright © 2019 Coin Ninja, LLC. All rights reserved.
//

#import "CNBCipherKeys.h"

@implementation CNBCipherKeys

- (instancetype)initWithEncryptionKey:(NSData *)encryptionKey
                              hmacKey:(NSData *)hmacKey {
  if (self = [super init]) {
    _encryptionKey = encryptionKey;
    _hmacKey = hmacKey;
  }
  return self;
}

@end
