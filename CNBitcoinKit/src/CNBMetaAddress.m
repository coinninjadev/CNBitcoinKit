//
//  CNBMetaAddress.m
//  CNBitcoinKit
//
//  Created by BJ Miller on 5/16/18.
//  Copyright © 2018 Coin Ninja, LLC. All rights reserved.
//

#import "CNBMetaAddress.h"

@implementation CNBMetaAddress

- (instancetype)initWithAddress:(NSString *)address
                 derivationPath:(CNBDerivationPath *)derivationPath
          uncompressedPublicKey:(NSString *)uncompressedPublicKey {
  if (self = [super init]) {
    _address = address;
    _derivationPath = derivationPath;
    _uncompressedPublicKey = uncompressedPublicKey;
  }
  return self;
}
@end
