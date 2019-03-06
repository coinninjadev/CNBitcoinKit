//
//  encryption_cipher_keys.cpp
//  CNBitcoinKit
//
//  Created by BJ Miller on 1/18/19.
//  Copyright © 2019 Coin Ninja, LLC. All rights reserved.
//

#include "encryption_cipher_keys.hpp"

encryption_cipher_keys::encryption_cipher_keys(
                                               bc::hash_digest encryption_key,
                                               bc::hash_digest hmac_key,
                                               bc::data_chunk ephemeral_public_key
                                               )
: cipher_keys(encryption_key, hmac_key)
{
  this->encryption_key = encryption_key;
  this->hmac_key = hmac_key;
  this->ephemeral_public_key = ephemeral_public_key;
}

bc::data_chunk encryption_cipher_keys::get_ephemeral_public_key() {
  return ephemeral_public_key;
}
