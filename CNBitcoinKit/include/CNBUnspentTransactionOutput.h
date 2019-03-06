//
//  CNBUnspentTransactionOutput.h
//  CNBitcoinKit
//
//  Created by Mitchell on 5/14/18.
//  Copyright © 2018 Coin Ninja, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CNBDerivationPath.h"

NS_ASSUME_NONNULL_BEGIN

@interface CNBUnspentTransactionOutput : NSObject

@property (nonatomic, strong) NSString *txId;
@property (nonatomic, assign) NSUInteger index;
@property (nonatomic, assign) NSUInteger amount;
@property (nonatomic, strong) CNBDerivationPath *path;
@property (nonatomic) BOOL isConfirmed;

-(instancetype)initWithId:(NSString*)txId
                    index:(NSUInteger)index
                   amount:(NSUInteger)amount
           derivationPath:(CNBDerivationPath*)path
              isConfirmed:(BOOL)confirmed;

@end

NS_ASSUME_NONNULL_END
