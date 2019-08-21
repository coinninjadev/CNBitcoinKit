//
//  CNBDerivationPath+Project.h
//  CNBitcoinKit
//
//  Created by BJ Miller on 8/8/19.
//  Copyright © 2019 Coin Ninja, LLC. All rights reserved.
//

#ifndef CNBDerivationPath_Project_h
#define CNBDerivationPath_Project_h

#ifdef __cplusplus
#include <bitcoin/bitcoin/coinninja/wallet/derivation_path.hpp>
#endif

@class CNBDerivationPath;

NS_ASSUME_NONNULL_BEGIN

@interface CNBDerivationPath (Project)

+ (CNBDerivationPath *)pathFromC_path:(coinninja::wallet::derivation_path)c_path;
- (coinninja::wallet::derivation_path)c_path;

@end

NS_ASSUME_NONNULL_END

#endif /* CNBDerivationPath_Project_h */
