//
//  CNBTransactionData.h
//  CNBitcoinKit
//
//  Created by Mitchell on 5/14/18.
//  Copyright © 2018 Coin Ninja, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CNBDerivationPath.h"
#import "CNBUnspentTransactionOutput.h"

@interface CNBTransactionData : NSObject

@property (nonnull, nonatomic, strong) NSString *paymentAddress;
@property (nonnull, nonatomic, strong) NSArray<CNBUnspentTransactionOutput *> *unspentTransactionOutputs;
@property (nonatomic, assign) NSUInteger amount;
@property (nonatomic, assign) NSUInteger feeAmount;
@property (nonatomic, assign) NSUInteger changeAmount;
@property (nullable, nonatomic, strong) CNBDerivationPath *changePath;
@property (nonatomic, assign) NSUInteger locktime;

- (BOOL)shouldAddChangeToTransaction;

/**
 Create transaction data object using a fee rate, calculating fee via number of inputs and outputs. Estimate 100 bytes per input/output, times fee rate. For example, 1 input and 2 outputs would have an estimated size of 300 bytes, times 5 satoshi fee rate, would equal 1500 satoshis for a fee.

 @param paymentAddress The address to which you want to send currency.
 @param unspentTransactionOutputs An array of all available UTXOs, which will be selected by this method.
 @param amount The amount which you would like to send to the receipient.
 @param feeRate The fee rate to be multiplied by the estimated transaction size.
 @param changePath The derivative path for receiving change, if any.
 @param blockHeight The current block height, used to calculate the locktime (blockHeight + 1).
 @return Returns an instantiated object if fully able to satisfy amount+fee with UTXOs, or nil if insufficient funds.
 */
- (nullable instancetype)initWithAddress:(nonnull NSString *)paymentAddress
                 fromAllAvailableOutputs:(nonnull NSArray<CNBUnspentTransactionOutput *> *)unspentTransactionOutputs
                           paymentAmount:(NSUInteger)amount
                                 feeRate:(NSUInteger)feeRate
                              changePath:(nullable CNBDerivationPath *)changePath
                             blockHeight:(NSUInteger)blockHeight;

/**
 Create transaction data object with a flat fee, versus calculated via number of inputs/outputs.

 @param paymentAddress The address to which you want to send currency.
 @param unspentTransactionOutputs An array of all available UTXOs, which will be selected by this method.
 @param amount The amount which you would like to send to the receipient.
 @param flatFee The flat-fee to pay, NOT a rate. This fee, added to amount, will equal the total deducted from the wallet.
 @param changePath The derivative path for receiving change, if any.
 @param blockHeight The current block height, used to calculate the locktime (blockHeight + 1).
 @return Returns an instantiated object if fully able to satisfy amount+fee with UTXOs, or nil if insufficient funds.
 */
- (nullable instancetype)initWithAddress:(nonnull NSString *)paymentAddress
                 fromAllAvailableOutputs:(nonnull NSArray<CNBUnspentTransactionOutput *> *)unspentTransactionOutputs
                           paymentAmount:(NSUInteger)amount
                                 flatFee:(NSUInteger)flatFee
                              changePath:(nullable CNBDerivationPath *)changePath
                             blockHeight:(NSUInteger)blockHeight;

@end

