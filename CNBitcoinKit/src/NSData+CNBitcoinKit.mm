//
//  NSData+CNBitcoinKit.mm
//  CNBitcoinKit
//
//  Created by Dan Sexton on 5/1/18.
//  Copyright © 2018 Coin Ninja, LLC. All rights reserved.
//

#import "NSData+CNBitcoinKit.h"

@implementation NSData (CNBitcoinKit)

- (bc::data_chunk)dataChunk {
    const uint8_t *bytes = (const uint8_t*)self.bytes;
    bc::data_chunk chunk;
    bc::data_sink ostream(chunk);
    bc::ostream_writer sink(ostream);
    sink.write_bytes(bytes, (size_t)self.length);
    ostream.flush();
    return chunk;
}

- (bc::hash_digest)hashDigest {
    bc::data_chunk chunk = [self dataChunk];
    return bc::bitcoin_hash(chunk);
}

- (NSString *)hexString {
    const unsigned char *dataBuffer = (const unsigned char *)self.bytes;
    if (!dataBuffer) return nil;
    
    NSUInteger          dataLength  = self.length;
    NSMutableString     *hexString  = [NSMutableString stringWithCapacity:(dataLength * 2)];
    
    for (int i = 0; i < dataLength; ++i)
        [hexString appendString:[NSString stringWithFormat:@"%02lx", (unsigned long)dataBuffer[i]]];
    
    return [NSString stringWithString:hexString];
}

@end
