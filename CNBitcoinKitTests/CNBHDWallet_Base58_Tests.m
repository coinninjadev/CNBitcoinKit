//
//  CNBHDWallet_Base58_Tests.m
//  CNBitcoinKitTests
//
//  Created by BJ Miller on 9/18/18.
//  Copyright © 2018 Coin Ninja, LLC. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "CNBitcoinKit.h"

@interface CNBHDWallet_Base58_Tests : XCTestCase

@end

@implementation CNBHDWallet_Base58_Tests

- (void)test_valid_BreadP2PKHAddress_isValid {
  NSString *address = @"12vRFewBpbdiS5HXDDLEfVFtJnpA2x8NV8";
  BOOL isValid = [CNBHDWallet addressIsBase58CheckEncoded:address];
  XCTAssertTrue(isValid, @"Valid Bread P2PKH should be valid Base58Check address");
}

- (void)test_invalid_BreadP2PKHAddress_isInvalid {
  NSString *address = @"12vRFewBpbdiS5HXDDLEfVFtJnpA2";
  BOOL isValid = [CNBHDWallet addressIsBase58CheckEncoded:address];
  XCTAssertFalse(isValid, @"Invalid Bread P2PKH should be invalid Base58Check address");
}

- (void)test_valid_P2PKHAddress_isValid {
  NSString *address = @"16UwLL9Risc3QfPqBUvKofHmBQ7wMtjvM";
  BOOL isValid = [CNBHDWallet addressIsBase58CheckEncoded:address];
  XCTAssertTrue(isValid, @"Valid P2PKH should be valid Base58Check address");
}

- (void)test_invalid_P2PKHAddressWithCharactersRemoved_isInvalid {
  NSString *address = @"12vRFewBpbdiS5HXDDLEfVFt";
  BOOL isValid = [CNBHDWallet addressIsBase58CheckEncoded:address];
  XCTAssertFalse(isValid, @"Invalid P2PKH should be invalid Base58Check address");
}

- (void)test_invalid_P2PKHAddressWithFirst10CharsRemoved_isInvalid {
  NSString *address = @"diS5HXDDLEfVFtJnpA2x8NV8";
  BOOL isValid = [CNBHDWallet addressIsBase58CheckEncoded:address];
  XCTAssertFalse(isValid, @"Invalid P2PKH should be invalid Base58Check address");
}

- (void)test_invalid_P2PKHAddressWithExtraLeadingDigit_isInvalid {
  NSString *address = @"212vRFewBpbdiS5HXDDLEfVFtJnpA2x8NV8";
  BOOL isValid = [CNBHDWallet addressIsBase58CheckEncoded:address];
  XCTAssertFalse(isValid, @"Invalid P2PKH should be invalid Base58Check address");
}

- (void)test_invalid_P2PKHAddressWithDifferentLeadingDigit_isInvalid {
  NSString *address = @"42vRFewBpbdiS5HXDDLEfVFtJnpA2x8NV8";
  BOOL isValid = [CNBHDWallet addressIsBase58CheckEncoded:address];
  XCTAssertFalse(isValid, @"Invalid P2PKH should be invalid Base58Check address");
}

- (void)test_valid_P2SHAddressFromCoinbase_isValid {
  NSString *address = @"3EH9Wj6KWaZBaYXhVCa8ZrwpHJYtk44bGX";
  BOOL isValid = [CNBHDWallet addressIsBase58CheckEncoded:address];
  XCTAssertTrue(isValid, @"Valid P2SH should be valid Base58Check address");
}

- (void)test_invalid_P2SHAddressWithLast5CharsRemoved_isInvalid {
  NSString *address = @"3EH9Wj6KWaZBaYXhVCa8ZrwpHJYtk";
  BOOL isValid = [CNBHDWallet addressIsBase58CheckEncoded:address];
  XCTAssertFalse(isValid, @"Invalid P2SH should be invalid Base58Check address");
}

- (void)test_invalid_P2SHAddressWithFirst5CharsRemoved_isInvalid {
  NSString *address = @"j6KWaZBaYXhVCa8ZrwpHJYtk44bGX";
  BOOL isValid = [CNBHDWallet addressIsBase58CheckEncoded:address];
  XCTAssertFalse(isValid, @"Invalid P2SH should be invalid Base58Check address");
}

- (void)test_invalid_P2SHAddressWithFirst10CharsRemoved_isInvalid {
  NSString *address = @"ZBaYXhVCa8ZrwpHJYtk44bGX";
  BOOL isValid = [CNBHDWallet addressIsBase58CheckEncoded:address];
  XCTAssertFalse(isValid, @"Invalid P2SH should be invalid Base58Check address");
}

- (void)test_invalid_P2SHAddressWithExtraLeadingDigit_isInvalid {
  NSString *address = @"23EH9Wj6KWaZBaYXhVCa8ZrwpHJYtk44bGX";
  BOOL isValid = [CNBHDWallet addressIsBase58CheckEncoded:address];
  XCTAssertFalse(isValid, @"Invalid P2SH should be invalid Base58Check address");
}

