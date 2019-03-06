//
//  CNBTransactionData+Project.h
//  CNBitcoinKit
//
//  Created by BJ Miller on 5/29/18.
//  Copyright © 2018 Coin Ninja, LLC. All rights reserved.
//

#ifndef CNBTransactionData_Project_h
#define CNBTransactionData_Project_h

#endif /* CNBTransactionData_Project_h */

#import <Foundation/Foundation.h>
#import "CNBDerivationPath.h"
#import "CNBUnspentTransactionOutput.h"

@interface CNBTransactionData (Project)

/// Convenience initializer used in testing
- (nonnull instancetype)initWithAddress:(nonnull NSString *)paymentAddress
              unspentTransactionOutputs:(nonnull NSArray *)unspentTransactionOutputs
                                 amount:(NSUInteger)amount
                              feeAmount:(NSUInteger)feeAmount
                           changeAmount:(NSUInteger)changeAmount
                             changePath:(nullable CNBDerivationPath *)changePath
                            blockHeight:(NSUInteger)blockHeight;

@end
