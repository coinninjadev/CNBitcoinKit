//
//  CNBTransactionMetadata.h
//  CNBitcoinKit
//
//  Created by BJ Miller on 8/21/18.
//  Copyright © 2018 Coin Ninja, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@class CNBDerivationPath;

NS_ASSUME_NONNULL_BEGIN

@interface CNBTransactionMetadata : NSObject

@property (nonatomic, strong) NSString *txid;
@property (nonatomic, strong) NSString *encodedTx;
@property (nonatomic, strong, nullable) NSString *changeAddress;
@property (nonatomic, strong, nullable) CNBDerivationPath *changePath;
@property (nonatomic, assign, nullable) NSNumber *voutIndex;

- (instancetype)initWithTxid:(NSString *)txid encodedTx:(NSString *)encodedTx;
- (instancetype)initWithTxid:(NSString *)txid
                   encodedTx:(NSString *)encodedTx
               changeAddress:(NSString *)changeAddress
                  changePath:(CNBDerivationPath *)changePath
                   voutIndex:(NSNumber *)voutIndex;

@end

NS_ASSUME_NONNULL_END
