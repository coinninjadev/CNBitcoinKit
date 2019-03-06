//
//  NSData+CNBitcoinKit.h
//  CNBitcoinKit
//
//  Created by Dan Sexton on 5/1/18.
//  Copyright © 2018 Coin Ninja, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#ifdef __cplusplus
    #include <bitcoin/bitcoin.hpp>
#endif

@interface NSData (CNBitcoinKit)

- (bc::data_chunk)dataChunk;
- (bc::hash_digest)hashDigest;
- (NSString *)hexString;

@end
