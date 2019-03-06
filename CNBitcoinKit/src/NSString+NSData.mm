//
//  NSString+NSData.m
//  CNBitcoinKit
//
//  Created by BJ Miller on 1/15/19.
//  Copyright © 2019 Coin Ninja, LLC. All rights reserved.
//

#import "NSString+NSData.h"

@implementation NSString (NSData)

- (NSData *)dataFromHexString {
  const char *chars = [self UTF8String];
  int i = 0, len = self.length;

  NSMutableData *data = [NSMutableData dataWithCapacity:len / 2];
  char byteChars[3] = {'\0','\0','\0'};
  unsigned long wholeByte;

  while (i < len) {
    byteChars[0] = chars[i++];
    byteChars[1] = chars[i++];
    wholeByte = strtoul(byteChars, NULL, 16);
    [data appendBytes:&wholeByte length:1];
  }

  return data;
}

@end
