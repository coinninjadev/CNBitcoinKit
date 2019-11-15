//
//  SegwitAddressTests.m
//  CNBitcoinKitTests
//
//  Created by BJ Miller on 7/9/19.
//  Copyright © 2019 Coin Ninja, LLC. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "CNBBech32Metadata.h"
#import "CNBWitnessMetadata.h"
#import "CNBBech32Address.h"
#import "CNBSegwitAddress.h"
#import "NSData+CNBitcoinKit.h"
#include <string>
#include <vector>

@interface SegwitAddressTests : XCTestCase

@end

@implementation SegwitAddressTests

static const std::string valid_checksum[] = {
  "A12UEL5L",
  "an83characterlonghumanreadablepartthatcontainsthenumber1andtheexcludedcharactersbio1tt5tgs",
  "abcdef1qpzry9x8gf2tvdw0s3jn54khce6mua7lmqqqxw",
  "11qqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqc8247j",
  "split1checkupstagehandshakeupstreamerranterredcaperred2y9e3w",
};

static const std::string invalid_checksum[] = {
  " 1nwldj5",
  "\x7f""1axkwrx",
  "an84characterslonghumanreadablepartthatcontainsthenumber1andtheexcludedcharactersbio1569pvx",
  "pzry9x0s0muk",
  "1pzry9x0s0muk",
  "x1b4n0q5v",
  "li1dgmt3",
  "de1lg7wt\xff",
};

struct valid_address_data {
  std::string address;
  size_t scriptPubKeyLen;
  uint8_t scriptPubKey[42];
};

struct invalid_address_data {
  std::string hrp;
  int version;
  size_t program_length;
};

static const struct valid_address_data valid_address[] = {
  {
    "BC1QW508D6QEJXTDG4Y5R3ZARVARY0C5XW7KV8F3T4",
    22, {
      0x00, 0x14, 0x75, 0x1e, 0x76, 0xe8, 0x19, 0x91, 0x96, 0xd4, 0x54,
      0x94, 0x1c, 0x45, 0xd1, 0xb3, 0xa3, 0x23, 0xf1, 0x43, 0x3b, 0xd6
    }
  },
  {
    "tb1qrp33g0q5c5txsp9arysrx4k6zdkfs4nce4xj0gdcccefvpysxf3q0sl5k7",
    34, {
      0x00, 0x20, 0x18, 0x63, 0x14, 0x3c, 0x14, 0xc5, 0x16, 0x68, 0x04,
      0xbd, 0x19, 0x20, 0x33, 0x56, 0xda, 0x13, 0x6c, 0x98, 0x56, 0x78,
      0xcd, 0x4d, 0x27, 0xa1, 0xb8, 0xc6, 0x32, 0x96, 0x04, 0x90, 0x32,
      0x62
    }
  },
  {
    "bc1pw508d6qejxtdg4y5r3zarvary0c5xw7kw508d6qejxtdg4y5r3zarvary0c5xw7k7grplx",
    42, {
      0x81, 0x28, 0x75, 0x1e, 0x76, 0xe8, 0x19, 0x91, 0x96, 0xd4, 0x54,
      0x94, 0x1c, 0x45, 0xd1, 0xb3, 0xa3, 0x23, 0xf1, 0x43, 0x3b, 0xd6,
      0x75, 0x1e, 0x76, 0xe8, 0x19, 0x91, 0x96, 0xd4, 0x54, 0x94, 0x1c,
      0x45, 0xd1, 0xb3, 0xa3, 0x23, 0xf1, 0x43, 0x3b, 0xd6
    }
  },
  {
    "BC1SW50QA3JX3S",
    4, {
      0x90, 0x02, 0x75, 0x1e
    }
  },
  {
    "bc1zw508d6qejxtdg4y5r3zarvaryvg6kdaj",
    18, {
      0x82, 0x10, 0x75, 0x1e, 0x76, 0xe8, 0x19, 0x91, 0x96, 0xd4, 0x54,
      0x94, 0x1c, 0x45, 0xd1, 0xb3, 0xa3, 0x23
    }
  },
  {
    "tb1qqqqqp399et2xygdj5xreqhjjvcmzhxw4aywxecjdzew6hylgvsesrxh6hy",
    34, {
      0x00, 0x20, 0x00, 0x00, 0x00, 0xc4, 0xa5, 0xca, 0xd4, 0x62, 0x21,
      0xb2, 0xa1, 0x87, 0x90, 0x5e, 0x52, 0x66, 0x36, 0x2b, 0x99, 0xd5,
      0xe9, 0x1c, 0x6c, 0xe2, 0x4d, 0x16, 0x5d, 0xab, 0x93, 0xe8, 0x64,
      0x33
    }
  }
};

