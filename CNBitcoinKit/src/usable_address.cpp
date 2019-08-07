//
//  usable_address.cpp
//  CNBitcoinKit
//
//  Created by Dan Sexton on 5/17/18.
//  Copyright © 2018 Coin Ninja, LLC. All rights reserved.
//

#include "usable_address.hpp"

//This is the initalizer for the usable_address class
usable_address::usable_address(bc::wallet::hd_private privateKey, derivation_path path) {
    this->privateKey = privateKey;
    this->path = path;
    if (path.get_coin() == 1) {
        testnet = true;
    }
}

void usable_address::createPayToScriptOutputFrom(bc::chain::transaction &tx, bc::wallet::payment_address address, uint64_t amount) {
    tx.outputs().push_back(
                           bc::chain::output(amount, bc::chain::script(bc::chain::script().to_pay_script_hash_pattern(address.hash()))));
}

void usable_address::createPayToKeyOutputFrom(bc::chain::transaction &tx, bc::wallet::payment_address address, uint64_t amount) {
    tx.outputs().push_back(
                           bc::chain::output(amount, bc::chain::script(bc::chain::script().to_pay_key_hash_pattern(address.hash()))));
}

bc::machine::operation::list usable_address::witnessProgram(bc::ec_compressed publicKey) {
    bc::short_hash KeyHash = bc::bitcoin_short_hash(publicKey);
    return {bc::machine::operation(bc::machine::opcode(0)), bc::machine::operation(bc::to_chunk(KeyHash))};
}

bc::wallet::hd_private usable_address::childPrivateKey(bc::wallet::hd_private privateKey, int index) {
    return privateKey.derive_private(index);
}

bc::wallet::hd_private usable_address::indexPrivateKeyForHardenedDerivationPath(bc::wallet::hd_private privateKey, derivation_path path) {
    
    bc::wallet::hd_private purposePrivateKey = childPrivateKey(privateKey, path.get_hardened_purpose());
    bc::wallet::hd_private coinPrivateKey = childPrivateKey(purposePrivateKey, path.get_hardened_coin());
    bc::wallet::hd_private accountPrivateKey = childPrivateKey(coinPrivateKey,
                                                               path.get_hardened_account());
    bc::wallet::hd_private changePrivateKey = childPrivateKey(accountPrivateKey, path.get_change());
    return childPrivateKey(changePrivateKey, path.get_index());
}

bc::ec_compressed usable_address::compressedPublicKeyForHardenedDerivationPath(bc::wallet::hd_private privateKey, derivation_path path) {
    bc::wallet::hd_private indexPrivateKey = indexPrivateKeyForHardenedDerivationPath(privateKey, path);
    bc::wallet::hd_public indexPublicKey = indexPrivateKey.to_public();
    return indexPublicKey.point();
}

bc::chain::script usable_address::P2WPKHForHardenedDerivationPath(bc::wallet::hd_private privateKey, derivation_path path) {
    return bc::chain::script(witnessProgram((compressedPublicKeyForHardenedDerivationPath(privateKey, path))));
}

bc::wallet::payment_address usable_address::paymentAddressForHardenedDerivationPath(bc::wallet::hd_private privateKey, derivation_path path) {
    bc::ec_compressed compressedPublicKey = compressedPublicKeyForHardenedDerivationPath(privateKey,
                                                                                         path);
    
    uint8_t format = bc::wallet::payment_address::mainnet_p2sh;
    if (path.get_coin() == 1) {
        format = bc::wallet::payment_address::testnet_p2sh;
    }
    
    bc::chain::script P2WPKH = bc::chain::script(witnessProgram(compressedPublicKey));
    return bc::wallet::payment_address(P2WPKH, format);
}

bc::wallet::payment_address usable_address::buildPaymentAddress() {
    return paymentAddressForHardenedDerivationPath(privateKey, path);
}

bc::ec_compressed usable_address::buildCompressedPublicKey() {
    return compressedPublicKeyForHardenedDerivationPath(privateKey, path);
}

bc::chain::script usable_address::buildP2WPKH() {
    return P2WPKHForHardenedDerivationPath(privateKey, path);
}

bc::wallet::hd_private usable_address::buildPrivateKey() {
    return indexPrivateKeyForHardenedDerivationPath(privateKey, path);
}
