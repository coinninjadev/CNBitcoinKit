//
//  CNBAddressResult.m
//  CNBitcoinKit
//
//  Created by BJ Miller on 6/18/18.
//  Copyright © 2018 Coin Ninja, LLC. All rights reserved.
//

#import "CNBAddressResult.h"

@implementation CNBAddressResult

- (instancetype)initWithAddress:(NSString *)address isReceiveAddress:(BOOL)isReceiveAddress {
  if (self = [super init]) {
    _address = address;
    _isReceiveAddress = isReceiveAddress;
  }
  return self;
}

@end
