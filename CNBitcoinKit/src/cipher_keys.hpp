//
//  cipher_keys.hpp
//  CNBitcoinKit
//
//  Created by BJ Miller on 1/22/19.
//  Copyright © 2019 Coin Ninja, LLC. All rights reserved.
//

#ifndef cipher_keys_hpp
#define cipher_keys_hpp

#ifdef __cplusplus
  #include <bitcoin/bitcoin.hpp>
#endif

class cipher_keys {
public:
  cipher_keys(
              bc::hash_digest encryption_key,
              bc::hash_digest hmac_key
              );

  bc::hash_digest get_encryption_key();
  bc::hash_digest get_hmac_key();

protected:
  bc::hash_digest encryption_key;
  bc::hash_digest hmac_key;

};

#endif /* decryption_cipher_keys_hpp */
