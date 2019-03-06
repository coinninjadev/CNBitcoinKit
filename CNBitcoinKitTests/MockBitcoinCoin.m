//
//  MockBitcoinCoin.m
//  CNBitcoinKitTests
//
//  Created by BJ Miller on 4/11/18.
//  Copyright © 2018 Coin Ninja, LLC. All rights reserved.
//

#import "MockBitcoinCoin.h"

@implementation MockBitcoinCoin

- (instancetype)init
{
	self = [super init];
	if (self) {
		[self setPurpose:BIP49];
		[self setCoin:0];
		[self setAccount:0];
	}
	return self;
}
@end
