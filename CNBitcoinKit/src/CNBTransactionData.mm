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
#import "CNBBaseCoin+Project.h"
#import "CNBUnspentTransactionOutput+Project.h"
#import "CNBDerivationPath+Project.h"

#ifdef __cplusplus
#include <bitcoin/bitcoin/coinninja/transaction/transaction_data.hpp>
#endif

@interface CNBTransactionData()
@property (nonatomic, retain) CNBBaseCoin *coin;
@property (nonatomic, assign, readwrite) BOOL shouldBeRBF;
@end

using namespace coinninja::transaction;
using namespace coinninja::wallet;

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
    _shouldBeRBF = false;
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
    _shouldBeRBF = false;
    _changePath = nil;

    std::string address = [paymentAddress cStringUsingEncoding:[NSString defaultCStringEncoding]];
    coinninja::wallet::base_coin c_coin = [coin c_coin];
    auto all_utxo_size = [allUnspentTransactionOutputs count];
    std::vector<unspent_transaction_output> all_utxos;
    all_utxos.reserve(all_utxo_size);
    for (size_t i = 0; i < all_utxo_size; i++) {
      unspent_transaction_output utxo{[allUnspentTransactionOutputs[i] c_utxo]};
      all_utxos.push_back(utxo);
    }

    derivation_path *c_change_path_ptr{nullptr};
    derivation_path c_change_path{49,0,0,1,0};
    if (changePath != nil) {
      c_change_path = [changePath c_path];
      c_change_path_ptr = &c_change_path;
    }

    coinninja::transaction::transaction_data tx_data;
    bool success = transaction_data::create_transaction_data(tx_data,
                                                             address,
                                                             c_coin,
                                                             all_utxos,
                                                             static_cast<uint64_t>(amount),
                                                             static_cast<uint16_t>(feeRate),
                                                             c_change_path_ptr,
                                                             static_cast<uint64_t>(blockHeight));

    if (!success) {
      return nil;
    }

    // succeeded in creating transaction data
    // utxos
    auto utxo_count{tx_data.unspent_transaction_outputs.size()};
    NSMutableArray *selectedUTXOs = [[NSMutableArray alloc] initWithCapacity:utxo_count];
    for (size_t i = 0; i< utxo_count; i++) {
      unspent_transaction_output c_utxo{tx_data.unspent_transaction_outputs.at(i)};
      CNBUnspentTransactionOutput *newUTXO = [CNBUnspentTransactionOutput utxoFromC_utxo:c_utxo];
      selectedUTXOs[i] = newUTXO;
    }
    _unspentTransactionOutputs = [selectedUTXOs copy];

    // feeAmount
    _feeAmount = tx_data.fee_amount;

    // changeAmount
    _changeAmount = tx_data.change_amount;

    // changePath
    if (tx_data.change_path != nullptr) {
      _changePath = changePath;
      c_change_path_ptr = nullptr;
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
    _shouldBeRBF = true;
    _changePath = nil;

    std::string address = [paymentAddress cStringUsingEncoding:[NSString defaultCStringEncoding]];
    base_coin c_coin{[coin c_coin]};
    auto all_utxo_size{[allUnspentTransactionOutputs count]};
    std::vector<unspent_transaction_output> all_utxos;
    all_utxos.reserve(all_utxo_size);
    for (size_t i = 0; i < all_utxo_size; i++) {
      unspent_transaction_output utxo{[allUnspentTransactionOutputs[i] c_utxo]};
      all_utxos.push_back(utxo);
    }

    derivation_path *c_change_path_ptr{nullptr};
    derivation_path c_change_path{49,0,0,1,0};
    if (changePath != nil) {
      c_change_path = [changePath c_path];
      c_change_path_ptr = &c_change_path;
    }

    transaction_data tx_data;
    bool success = transaction_data::create_flat_fee_transaction_data(tx_data,
                                                                      address,
                                                                      c_coin,
                                                                      all_utxos,
                                                                      static_cast<uint64_t>(amount),
                                                                      static_cast<uint64_t>(flatFee),
                                                                      c_change_path_ptr,
                                                                      static_cast<uint64_t>(blockHeight));

    if (!success) {
      return nil;
    }

    // succeeded in creating transaction data
    // utxos
    auto utxo_count{tx_data.unspent_transaction_outputs.size()};
    NSMutableArray *selectedUTXOs = [[NSMutableArray alloc] initWithCapacity:utxo_count];
    for (size_t i = 0; i < utxo_count; i++) {
      unspent_transaction_output c_utxo{tx_data.unspent_transaction_outputs.at(i)};
      CNBUnspentTransactionOutput *newUTXO = [CNBUnspentTransactionOutput utxoFromC_utxo:c_utxo];
      selectedUTXOs[i] = newUTXO;
    }
    _unspentTransactionOutputs = [selectedUTXOs copy];

    // changeAmount
    _changeAmount = tx_data.change_amount;

    // changePath
    if (tx_data.change_path != nullptr) {
      _changePath = changePath;
      c_change_path_ptr = nullptr;
    }
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
    _shouldBeRBF = false;

    std::string address = [paymentAddress cStringUsingEncoding:[NSString defaultCStringEncoding]];
    base_coin c_coin{[coin c_coin]};
    auto all_utxo_size{[unspentTransactionOutputs count]};
    std::vector<unspent_transaction_output> all_utxos;
    all_utxos.reserve(all_utxo_size);
    for (size_t i = 0; i < all_utxo_size; i++) {
      unspent_transaction_output utxo{[unspentTransactionOutputs[i] c_utxo]};
      all_utxos.push_back(utxo);
    }

    transaction_data tx_data;
    bool success = transaction_data::create_send_max_transaction_data(tx_data,
                                                                      all_utxos,
                                                                      c_coin,
                                                                      address,
                                                                      static_cast<uint16_t>(feeRate),
                                                                      static_cast<uint64_t>(blockHeight));

    if (!success) {
      return nil;
    }

    // succeeded in creating transaction data
    // utxos
    auto utxo_count{tx_data.unspent_transaction_outputs.size()};
    NSMutableArray *selectedUTXOs = [[NSMutableArray alloc] initWithCapacity:utxo_count];
    for (size_t i = 0; i < utxo_count; i++) {
      unspent_transaction_output c_utxo{tx_data.unspent_transaction_outputs.at(i)};
      CNBUnspentTransactionOutput *newUTXO = [CNBUnspentTransactionOutput utxoFromC_utxo:c_utxo];
      selectedUTXOs[i] = newUTXO;
    }
    _unspentTransactionOutputs = [selectedUTXOs copy];

    // amount
    _amount = tx_data.amount;

    // feeAmount
    _feeAmount = tx_data.fee_amount;
  }

  return self;
}

- (BOOL)shouldAddChangeToTransaction {
  return _changeAmount > 0 && _changePath != nil;
}

@end
