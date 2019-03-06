//
//  cipher_key_vendor.cpp
//  CNBitcoinKit
//
//  Created by BJ Miller on 1/24/19.
//  Copyright © 2019 Coin Ninja, LLC. All rights reserved.
//

#include "cipher_key_vendor.hpp"

// MARK: Public functions
cipher_keys cipher_key_vendor::decryption_cipher_keys(hd_private private_key, data_chunk public_key_data) {
  ec_secret secret_key(private_key.secret());
  cipher_keys keys = cipher_key_vendor::cipher_keys_with_secret_key_and_public_key(secret_key, public_key_data);
  return keys;
}

encryption_cipher_keys cipher_key_vendor::encryption_cipher_keys_for_uncompressed_public_key(data_chunk public_key_data) {
  // generate ephemeral key
  data_chunk entropy(ec_secret_size);
  pseudo_random_fill(entropy);
  auto secret = to_array<ec_secret_size>(entropy);
  ec_secret secret_key(secret);

  cipher_keys keys = cipher_key_vendor::cipher_keys_with_secret_key_and_public_key(secret_key, public_key_data);

  // get uncompressed public key from ephemeral secret
  ec_uncompressed ephemeral_public_key;
  ec_public(secret_key).to_uncompressed(ephemeral_public_key);
  data_chunk eph_pubkey_output(sizeof(ephemeral_public_key));
  std::copy(ephemeral_public_key.begin(), ephemeral_public_key.end(), eph_pubkey_output.begin());

  encryption_cipher_keys encryption_keys(keys.get_encryption_key(), keys.get_hmac_key(), eph_pubkey_output);
  return encryption_keys;
}

// MARK: Private functions
cipher_keys cipher_key_vendor::cipher_keys_with_secret_key_and_public_key(ec_secret secret_key, data_chunk public_key_data) {
  // get uncompressed public key
  ec_uncompressed recipient_uncompressed_pubkey = cipher_key_vendor::uncompressed_public_key(public_key_data);

  // generate ecdh_key
  data_chunk ecdh_key = cipher_key_vendor::generate_shared_secret(secret_key, recipient_uncompressed_pubkey);

  // derive key from ecdh_key
  data_slice slice(ecdh_key);
  long_hash derived_key = sha512_hash(slice);

  // get keyE and keyM
  hash_digest keyE;  // sizeof = 256 bits
  hash_digest keyM;

  std::copy(derived_key.begin(), derived_key.begin() + hash_size, keyE.begin());
  std::copy(derived_key.begin() + hash_size, derived_key.end(), keyM.begin());

  cipher_keys keys(keyE, keyM);
  return keys;
}

data_chunk cipher_key_vendor::generate_shared_secret(ec_secret secret_key, ec_uncompressed uncompressed_public_key) {
  ec_multiply(uncompressed_public_key, secret_key);
  return to_chunk(uncompressed_public_key);
}

ec_uncompressed cipher_key_vendor::uncompressed_public_key(data_chunk public_key_data) {
  ec_public ec_public_key(public_key_data);
  ec_uncompressed recipient_uncompressed_pubkey;
  ec_public_key.to_uncompressed(recipient_uncompressed_pubkey);
  return recipient_uncompressed_pubkey;
}
