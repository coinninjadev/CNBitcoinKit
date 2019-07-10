//
//  CNBTransactionData.m
//  CNBitcoinKit
//
//  Created by Mitchell on 5/14/18.
//  Copyright © 2018 Coin Ninja, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CNBTransactionData.h"
#import "CNBAddressHelper.h"
#import "CNBAddressHelper+Project.h"
#import "CNBBaseCoin.h"

@interface CNBTransactionData()
@property (nonatomic, retain) CNBBaseCoin *coin;
@end

@implementation CNBTransactionData

- (nonnull instancetype)initWithAddress:(nonnull NSString *)paymentAddress
                                   coin:(nonnull CNBBaseCoin *)coin
              unspentTransactionOutputs:(nonnull NSArray *)unspentTransactionOutputs
                                 amount:(NSUInteger)amount
                              feeAmount:(NSUInteger)feeAmount
                           changeAmount:(NSUInteger)changeAmount
                             changePath:(nullable CNBDerivationPath *)changePath
                            blockHeight:(NSUInteger)blockHeight {
  if (self = [super init]) {
    _paymentAddress = paymentAddress;
    _coin = coin;
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
                                    coin:(nonnull CNBBaseCoin *)coin
                 fromAllAvailableOutputs:(NSArray<CNBUnspentTransactionOutput *> *)allUnspentTransactionOutputs
                           paymentAmount:(NSUInteger)amount
                                 feeRate:(NSUInteger)feeRate
                              changePath:(nullable CNBDerivationPath *)changePath
                             blockHeight:(NSUInteger)blockHeight {
  if (self = [super init]) {
    _paymentAddress = paymentAddress;
    _coin = coin;
    _amount = amount;
    _unspentTransactionOutputs = @[];
    _feeAmount = 0;
    _locktime = blockHeight;

    CNBAddressHelper *helper = [[CNBAddressHelper alloc] initWithCoin:_coin];

    NSMutableArray<CNBUnspentTransactionOutput *> *requiredInputs = [@[] mutableCopy];
    NSInteger totalFromUTXOs = 0;
    NSUInteger numberOfInputs = 0;
    NSInteger totalSendingValue = 0;
    NSInteger currentFee = 0;
    NSInteger feePerInput = feeRate * [helper bytesPerInput];

    for (CNBUnspentTransactionOutput *output in allUnspentTransactionOutputs) {
      totalSendingValue = amount + currentFee;

      if (totalSendingValue > totalFromUTXOs) {
        [requiredInputs addObject:output];
        numberOfInputs += 1;
        totalFromUTXOs += [output amount];
        BOOL includeChangeOutput = (_changePath != nil);
        NSUInteger totalBytes = [self bytesForInputCount:numberOfInputs paymentAddress:paymentAddress includeChangeOutput:includeChangeOutput];
        currentFee = feeRate * totalBytes;
        totalSendingValue = amount + currentFee;

        NSInteger changeValue = totalFromUTXOs - totalSendingValue;

        if ((totalFromUTXOs < amount + currentFee) || changeValue < 0) {
          continue;
        }

        if (changeValue > 0 && changeValue < (feePerInput + [self dustThreshold])) {  // not beneficial to add change
          currentFee += changeValue;
          break;
        } else if (changeValue > 0) {
          totalBytes = [self bytesForInputCount:numberOfInputs paymentAddress:paymentAddress includeChangeOutput:YES];
          currentFee = feeRate * totalBytes;
          changeValue -= (feeRate * [helper bytesPerChangeOutput]);
          _changeAmount = changeValue;
          _changePath = changePath;
          break;
        }
      } else {
        break;
      }
    }

    _feeAmount = currentFee;
    _unspentTransactionOutputs = [requiredInputs copy];

    if (totalFromUTXOs < totalSendingValue) {
      return nil;
    }
  }
  return self;
}

- (instancetype)initWithAddress:(NSString *)paymentAddress
                           coin:(nonnull CNBBaseCoin *)coin
        fromAllAvailableOutputs:(NSArray<CNBUnspentTransactionOutput *> *)allUnspentTransactionOutputs
                  paymentAmount:(NSUInteger)amount
                        flatFee:(NSUInteger)flatFee
                     changePath:(CNBDerivationPath *)changePath
                    blockHeight:(NSUInteger)blockHeight {
  if (self = [super init]) {
    _paymentAddress = paymentAddress;
    _coin = coin;
    _amount = amount;
    _unspentTransactionOutputs = @[];
    _feeAmount = flatFee;
    _locktime = blockHeight;

    NSMutableArray<CNBUnspentTransactionOutput *> *mutableOutputsFromAll = [allUnspentTransactionOutputs mutableCopy];
    NSMutableArray<CNBUnspentTransactionOutput *> *outputsToUse = [@[] mutableCopy];

    NSInteger totalFromUTXOs = 0;

    do {
      // early exit if insufficient funds
      if (mutableOutputsFromAll.count == 0) {
        return nil;
      }

      // get a utxo
      CNBUnspentTransactionOutput *output = [mutableOutputsFromAll objectAtIndex:0];
      [mutableOutputsFromAll removeObjectAtIndex:0];
      [outputsToUse addObject:output];

      totalFromUTXOs += output.amount;

      NSInteger possibleChange = totalFromUTXOs - (NSInteger)amount - (NSInteger)_feeAmount;
      NSInteger tempChangeAmount = MAX(0, possibleChange);
      _changeAmount = (NSUInteger)tempChangeAmount;

      if (totalFromUTXOs >= amount && tempChangeAmount > 0 && _changePath == nil) {
        _changePath = changePath;
        _changeAmount = MAX(0, (totalFromUTXOs - (NSInteger)amount - (NSInteger)_feeAmount));

        if (_changeAmount < [self dustThreshold]) {
          _changePath = nil;
          _changeAmount = 0;
        }
      }

    } while (totalFromUTXOs < (_feeAmount + _amount));

    _unspentTransactionOutputs = [outputsToUse copy];
  }

  return self;
}

- (nullable instancetype)initWithAllUsableOutputs:(nonnull NSArray<CNBUnspentTransactionOutput *> *)unspentTransactionOutputs
                                             coin:(nonnull CNBBaseCoin *)coin
                              sendingMaxToAddress:(nonnull NSString *)paymentAddress
                                          feeRate:(NSUInteger)feeRate
                                      blockHeight:(NSUInteger)blockHeight {
  if (self = [super init]) {
    _paymentAddress = paymentAddress;
    _coin = coin;
    _unspentTransactionOutputs = unspentTransactionOutputs;
    _feeAmount = 0;
    _locktime = blockHeight;
    _changeAmount = 0;
    _changePath = nil;

    CNBAddressHelper *helper = [[CNBAddressHelper alloc] initWithCoin:_coin];

    NSUInteger __block totalFromUTXOs = 0;
    [unspentTransactionOutputs enumerateObjectsUsingBlock:^(CNBUnspentTransactionOutput *obj, NSUInteger idx, BOOL *stop) {
      totalFromUTXOs += obj.amount;
    }];

    bc::wallet::payment_address payment_address = [helper paymentAddressFromString:paymentAddress];
    _feeAmount = feeRate * [helper totalBytesWithInputCount:[unspentTransactionOutputs count]
                                             paymentAddress:payment_address
                                       includeChangeAddress:NO];

    NSInteger signedAmountForValidation = (NSInteger)totalFromUTXOs - (NSInteger)_feeAmount;
    if (signedAmountForValidation < 0) {
      return nil;
    } else {
      _amount = totalFromUTXOs - _feeAmount;
    }
  }

  return self;
}

- (NSUInteger)bytesForInputCount:(NSUInteger)inputCount paymentAddress:(NSString *)address includeChangeOutput:(BOOL)includeChange {
  CNBAddressHelper *helper = [[CNBAddressHelper alloc] initWithCoin:self.coin];
  bc::wallet::payment_address payment_address = [helper paymentAddressFromString:address];
  return [helper totalBytesWithInputCount:inputCount paymentAddress:payment_address includeChangeAddress:includeChange];
}

- (NSUInteger)dustThreshold {
  return 1000;
}

- (BOOL)shouldAddChangeToTransaction {
  return _changeAmount > 0 && _changePath != nil;
}

@end
