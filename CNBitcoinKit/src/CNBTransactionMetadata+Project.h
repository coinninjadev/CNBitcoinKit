//
//  CNBTransactionMetadata+Project.h
//  CNBitcoinKit
//
//  Created by BJ Miller on 8/9/19.
//  Copyright © 2019 Coin Ninja, LLC. All rights reserved.
//

#ifndef CNBTransactionMetadata_Project_h
#define CNBTransactionMetadata_Project_h

#ifdef __cplusplus
#include <bitcoin/bitcoin/coinninja/transaction/transaction_metadata.hpp>
#endif

@class CNBTransactionMetadata;

NS_ASSUME_NONNULL_BEGIN

@interface CNBTransactionMetadata (Project)

+ (CNBTransactionMetadata *)metadataFromC_metadata:(coinninja::transaction::transaction_metadata)c_metadata;
- (coinninja::transaction::transaction_metadata)c_metadata;

@end

NS_ASSUME_NONNULL_END

#endif /* CNBTransactionMetadata_Project_h */
