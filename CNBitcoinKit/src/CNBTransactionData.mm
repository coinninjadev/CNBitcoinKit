//
//  CNBTransactionData.m
//  CNBitcoinKit
//
//  Created by Mitchell on 5/14/18.
//  Copyright © 2018 Coin Ninja, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CNBTransactionData.h"
#import "CNBTransactionData+Project.h"
#import "CNBAddressHelper.h"
#import "CNBAddressHelper+Project.h"
#import "CNBBaseCoin.h"
#import "CNBBaseCoin+Project.h"
#import "CNBUnspentTransactionOutput+Project.h"
#import "CNBDerivationPath+Project.h"

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

    derivation_path c_change_path{49,0,0,1,0};
    if (changePath != nil) {
      c_change_path = [changePath c_path];
    }

    coinninja::transaction::transaction_data tx_data;
    bool success = transaction_data::create_transaction_data(tx_data,
                                                             address,
                                                             c_coin,
                                                             all_utxos,
                                                             static_cast<uint64_t>(amount),
                                                             static_cast<uint16_t>(feeRate),
                                                             c_change_path,
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
    if (tx_data.should_add_change_to_transaction()) {
      _changePath = changePath;
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

    derivation_path c_change_path{49,0,0,1,0};
    if (changePath != nil) {
      c_change_path = [changePath c_path];
    }

    transaction_data tx_data;
    bool success = transaction_data::create_flat_fee_transaction_data(tx_data,
                                                                      address,
                                                                      c_coin,
                                                                      all_utxos,
                                                                      static_cast<uint64_t>(amount),
                                                                      static_cast<uint64_t>(flatFee),
                                                                      c_change_path,
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
    if (tx_data.should_add_change_to_transaction()) {
      _changePath = changePath;
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

//MARK: translation methods
+ (CNBTransactionData *)dataFromC_data:(coinninja::transaction::transaction_data)c_data {
  CNBBaseCoin *coin = [CNBBaseCoin coinFromC_Coin:c_data.get_coin()];
  BOOL shouldBeRBF = c_data.get_should_be_rbf();
  NSString *paymentAddress = [NSString stringWithCString:c_data.payment_address.c_str() encoding:[NSString defaultCStringEncoding]];

  NSMutableArray *mutableUTXOs = [[NSMutableArray alloc] initWithCapacity:c_data.unspent_transaction_outputs.size()];
  for (size_t i{0}; i < c_data.unspent_transaction_outputs.size(); i++) {
    auto c_utxo = c_data.unspent_transaction_outputs.at(i);
    mutableUTXOs[i] = [CNBUnspentTransactionOutput utxoFromC_utxo:c_utxo];
  }

  NSUInteger amount = (NSUInteger)c_data.amount;
  NSUInteger feeAmount = (NSUInteger)c_data.fee_amount;
  NSUInteger changeAmount = (NSUInteger)c_data.change_amount;
  CNBDerivationPath *changePath = [CNBDerivationPath pathFromC_path:c_data.change_path];

  NSUInteger locktime = (NSUInteger)c_data.locktime;

  CNBTransactionData *retval = [[CNBTransactionData alloc] init];
  [retval setCoin:coin];
  [retval setShouldBeRBF:shouldBeRBF];
  [retval setPaymentAddress:paymentAddress];
  [retval setUnspentTransactionOutputs:[mutableUTXOs copy]];
  [retval setAmount:amount];
  [retval setFeeAmount:feeAmount];
  [retval setChangeAmount:changeAmount];
  [retval setChangePath:changePath];
  [retval setLocktime:locktime];
  return retval;
}

- (coinninja::transaction::transaction_data)c_data {
  coinninja::wallet::base_coin c_coin{[[self coin] c_coin]};
  bool c_should_be_rbf{[self shouldBeRBF]};
  std::string c_payment_address{[[self paymentAddress] cStringUsingEncoding:[NSString defaultCStringEncoding]]};
  uint64_t c_amount{[self amount]};
  uint64_t c_fee_amount{[self feeAmount]};
  uint64_t c_change_amount{[self changeAmount]};
  uint64_t c_locktime{[self locktime]};

  std::vector<coinninja::transaction::unspent_transaction_output>c_utxos;
  c_utxos.reserve([[self unspentTransactionOutputs] count]);
  for (CNBUnspentTransactionOutput *utxo in [self unspentTransactionOutputs]) {
    coinninja::transaction::unspent_transaction_output c_utxo{[utxo c_utxo]};
    c_utxos.push_back(c_utxo);
  }

  coinninja::wallet::derivation_path c_change_path{
    static_cast<uint32_t>([[self changePath] purpose]),
    static_cast<uint32_t>([[self changePath] coinType]),
    static_cast<uint32_t>([[self changePath] account]),
    static_cast<uint32_t>([[self changePath] change]),
    static_cast<uint32_t>([[self changePath] index])
  };

  coinninja::transaction::transaction_data c_data{
    c_payment_address,
    c_coin, c_utxos,
    c_amount,
    c_fee_amount,
    c_change_amount,
    c_change_path,
    c_locktime,
    c_should_be_rbf
  };

  return c_data;
}
@end
