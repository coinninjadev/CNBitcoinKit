//
//  cipher_key_vendor.hpp
//  CNBitcoinKit
//
//  Created by BJ Miller on 1/24/19.
//  Copyright © 2019 Coin Ninja, LLC. All rights reserved.
//

#ifndef cipher_key_vendor_hpp
#define cipher_key_vendor_hpp

#ifdef __cplusplus
  #include <bitcoin/bitcoin.hpp>
#endif

#include "cipher_keys.hpp"
#include "encryption_cipher_keys.hpp"

using namespace bc;
using namespace wallet;

class cipher_key_vendor {
public:
  static cipher_keys decryption_cipher_keys(hd_private private_key, data_chunk public_key_data);
  static encryption_cipher_keys encryption_cipher_keys_for_uncompressed_public_key(data_chunk public_key_data, data_chunk entropy);

private:
  static cipher_keys cipher_keys_with_secret_key_and_public_key(ec_secret secret_key, data_chunk public_key_data);
  static data_chunk generate_shared_secret(ec_secret secret_key, ec_uncompressed uncompressed_public_key);
  static ec_uncompressed uncompressed_public_key(data_chunk public_key_data);

};

#endif /* cipher_key_vendor_hpp */
