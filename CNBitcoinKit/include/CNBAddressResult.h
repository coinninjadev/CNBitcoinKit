//
//  CNBAddressResult.h
//  CNBitcoinKit
//
//  Created by BJ Miller on 6/18/18.
//  Copyright © 2018 Coin Ninja, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CNBAddressResult : NSObject

@property (nonatomic, strong) NSString *address;

/**
 isReceiveAddress is a Boolean property describing whether the found address is a receive address or not (i.e., a change address).
 */
@property (nonatomic, assign) BOOL isReceiveAddress;

- (instancetype)initWithAddress:(NSString *)address isReceiveAddress:(BOOL)isReceiveAddress;

@end
