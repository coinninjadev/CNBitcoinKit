//
//  CNBUnspentTransactionOutput+Project.h
//  CNBitcoinKit
//
//  Created by BJ Miller on 8/8/19.
//  Copyright © 2019 Coin Ninja, LLC. All rights reserved.
//

#ifndef CNBUnspentTransactionOutput_Project_h
#define CNBUnspentTransactionOutput_Project_h

#ifdef __cplusplus
#include <bitcoin/bitcoin/coinninja/transaction/unspent_transaction_output.hpp>
#endif

@class CNBUnspentTransactionOutput;

NS_ASSUME_NONNULL_BEGIN

@interface CNBUnspentTransactionOutput (Project)

+ (CNBUnspentTransactionOutput *)utxoFromC_utxo:(coinninja::transaction::unspent_transaction_output)output;
- (coinninja::transaction::unspent_transaction_output)c_utxo;

@end

NS_ASSUME_NONNULL_END

#endif /* CNBUnspentTransactionOutput_Project_h */
