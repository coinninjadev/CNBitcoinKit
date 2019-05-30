//
//  CNBAddressHelper.m
//  CNBitcoinKit
//
//  Created by BJ Miller on 5/30/19.
//  Copyright © 2019 Coin Ninja, LLC. All rights reserved.
//

#import "CNBAddressHelper.h"

#define kP2KHOutputSize 34
#define kP2SHOutputSize 32
#define kP2SHSegWitInputSize 91
#define kBaseTxBytes 11

@implementation CNBAddressHelper

- (bc::wallet::payment_address)paymentAddressFromString:(NSString *)address {
  std::string address_string = std::string([address UTF8String]);
  bc::wallet::payment_address payment_address(address_string);
  return payment_address;
}

- (BOOL)addressIsP2KH:(bc::wallet::payment_address)address {
  uint8_t version = address.version();
  return [self addressVersionIsP2KH:version];
}

- (BOOL)addressIsP2SH:(bc::wallet::payment_address)address {
  uint8_t version = address.version();
  return [self addressVersionIsP2SH:version];
}

- (NSUInteger)bytesPerChangeOutput {
  return kP2SHOutputSize;
}

- (NSUInteger)bytesPerInput {
  return kP2SHSegWitInputSize;
}

- (NSUInteger)totalBytesWithInputCount:(NSUInteger)inputCount
                        paymentAddress:(bc::wallet::payment_address)paymentAddress
                  includeChangeAddress:(BOOL)includeChangeAddress {
  return (kP2SHSegWitInputSize * inputCount) +
  [self bytesPerOutputAddress:paymentAddress] +
  (includeChangeAddress ? kP2SHOutputSize : 0) +
  kBaseTxBytes;
}

// MARK: private
- (NSUInteger)bytesPerOutputAddress:(bc::wallet::payment_address)address {
  if ([self addressIsP2KH:address]) {
    return kP2KHOutputSize;
  } else if ([self addressIsP2SH:address]) {
    return kP2SHOutputSize;
  } else {
    return 32; // default
  }
}

- (BOOL)addressVersionIsP2KH:(uint8_t)version {
  return version == bc::wallet::payment_address::mainnet_p2kh ||
  version == bc::wallet::payment_address::testnet_p2kh;
}

- (BOOL)addressVersionIsP2SH:(uint8_t)version {
  return version == bc::wallet::payment_address::mainnet_p2sh ||
  version == bc::wallet::payment_address::testnet_p2sh;
}

@end
