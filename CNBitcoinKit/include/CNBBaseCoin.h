//
//  CNBBaseCoin.h
//  CNBitcoinKit
//
//  Created by BJ Miller on 4/11/18.
//  Copyright © 2018 Coin Ninja, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, CoinDerivation) {
  BIP32 = 32,
  BIP44 = 44,
  BIP49 = 49,
  BIP84 = 84
};

typedef NS_ENUM(NSUInteger, CoinType) {
  MainNet = 0,
  TestNet = 1
};

NS_ASSUME_NONNULL_BEGIN

@interface CNBBaseCoin : NSObject

@property (nonatomic, assign) CoinDerivation purpose;
@property (nonatomic, assign) CoinType coin;
@property (nonatomic, assign) NSUInteger account;
@property (nonatomic, strong, nullable) NSString *networkURL;

/// Designated initializer
- (instancetype)initWithPurpose:(CoinDerivation)purpose
													 coin:(CoinType)coin
												account:(NSUInteger)account
										 networkURL:(NSString *)networkURL;

/// Convenient intializer: Uses default networkURL of mainnet.
- (instancetype)initWithPurpose:(CoinDerivation)purpose
													 coin:(CoinType)coin
												account:(NSUInteger)account;
@end

NS_ASSUME_NONNULL_END
