//
//  Base58Check.cpp
//  CNBitcoinKit
//
//  Created by BJ Miller on 9/18/18.
//  Copyright © 2018 Coin Ninja, LLC. All rights reserved.
//

#include "Base58Check.hpp"

using namespace bc;

bool Base58Check::addressIsBase58CheckEncoded(std::string address) {
  data_chunk chunk;
  decode_base58(chunk, address);

  static const int checksum_size { 4 };

  if (chunk.size() < checksum_size) {
    return false;
  }

  data_chunk checksum_chunk(checksum_size);
  std::copy(chunk.end() - checksum_size, chunk.end(), checksum_chunk.begin());
  std::string last_four = encode_base16(checksum_chunk);

  data_chunk chunk_to_hash(chunk.size() - checksum_size);
  std::copy(chunk.begin(), chunk.end() - checksum_size, chunk_to_hash.begin());
  hash_digest double_hashed_address = sha256_hash(sha256_hash(chunk_to_hash));

  data_chunk first_four_from_hash(checksum_size);
  std::copy(double_hashed_address.begin(), double_hashed_address.begin() + checksum_size, first_four_from_hash.begin());
  std::string first_four = encode_base16(first_four_from_hash);

  bool valid = (first_four == last_four);
  return valid;
}
