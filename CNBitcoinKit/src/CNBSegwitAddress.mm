//
//  CNBSegwitAddress.m
//  CNBitcoinKit
//
//  Created by BJ Miller on 7/9/19.
//  Copyright © 2019 Coin Ninja, LLC. All rights reserved.
//

#import "CNBSegwitAddress.h"
#import "CNBWitnessMetadata.h"
#include "segwit_addr.h"
#import "NSData+CNBitcoinKit.h"

@implementation CNBSegwitAddress

+ (CNBWitnessMetadata *)decodeSegwitAddressWithHRP:(NSString *)hrpString address:(NSString *)addressString {
  std::string hrp = [hrpString cStringUsingEncoding:[NSString defaultCStringEncoding]];
  std::string addr = [addressString cStringUsingEncoding:[NSString defaultCStringEncoding]];
  std::pair<int, std::vector<uint8_t>> dec(segwit_addr::decode(hrp, addr));
  CNBWitnessMetadata *metadata = [[CNBWitnessMetadata alloc] init];
  metadata.witver = dec.first;
  metadata.witprog = [NSData dataWithBytes:dec.second.data() length:dec.second.size()];
  return metadata;
}

+ (NSString *)encodeSegwitAddressWithHRP:(NSString *)hrpString witnessMetadata:(CNBWitnessMetadata *)metadata {
  std::string hrp = [hrpString cStringUsingEncoding:[NSString defaultCStringEncoding]];
  std::vector<uint8_t> witprog = [[metadata witprog] dataChunk];
  std::string encoded = segwit_addr::encode(hrp, (int)metadata.witver, witprog);
  return [NSString stringWithCString:encoded.c_str() encoding:[NSString defaultCStringEncoding]];
}

@end
