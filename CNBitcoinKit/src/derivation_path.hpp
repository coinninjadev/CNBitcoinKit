//
//  derivation_path.hpp
//  CNBitcoinKit
//
//  Created by Dan Sexton on 5/17/18.
//  Copyright © 2018 Coin Ninja, LLC. All rights reserved.
//

#ifndef derivation_path_hpp
#define derivation_path_hpp

#ifdef __cplusplus
  #include <bitcoin/bitcoin.hpp>
#endif

class derivation_path {
public:
    derivation_path(int purpose);
    derivation_path(int purpose, int coin, int account, int change, int index);
    
    bool hasPurpose();
    bool hasCoin();
    bool hasAccount();
    bool hasChange();
    bool hasindex();
    int getPurpose();
    int getCoin();
    int getAccount();
    int getChange();
    int getIndex();
    int getHardenedPurpose();
    int getHardenedCoin();
    int getHardenedAccount();
    
private:
    uint32_t hardenedOffset = bc::wallet::hd_first_hardened_key;
    int purpose = -1;
    int coin = -1;
    int account = -1;
    int change = -1;
    int index = -1;
};

#endif /* derivation_path_hpp */
