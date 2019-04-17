//
//  CNBTransactionData.m
//  CNBitcoinKit
//
//  Created by Mitchell on 5/14/18.
//  Copyright © 2018 Coin Ninja, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CNBTransactionData.h"

@implementation CNBTransactionData

- (nonnull instancetype)initWithAddress:(nonnull NSString *)paymentAddress
              unspentTransactionOutputs:(nonnull NSArray *)unspentTransactionOutputs
                                 amount:(NSUInteger)amount
                              feeAmount:(NSUInteger)feeAmount
                           changeAmount:(NSUInteger)changeAmount
                             changePath:(nullable CNBDerivationPath *)changePath
                            blockHeight:(NSUInteger)blockHeight {
  if (self = [super init]) {
    _paymentAddress = paymentAddress;
    _unspentTransactionOutputs = unspentTransactionOutputs;
    _amount = amount;
    _feeAmount = feeAmount;
    _changeAmount = changeAmount;
    _changePath = changePath;
    _locktime = blockHeight;
  }

  return self;
}

- (nullable instancetype)initWithAddress:(NSString *)paymentAddress
                 fromAllAvailableOutputs:(NSArray<CNBUnspentTransactionOutput *> *)allUnspentTransactionOutputs
                           paymentAmount:(NSUInteger)amount
                                 feeRate:(NSUInteger)feeRate
                              changePath:(nullable CNBDerivationPath *)changePath
                             blockHeight:(NSUInteger)blockHeight {
  if (self = [super init]) {
    _paymentAddress = paymentAddress;
    _amount = amount;
    _unspentTransactionOutputs = @[];
    _feeAmount = 0;
    _locktime = blockHeight;
    NSMutableArray<CNBUnspentTransactionOutput *> *mutableOutputsFromAll = [allUnspentTransactionOutputs mutableCopy];
    NSMutableArray<CNBUnspentTransactionOutput *> *outputsToUse = [@[] mutableCopy];

    NSInteger totalFromUTXOs = 0;

    NSInteger numberOfInputsAndOutputs = 1;  // assume already one output

    do {
      // early exit if insufficient funds
      if (mutableOutputsFromAll.count == 0) {
        return nil;
      }

      // get a utxo
      CNBUnspentTransactionOutput *output = [mutableOutputsFromAll objectAtIndex:0];
      [mutableOutputsFromAll removeObjectAtIndex:0];
      [outputsToUse addObject:output];
      numberOfInputsAndOutputs += 1;

      _feeAmount = [self bytesPerInputOrOutput] * numberOfInputsAndOutputs * feeRate;

      totalFromUTXOs += output.amount;

      NSInteger possibleChange = totalFromUTXOs - (NSInteger)amount - (NSInteger)_feeAmount;
      NSInteger tempChangeAmount = MAX(0, possibleChange);
      _changeAmount = (NSUInteger)tempChangeAmount;

      if (totalFromUTXOs >= amount && tempChangeAmount > 0 && _changePath == nil) {
        numberOfInputsAndOutputs += 1;
        _feeAmount = [self bytesPerInputOrOutput] * numberOfInputsAndOutputs * feeRate;
        _changePath = changePath;
        _changeAmount = MAX(0, (totalFromUTXOs - (NSInteger)amount - (NSInteger)_feeAmount));

        NSUInteger feePerInput = feeRate * [self bytesPerInputOrOutput];
        if ([self isEquitableToAddChangeForChangeAmount:_changeAmount feePerInput:feePerInput]) {
          _changePath = nil;
          _changeAmount = 0;
          numberOfInputsAndOutputs -= 1;
        }
      }

    } while (totalFromUTXOs < (_feeAmount + amount));

    _unspentTransactionOutputs = [outputsToUse copy];
  }

  return self;
}