- (void)test_valid_DropBitP2SHP2WPKHAddress_isValid {
  NSString *address = @"3Cd4xEu2VvM352BVgd9cb1Ct5vxz318tVT";
  BOOL isValid = [CNBHDWallet addressIsBase58CheckEncoded:address];
  XCTAssertTrue(isValid, @"Valid P2SH(P2WPKH) should be valid Base58Check address");
}

- (void)test_invalid_DropBitP2SHP2WPKHAddressWithLast5CharsRemoved_isInvalid {
  NSString *address = @"3Cd4xEu2VvM352BVgd9cb1Ct5vxz3";
  BOOL isValid = [CNBHDWallet addressIsBase58CheckEncoded:address];
  XCTAssertFalse(isValid, @"Invalid P2SH(P2WPKH) should be invalid Base58Check address");
}

- (void)test_invalid_DropBitP2SHP2WPKHAddressWithLast10CharsRemoved_isInvalid {
  NSString *address = @"3Cd4xEu2VvM352BVgd9cb1Ct";
  BOOL isValid = [CNBHDWallet addressIsBase58CheckEncoded:address];
  XCTAssertFalse(isValid, @"Invalid P2SH(P2WPKH) should be invalid Base58Check address");
}

- (void)test_invalid_DropBitP2SHP2WPKHAddressWithFirst5CharsRemoved_isInvalid {
  NSString *address = @"Eu2VvM352BVgd9cb1Ct5vxz318tVT";
  BOOL isValid = [CNBHDWallet addressIsBase58CheckEncoded:address];
  XCTAssertFalse(isValid, @"Invalid P2SH(P2WPKH) should be invalid Base58Check address");
}

- (void)test_invalid_DropBitP2SHP2WPKHAddressWithFirst10CharsRemoved_isInvalid {
  NSString *address = @"M352BVgd9cb1Ct5vxz318tVT";
  BOOL isValid = [CNBHDWallet addressIsBase58CheckEncoded:address];
  XCTAssertFalse(isValid, @"Invalid P2SH(P2WPKH) should be invalid Base58Check address");
}

- (void)test_invalid_DropBitP2SHP2WPKHAddressWithExtraLeadingChar_isInvalid {
  NSString *address = @"23Cd4xEu2VvM352BVgd9cb1Ct5vxz318tVT";
  BOOL isValid = [CNBHDWallet addressIsBase58CheckEncoded:address];
  XCTAssertFalse(isValid, @"Invalid P2SH(P2WPKH) should be invalid Base58Check address");
}

- (void)test_invalid_DropBitP2SHP2WPKHAddressWithDifferentLeadingChar_isInvalid {
  NSString *address = @"4Cd4xEu2VvM352BVgd9cb1Ct5vxz318tVT";
  BOOL isValid = [CNBHDWallet addressIsBase58CheckEncoded:address];
  XCTAssertFalse(isValid, @"Invalid P2SH(P2WPKH) should be invalid Base58Check address");
}

- (void)test_valid_EthereumAddress_isInvalid {
  NSString *address = @"0xF26C29D25a1E1696c5CC54DE4bf2AEc906EB4F79";
  BOOL isValid = [CNBHDWallet addressIsBase58CheckEncoded:address];
  XCTAssertFalse(isValid, @"Valid Ethereum address should be invalid Base58Check address");
}

- (void)test_valid_BCHAddress_isInvalid {
  NSString *address = @"qr45rul6luexjgg5h8p26c0cs6rrhwzrkg6e0hdvrf";
  BOOL isValid = [CNBHDWallet addressIsBase58CheckEncoded:address];
  XCTAssertFalse(isValid, @"Valid BCH address should be invalid Base58Check address");
}

- (void)test_invalid_SongLyricsAddress_isInvalid {
  NSString *address = @"Jenny86753098675309IgotIt";
  BOOL isValid = [CNBHDWallet addressIsBase58CheckEncoded:address];
  XCTAssertFalse(isValid, @"Invalid song lyrics should be invalid Base58Check address");
}

- (void)test_invalid_gibberishAddress_isInvalid {
  NSString *address = @"31415926535ILikePi89793238462643";
  BOOL isValid = [CNBHDWallet addressIsBase58CheckEncoded:address];
  XCTAssertFalse(isValid, @"Invalid gibberish should be invalid Base58Check address");
}

- (void)test_invalid_FooAddress_isInvalid {
  NSString *address = @"foo";
  BOOL isValid = [CNBHDWallet addressIsBase58CheckEncoded:address];
  XCTAssertFalse(isValid, @"Invalid foo should be invalid Base58Check address");
}

- (void)test_invalid_EmptyStringAddress_isInvalid {
  NSString *address = @"";
  BOOL isValid = [CNBHDWallet addressIsBase58CheckEncoded:address];
  XCTAssertFalse(isValid, @"Invalid empty string should be invalid Base58Check address");
}

@end