static const std::string invalid_address[] = {
  "tc1qw508d6qejxtdg4y5r3zarvary0c5xw7kg3g4ty",
  "bc1qw508d6qejxtdg4y5r3zarvary0c5xw7kv8f3t5",
  "BC13W508D6QEJXTDG4Y5R3ZARVARY0C5XW7KN40WF2",
  "bc1rw5uspcuh",
  "bc10w508d6qejxtdg4y5r3zarvary0c5xw7kw508d6qejxtdg4y5r3zarvary0c5xw7kw5rljs90",
  "BC1QR508D6QEJXTDG4Y5R3ZARVARYV98GJ9P",
//  "tb1qrp33g0q5c5txsp9arysrx4k6zdkfs4nce4xj0gdcccefvpysxf3q0sL5k7",
  "bc1zw508d6qejxtdg4y5r3zarvaryvqyzf3du",
  "tb1qrp33g0q5c5txsp9arysrx4k6zdkfs4nce4xj0gdcccefvpysxf3pjxtptv",
  "bc1gmk9yu",
};

static const invalid_address_data invalid_address_enc[] = {
  {"BC", 0, 20},
  {"bc", 0, 21},
  {"bc", 17, 32},
  {"bc", 1, 1},
  {"bc", 16, 41},
};

- (NSData *)segwitScriptPubkeyWithWitVer:(int)witver witprog:(NSData *)witprog {
  NSMutableData *ret = [[NSData data] mutableCopy];
  uint8_t witverByte = (witver ? (0x80 | witver) : 0);
  uint8_t lengthByte = [witprog length];
  [ret appendBytes:&witverByte length:1];
  [ret appendBytes:&lengthByte length:1];
  [ret appendData:witprog];
  return [ret copy];
}

- (NSString *)stringFrom:(std::string)cppString {
  return [NSString stringWithCString:cppString.c_str() encoding:[NSString defaultCStringEncoding]];
}

- (void)testValidChecksums {
  for (int i = 0; i < sizeof(valid_checksum) / sizeof(valid_checksum[0]); ++i) {
    NSString *checksum = [self stringFrom:valid_checksum[i]];
    CNBBech32Metadata *dec = [CNBBech32Address decodeBech32Address:checksum];
    if ([[dec hrp] isEqualToString:@""]) {
      XCTFail(@"Failed to parse %@", checksum);
    }

    NSString *recode = [CNBBech32Address encodeBech32AddressWithHRP:[dec hrp] values:[dec data]];
    XCTAssertTrue([recode caseInsensitiveCompare:checksum] == NSOrderedSame);
  }
}

- (void)testInvalidChecksums {
  for (int i = 0; i < sizeof(invalid_checksum) / sizeof(invalid_checksum[0]); ++i) {
    NSString *invalidChecksum = [self stringFrom:invalid_checksum[i]];
    CNBBech32Metadata *dec = [CNBBech32Address decodeBech32Address:invalidChecksum];
    if (![[dec hrp] isEqualToString:@""] || [[dec data] length] != 0) {
      XCTFail(@"Parsed an invalid code: %@", invalidChecksum);
    }
    XCTAssert(YES);
  }
}

- (void)testValidAddresses {
  for (int i = 0; i < sizeof(valid_address) / sizeof(valid_address[0]); ++i) {
    NSString *hrp = @"bc";
    NSString *address = [self stringFrom:valid_address[i].address];
    CNBWitnessMetadata *dec = [CNBSegwitAddress decodeSegwitAddressWithHRP:hrp address:address];

    if ([dec witver] == -1) {
      hrp = @"tb";
      dec = [CNBSegwitAddress decodeSegwitAddressWithHRP:hrp address:address];
    }

    if ([dec witver] == -1) {
      XCTFail(@"Failed to decode segwit address: %@", address);
    }

    NSData *spk = [self segwitScriptPubkeyWithWitVer:(int)dec.witver witprog:dec.witprog];
    BOOL ok = (([spk length] == valid_address[i].scriptPubKeyLen) && (memcmp(&[spk dataChunk][0], valid_address[i].scriptPubKey, spk.length) == 0));
    if (!ok) {
      XCTFail(@"Segwit Address decode produces wrong result: %@", address);
    }

    NSString *recode = [CNBSegwitAddress encodeSegwitAddressWithHRP:hrp witnessMetadata:dec];

    if ([recode isEqualToString:@""]) {
      XCTFail(@"Segwit Address encode failes on %@", address);
    }

    XCTAssertTrue([recode caseInsensitiveCompare:address] == NSOrderedSame);
  }
}

