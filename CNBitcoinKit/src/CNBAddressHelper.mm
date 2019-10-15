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
#import "CNBBaseCoin+Project.h"

#define kP2KHOutputSize 34
#define kP2SHOutputSize 32
#define kP2WPKHOutputSize 31
#define kDefaultOutputSize 32
#define kP2SHSegWitInputSize 91
#define kP2WPKHSegWitInputSize 68
#define kBaseTxBytes 11

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

- (CNBPaymentOutputType)addressTypeForAddress:(NSString *)address {
  std::string c_address{[address cStringUsingEncoding:[NSString defaultCStringEncoding]]};
  auto result{[self helper].address_type_for_address(c_address)};
  using namespace coinninja::address;
  switch (result) {
    case coinninja::address::payment_output_type::P2PKH:
      return CNBPaymentOutputType::P2PKH;
    case coinninja::address::payment_output_type::P2SH:
      return CNBPaymentOutputType::P2SH;
    case coinninja::address::payment_output_type::P2WPKH:
      return CNBPaymentOutputType::P2WPKH;
    case coinninja::address::payment_output_type::P2WSH:
      return CNBPaymentOutputType::P2WSH;
    default:
      return CNBPaymentOutputType::P2SH;
  }
}

- (NSUInteger)bytesPerChangeOutput {
  return [self helper].bytes_per_change_output();
}

- (NSUInteger)bytesPerInput {
  return [self helper].bytes_per_input();
}

- (NSUInteger)totalBytesWithInputCount:(NSUInteger)inputCount
                        paymentAddress:(NSString *)paymentAddress
                  includeChangeAddress:(BOOL)includeChangeAddress {
  auto c_input_count = static_cast<uint16_t>(inputCount);
  std::string c_address = [paymentAddress cStringUsingEncoding:[NSString defaultCStringEncoding]];
  return [self helper].total_bytes(c_input_count, c_address, includeChangeAddress);
}

// MARK: private
- (coinninja::wallet::base_coin)c_coin {
  return [self.coin c_coin];
}

- (coinninja::address::address_helper)helper {
  return coinninja::address::address_helper([self c_coin]);
}

@end
