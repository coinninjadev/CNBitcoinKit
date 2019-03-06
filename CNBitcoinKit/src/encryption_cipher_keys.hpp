//
//  encryption_cipher_keys.hpp
//  CNBitcoinKit
//
//  Created by BJ Miller on 1/18/19.
//  Copyright © 2019 Coin Ninja, LLC. All rights reserved.
//

#ifndef encryption_cipher_keys_hpp
#define encryption_cipher_keys_hpp

#ifdef __cplusplus
  #include <bitcoin/bitcoin.hpp>
#endif
#include "cipher_keys.hpp"

class encryption_cipher_keys: public cipher_keys {
public:
  encryption_cipher_keys(
                         bc::hash_digest encryption_key,
                         bc::hash_digest hmac_key,
                         bc::data_chunk ephemeral_public_key
                         );

  bc::data_chunk get_ephemeral_public_key();

private:
  bc::data_chunk ephemeral_public_key;
};

#endif /* encryption_cipher_keys_hpp */
