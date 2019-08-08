//
//  CNBUnspentTransactionOutput.m
//  CNBitcoinKit
//
//  Created by Mitchell on 5/14/18.
//  Copyright © 2018 Coin Ninja, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CNBUnspentTransactionOutput.h"
#import "CNBUnspentTransactionOutput+Project.h"
#import "CNBDerivationPath+Project.h"

@implementation CNBUnspentTransactionOutput

-(instancetype)initWithId:(NSString *)txId
                    index:(NSUInteger)index
                   amount:(NSUInteger)amount
           derivationPath:(CNBDerivationPath *)path
              isConfirmed:(BOOL)confirmed{
  if(self = [super init]) {
    self.txId = txId;
    self.index = index;
    self.amount = amount;
    self.path = path;
    self.isConfirmed = confirmed;
  }

  return self;
}

+ (CNBUnspentTransactionOutput *)utxoFromC_utxo:(coinninja::transaction::unspent_transaction_output)output {
  CNBUnspentTransactionOutput *utxo = [[CNBUnspentTransactionOutput alloc] init];
  utxo.txId = [NSString stringWithCString:output.txid.c_str() encoding:[NSString defaultCStringEncoding]];
  utxo.index = output.index;
  utxo.amount = output.amount;
  utxo.path = [CNBDerivationPath pathFromC_path:output.path];
  utxo.isConfirmed = output.is_confirmed;
  return utxo;
}

- (coinninja::transaction::unspent_transaction_output)c_utxo {
  std::string c_txid = [[self txId] cStringUsingEncoding:[NSString defaultCStringEncoding]];
  coinninja::transaction::unspent_transaction_output utxo{
    c_txid,
    static_cast<uint8_t>([self index]),
    static_cast<uint64_t>([self amount]),
    [[self path] c_path],
    [self isConfirmed]
  };
  return utxo;
}
@end
