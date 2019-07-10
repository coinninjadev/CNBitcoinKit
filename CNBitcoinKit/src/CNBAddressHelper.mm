//
//  CNBAddressHelper.m
//  CNBitcoinKit
//
//  Created by BJ Miller on 5/30/19.
//  Copyright © 2019 Coin Ninja, LLC. All rights reserved.
//

#import "CNBAddressHelper.h"
#import "CNBSegwitAddress.h"

#define kP2KHOutputSize 34
#define kP2SHOutputSize 32
#define kP2WPKHOutputSize 31
#define kP2SHSegWitInputSize 91
#define kP2WPKHSegWitInputSize 68
#define kBaseTxBytes 11

@interface CNBAddressHelper()
@property (nonatomic, retain) CNBBaseCoin *coin;
@end

@implementation CNBAddressHelper

- (instancetype)initWithCoin:(id)coin {
  if (self = [super init]) {
    _coin = coin;
  }
  return self;
}

- (bc::wallet::payment_address)paymentAddressFromString:(NSString *)address {
  std::string address_string = std::string([address UTF8String]);
  bc::wallet::payment_address payment_address(address_string);
  return payment_address;
}

- (CNBPaymentOutputType)addressTypeFor:(bc::wallet::payment_address)address {
  uint8_t version = address.version();
  if ([self addressVersionIsP2KH:version]) {
    return P2PKH;
  } else if ([self addressVersionIsP2SH:version]) {
    return P2SH;
  } else if ([self addressIsP2WPKH:address]) {
    return P2WPKH;
  } else {
    return P2WSH;
  }
}

- (NSUInteger)bytesPerChangeOutput {
  switch (self.coin.purpose) {
    case BIP49:
      return kP2SHOutputSize;

    case BIP84:
      return kP2WPKHOutputSize;

    default:
      break;
  }
  return kP2SHOutputSize;
}

- (NSUInteger)bytesPerInput {
  switch (self.coin.purpose) {
    case BIP49:
      return kP2SHSegWitInputSize;

    case BIP84:
      return kP2WPKHSegWitInputSize;

    default:
      break;
  }
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
  if ([self addressVersionIsP2KH:address.version()]) {
    return kP2KHOutputSize;
  } else if ([self addressVersionIsP2SH:address.version()]) {
    return kP2SHOutputSize;
  } else if ([self addressIsP2WPKH:address]) {
    return kP2WPKHOutputSize;
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

- (BOOL)addressIsP2WPKH:(bc::wallet::payment_address)payment_address {
  NSString *address = [NSString stringWithCString:payment_address.encoded().c_str() encoding:[NSString defaultCStringEncoding]];
  return [CNBSegwitAddress isValidSegwitAddress:address];
}

@end
