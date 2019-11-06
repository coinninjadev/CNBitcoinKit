//
//  CNBSegwitAddress.h
//  CNBitcoinKit
//
//  Created by BJ Miller on 7/9/19.
//  Copyright © 2019 Coin Ninja, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@class CNBWitnessMetadata;

NS_ASSUME_NONNULL_BEGIN

@interface CNBSegwitAddress : NSObject

+ (CNBWitnessMetadata *)decodeSegwitAddressWithHRP:(NSString *)hrpString address:(NSString *)addressString;
+ (NSString *)encodeSegwitAddressWithHRP:(NSString *)hrpString witnessMetadata:(CNBWitnessMetadata *)metadata;
+ (BOOL)isValidP2WPKHAddress:(NSString *)address;
+ (BOOL)isValidP2WSHAddress:(NSString *)address;
+ (NSString *)hrpFromAddress:(NSString *)address;

@end

NS_ASSUME_NONNULL_END
