//
//  CNBBech32Address.m
//  CNBitcoinKit
//
//  Created by BJ Miller on 7/9/19.
//  Copyright © 2019 Coin Ninja, LLC. All rights reserved.
//

#import "CNBBech32Address.h"
#import "CNBBech32Metadata.h"
#import "NSData+CNBitcoinKit.h"
#include "bech32.h"

@implementation CNBBech32Address

- (NSString *)encodeBech32AddressWithHRP:(NSString *)hrpString values:(NSData *)values {
  std::string hrp = [hrpString cStringUsingEncoding:[NSString defaultCStringEncoding]];
  std::vector<uint8_t> pubkey = [values dataChunk];
  std::string encoded = bech32::encode(hrp, pubkey);
  return [NSString stringWithCString:encoded.c_str() encoding:[NSString defaultCStringEncoding]];
}

- (CNBBech32Metadata *)decodeBech32Address:(NSString *)addressString {
  NSStringEncoding cEncoding = [NSString defaultCStringEncoding];
  std::string bech32String = [addressString cStringUsingEncoding:cEncoding];
  auto pair = bech32::decode(bech32String);
  CNBBech32Metadata *metadata = [[CNBBech32Metadata alloc] init];
  metadata.hrp = [NSString stringWithCString:pair.first.c_str() encoding:cEncoding];
  metadata.data = [NSData dataWithBytes:pair.second.data() length:pair.second.size()];
  return metadata;
}

@end
