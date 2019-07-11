//
//  CNBAddressHelper.m
//  CNBitcoinKit
//
//  Created by BJ Miller on 5/30/19.
//  Copyright © 2019 Coin Ninja, LLC. All rights reserved.
//

#import "CNBAddressHelper.h"
#import "CNBAddressHelper+Project.h"
#import "CNBSegwitAddress.h"

#define kP2KHOutputSize 34
#define kP2SHOutputSize 32
#define kP2WPKHOutputSize 31
#define kDefaultOutputSize 32
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
  } else {
    return P2PKH;
  }
}

- (CNBPaymentOutputType)addressTypeForAddress:(NSString *)address {
  if ([self addressIsP2WPKH:address]) {
    return P2WPKH;
  } else {
    std::string address_string = [address cStringUsingEncoding:[NSString defaultCStringEncoding]];
    bc::wallet::payment_address payment_address(address_string);
    return [self addressTypeFor:payment_address];
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
                        paymentAddress:(NSString *)paymentAddress
                  includeChangeAddress:(BOOL)includeChangeAddress {
  return (kP2SHSegWitInputSize * inputCount) +
  [self bytesPerOutputAddress:paymentAddress] +
  (includeChangeAddress ? kP2SHOutputSize : 0) +
  kBaseTxBytes;
}

// MARK: private
- (NSUInteger)bytesPerOutputAddress:(NSString *)address {
  NSUInteger outputSize = 0;
  if ([self addressIsP2WPKH:address]) {
    outputSize = kP2WPKHOutputSize;
  } else {
    uint8_t version = [self paymentAddressFromString:address].version();
    if ([self addressVersionIsP2KH:version]) {
      outputSize = kP2KHOutputSize;
    } else if ([self addressVersionIsP2SH:version]) {
      outputSize = kP2SHOutputSize;
    } else {
      outputSize = kDefaultOutputSize;
    }
  }
  return outputSize;
}

- (BOOL)addressVersionIsP2KH:(uint8_t)version {
  return version == bc::wallet::payment_address::mainnet_p2kh ||
  version == bc::wallet::payment_address::testnet_p2kh;
}

- (BOOL)addressVersionIsP2SH:(uint8_t)version {
  return version == bc::wallet::payment_address::mainnet_p2sh ||
  version == bc::wallet::payment_address::testnet_p2sh;
}

- (BOOL)addressIsP2WPKH:(NSString *)address {
  return [CNBSegwitAddress isValidSegwitAddress:address];
}

@end