- (instancetype)initWithAddress:(NSString *)paymentAddress
        fromAllAvailableOutputs:(NSArray<CNBUnspentTransactionOutput *> *)allUnspentTransactionOutputs
                  paymentAmount:(NSUInteger)amount
                        flatFee:(NSUInteger)flatFee
                     changePath:(CNBDerivationPath *)changePath
                    blockHeight:(NSUInteger)blockHeight {
  if (self = [super init]) {
    _paymentAddress = paymentAddress;
    _amount = amount;
    _unspentTransactionOutputs = @[];
    _feeAmount = flatFee;
    _locktime = blockHeight;

    NSMutableArray<CNBUnspentTransactionOutput *> *mutableOutputsFromAll = [allUnspentTransactionOutputs mutableCopy];
    NSMutableArray<CNBUnspentTransactionOutput *> *outputsToUse = [@[] mutableCopy];

    NSInteger totalFromUTXOs = 0;
    NSUInteger numberOfInputsAndOutputs = 1;  // assume one output to address

    do {
      // early exit if insufficient funds
      if (mutableOutputsFromAll.count == 0) {
        return nil;
      }

      // get a utxo
      CNBUnspentTransactionOutput *output = [mutableOutputsFromAll objectAtIndex:0];
      [mutableOutputsFromAll removeObjectAtIndex:0];
      [outputsToUse addObject:output];
      numberOfInputsAndOutputs += 1;

      totalFromUTXOs += output.amount;

      NSInteger possibleChange = totalFromUTXOs - (NSInteger)amount - (NSInteger)_feeAmount;
      NSInteger tempChangeAmount = MAX(0, possibleChange);
      _changeAmount = (NSUInteger)tempChangeAmount;

      if (totalFromUTXOs >= amount && tempChangeAmount > 0 && _changePath == nil) {
        _changePath = changePath;
        _changeAmount = MAX(0, (totalFromUTXOs - (NSInteger)amount - (NSInteger)_feeAmount));
        numberOfInputsAndOutputs += 1;

        NSUInteger feePerInput = numberOfInputsAndOutputs / flatFee;
        if ([self isEquitableToAddChangeForChangeAmount:_changeAmount feePerInput:feePerInput]) {
          _changePath = nil;
          _changeAmount = 0;
          numberOfInputsAndOutputs -= 1;
        }
      }

    } while (totalFromUTXOs < (_feeAmount + _amount));

    _unspentTransactionOutputs = [outputsToUse copy];
  }

  return self;
}

- (nullable instancetype)initWithAllUsableOutputs:(nonnull NSArray<CNBUnspentTransactionOutput *> *)unspentTransactionOutputs
                              sendingMaxToAddress:(nonnull NSString *)paymentAddress
                                          feeRate:(NSUInteger)feeRate
                                      blockHeight:(NSUInteger)blockHeight {
  if (self = [super init]) {
    _paymentAddress = paymentAddress;
    _unspentTransactionOutputs = unspentTransactionOutputs;
    _feeAmount = 0;
    _locktime = blockHeight;
    _changeAmount = 0;
    _changePath = nil;

    NSUInteger __block totalFromUTXOs = 0;
    [unspentTransactionOutputs enumerateObjectsUsingBlock:^(CNBUnspentTransactionOutput *obj, NSUInteger idx, BOOL *stop) {
      totalFromUTXOs += obj.amount;
    }];

    NSUInteger numberOfInputsAndOutputs = unspentTransactionOutputs.count + 1;  // + 1 for the destination output
    _feeAmount = feeRate * numberOfInputsAndOutputs * [self bytesPerInputOrOutput];

    NSInteger signedAmountForValidation = (NSInteger)totalFromUTXOs - (NSInteger)_feeAmount;
    if (signedAmountForValidation < 0) {
      return nil;
    } else {
      _amount = totalFromUTXOs - _feeAmount;
    }
  }

  return self;
}

- (NSUInteger)bytesPerInputOrOutput {
  return 100;
}

- (NSUInteger)dustValue {
  return 1000;
}

- (BOOL)isEquitableToAddChangeForChangeAmount:(NSUInteger)changeAmount feePerInput:(NSUInteger)feePerInput {
  return changeAmount < (feePerInput + [self dustValue]);
}

- (BOOL)shouldAddChangeToTransaction {
  return _changeAmount > 0 && _changePath != nil;
}

@end
