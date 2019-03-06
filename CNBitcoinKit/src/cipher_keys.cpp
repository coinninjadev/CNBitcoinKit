//
//  cipher_keys.cpp
//  CNBitcoinKit
//
//  Created by BJ Miller on 1/22/19.
//  Copyright © 2019 Coin Ninja, LLC. All rights reserved.
//

#include "cipher_keys.hpp"

cipher_keys::cipher_keys(
                         bc::hash_digest encryption_key,
                         bc::hash_digest hmac_key
                         ) {
  this->encryption_key = encryption_key;
  this->hmac_key = hmac_key;
}

bc::hash_digest cipher_keys::get_encryption_key() {
  return encryption_key;
}

bc::hash_digest cipher_keys::get_hmac_key() {
  return hmac_key;
}
