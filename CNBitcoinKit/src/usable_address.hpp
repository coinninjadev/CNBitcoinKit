//
//  usable_address.hpp
//  CNBitcoinKit
//
//  Created by Dan Sexton on 5/17/18.
//  Copyright © 2018 Coin Ninja, LLC. All rights reserved.
//

#ifndef usable_address_hpp
#define usable_address_hpp

//#include "derivation_path.hpp"
#include <bitcoin/bitcoin/coinninja/wallet/derivation_path.hpp>
using namespace coinninja::wallet;

class usable_address {
public:
    usable_address(bc::wallet::hd_private privateKey, derivation_path path);
    
    void createPayToScriptOutputFrom(bc::chain::transaction &tx, bc::wallet::payment_address address, uint64_t amount);
    void createPayToKeyOutputFrom(bc::chain::transaction &tx, bc::wallet::payment_address address, uint64_t amount);
    bc::machine::operation::list witnessProgram(bc::ec_compressed publicKey);
    bc::wallet::hd_private childPrivateKey(bc::wallet::hd_private privateKey, int index);
    bc::wallet::hd_private indexPrivateKeyForHardenedDerivationPath(bc::wallet::hd_private privateKey, derivation_path path);
    bc::ec_compressed compressedPublicKeyForHardenedDerivationPath(bc::wallet::hd_private privateKey, derivation_path path);
    bc::chain::script P2WPKHForHardenedDerivationPath(bc::wallet::hd_private privateKey, derivation_path path);
    bc::wallet::payment_address paymentAddressForHardenedDerivationPath(bc::wallet::hd_private privateKey, derivation_path path);
    bc::wallet::payment_address buildPaymentAddress();
    bc::ec_compressed buildCompressedPublicKey();
    bc::chain::script buildP2WPKH();
    bc::wallet::hd_private buildPrivateKey();
    
private:
    bc::wallet::hd_private privateKey;
    derivation_path path = 0;
    bool testnet = false;
};

#endif /* usable_address_hpp */
