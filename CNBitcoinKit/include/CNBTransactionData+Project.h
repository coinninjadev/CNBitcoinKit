//
//  CNBTransactionData+Project.h
//  CNBitcoinKit
//
//  Created by BJ Miller on 5/29/18.
//  Copyright © 2018 Coin Ninja, LLC. All rights reserved.
//

#ifndef CNBTransactionData_Project_h
#define CNBTransactionData_Project_h

#ifdef __cplusplus
#include <bitcoin/bitcoin/coinninja/transaction/transaction_data.hpp>
#endif

#import <Foundation/Foundation.h>
#import "CNBDerivationPath.h"
#import "CNBUnspentTransactionOutput.h"

@interface CNBTransactionData (Project)

/// Convenience initializer used in testing
- (nonnull instancetype)initWithAddress:(nonnull NSString *)paymentAddress
                                   coin:(nonnull CNBBaseCoin *)coin
              unspentTransactionOutputs:(nonnull NSArray *)unspentTransactionOutputs
                                 amount:(NSUInteger)amount
                              feeAmount:(NSUInteger)feeAmount
                           changeAmount:(NSUInteger)changeAmount
                             changePath:(nullable CNBDerivationPath *)changePath
                            blockHeight:(NSUInteger)blockHeight;

/// Translation methods
+ (CNBTransactionData *)dataFromC_data:(coinninja::transaction::transaction_data)c_data;
- (coinninja::transaction::transaction_data)c_data;

@end

#endif /* CNBTransactionData_Project_h */
