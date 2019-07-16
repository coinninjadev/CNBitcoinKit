//
//  CNBWitnessMetadata.m
//  CNBitcoinKit
//
//  Created by BJ Miller on 7/9/19.
//  Copyright © 2019 Coin Ninja, LLC. All rights reserved.
//

#import "CNBWitnessMetadata.h"

@implementation CNBWitnessMetadata

- (instancetype)initWithWitVer:(NSInteger)witver witProg:(NSData *)witprog {
  if (self = [super init]) {
    _witver = witver;
    _witprog = witprog;
  }

  return self;
}

@end