- (void)testInvalidAddresses {
  for (int i = 0; i < sizeof(invalid_address) / sizeof(invalid_address[0]); ++i) {
    NSString *hrp = @"bc";
    NSString *address = [self stringFrom:invalid_address[i]];
    CNBWitnessMetadata *dec = [CNBSegwitAddress decodeSegwitAddressWithHRP:hrp address:address];
    if ([dec witver] != -1) {
      XCTFail(@"Segwit Address decode succeeds on invalid address: %@", address);
    }

    CNBWitnessMetadata *testDec = [CNBSegwitAddress decodeSegwitAddressWithHRP:@"tb" address:address];
    if ([testDec witver] != -1) {
      XCTFail(@"Segwit Address decode succeeds on invalid address: %@", address);
    }

    for (int j = 0; j < sizeof(invalid_address_enc) / sizeof(invalid_address_enc[0]); ++j) {
      invalid_address_data data = invalid_address_enc[j];
      NSString *localHRP = [self stringFrom:data.hrp];
      CNBWitnessMetadata *metadata = [[CNBWitnessMetadata alloc] init];
      metadata.witver = data.version;
      auto bytes = std::vector<uint8_t>(data.program_length, 0);
      metadata.witprog = [NSData dataWithBytes:bytes.data() length:data.program_length];
      NSString *code = [CNBSegwitAddress encodeSegwitAddressWithHRP:localHRP witnessMetadata:metadata];
      if (![code isEqualToString:@""]) {
        XCTFail(@"Segwit Address encode succeeds on invalid data: %@", code);
      }
    }
  }
}

- (void)testP2WSHAddressDecodesProperly {
  NSString *p2wshAddress = @"bc1qrp33g0q5c5txsp9arysrx4k6zdkfs4nce4xj0gdcccefvpysxf3qccfmv3";
  NSInteger expectedVersion = 0;
  NSString *expectedProgram = @"1863143c14c5166804bd19203356da136c985678cd4d27a1b8c6329604903262";
  NSInteger expectedProgSize = 32;

  NSString *hrp = [CNBSegwitAddress hrpFromAddress:p2wshAddress];
  CNBWitnessMetadata *decoded = [CNBSegwitAddress decodeSegwitAddressWithHRP:hrp address:p2wshAddress];

  NSInteger actualVersion = [decoded witver];
  NSString *actualProgram = [[decoded witprog] hexString];
  NSInteger actualProgSize = [[decoded witprog] length];
  XCTAssertEqual(expectedVersion, actualVersion);
  XCTAssertEqualObjects(expectedProgram, actualProgram);
  XCTAssertEqual(expectedProgSize, actualProgSize);
}

- (void)testRegtestAddressValidation {
  NSString *address = @"bcrt1q67jjgzu3tkqlc9vlrqh9xfdapv5us7sv4lhpf8";
  NSString *hrp = [CNBSegwitAddress hrpFromAddress:address];

  XCTAssertEqualObjects(hrp, @"bcrt");

  CNBWitnessMetadata *decoded = [CNBSegwitAddress decodeSegwitAddressWithHRP:hrp address:address];

  NSInteger expectedVersion = 0;
  NSInteger expectedProgSize = 20;
  NSString *expectedProgram = @"d7a5240b915d81fc159f182e5325bd0b29c87a0c";

  NSInteger actualVersion = [decoded witver];
  NSString *actualProgram = [[decoded witprog] hexString];
  NSInteger actualProgSize = [[decoded witprog] length];

  XCTAssertEqual(expectedVersion, actualVersion);
  XCTAssertEqualObjects(expectedProgram, actualProgram);
  XCTAssertEqual(expectedProgSize, actualProgSize);
}

@end
