//
//  CNBMetaAddress.h
//  CNBitcoinKit
//
//  Created by BJ Miller on 5/16/18.
//  Copyright © 2018 Coin Ninja, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CNBDerivationPath.h"

NS_ASSUME_NONNULL_BEGIN

@interface CNBMetaAddress : NSObject

@property (nonatomic, strong) NSString *address;
@property (nonatomic, strong) CNBDerivationPath *derivationPath;
/**
 Base64 encoded string representation of the uncompressed public key for this address.
 */
@property (nonatomic, strong, nullable) NSString *uncompressedPublicKey;

- (instancetype)initWithAddress:(NSString *)address
                 derivationPath:(CNBDerivationPath *)derivationPath
          uncompressedPublicKey:(NSString * _Nullable)uncompressedPublicKey;

@end

NS_ASSUME_NONNULL_END
