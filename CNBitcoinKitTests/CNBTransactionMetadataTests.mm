//
//  CNBTransactionMetadataTests.m
//  CNBitcoinKitTests
//
//  Created by BJ Miller on 8/12/19.
//  Copyright © 2019 Coin Ninja, LLC. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "CNBTransactionMetadata.h"
#import "CNBTransactionMetadata+Project.h"
#import "CNBDerivationPath.h"

#ifdef __cplusplus
#include <string>
#include <bitcoin/bitcoin/coinninja/wallet/derivation_path.hpp>
#endif

using namespace coinninja::wallet;

@interface CNBTransactionMetadataTests : XCTestCase

@end

@implementation CNBTransactionMetadataTests

- (void)setUp {
}

- (void)tearDown {
}

- (void)testTranslatingToCNBObjectFromCppObject {
  std::string c_txid{"sample txid"};
  std::string c_encoded_tx{"01000000"};
  std::string c_change_address{"38BhTc8HcgUwdsafFQqd2TSN8iFGgsLQZK"};
  coinninja::wallet::derivation_path c_change_path{49,0,0,1,10};
  uint c_vout_index{1};

  coinninja::transaction::transaction_metadata c_metadata{
    c_txid, c_encoded_tx, c_change_address, c_change_path, c_vout_index
  };

  CNBTransactionMetadata *metadata = [CNBTransactionMetadata metadataFromC_metadata:c_metadata];

  XCTAssertEqualObjects([metadata txid], @"sample txid");
  XCTAssertEqualObjects([metadata encodedTx], @"01000000");
  XCTAssertEqualObjects([metadata changeAddress], @"38BhTc8HcgUwdsafFQqd2TSN8iFGgsLQZK");
  XCTAssertEqual((int)[[metadata changePath] purpose], 49);
  XCTAssertEqual((int)[[metadata changePath] coinType], 0);
  XCTAssertEqual((int)[[metadata changePath] account], 0);
  XCTAssertEqual((int)[[metadata changePath] change], 1);
  XCTAssertEqual((int)[[metadata changePath] index], 10);
  XCTAssertEqual([[metadata voutIndex] unsignedIntValue], 1);
}

- (void)testTranslatingToCppObjectFromCNBTransactionMetadataObject {
  CNBDerivationPath *changePath = [[CNBDerivationPath alloc] initWithPurpose:BIP49 coinType:MainNet account:0 change:1 index:10];
  CNBTransactionMetadata *metadata = [[CNBTransactionMetadata alloc] initWithTxid:@"sample txid" encodedTx:@"01000000" changeAddress:@"38BhTc8HcgUwdsafFQqd2TSN8iFGgsLQZK" changePath:changePath voutIndex:[NSNumber numberWithUnsignedInteger:1]];

  coinninja::transaction::transaction_metadata c_metadata = [metadata c_metadata];

  XCTAssertEqual(c_metadata.get_txid(), "sample txid");
  XCTAssertEqual(c_metadata.get_encoded_tx(), "01000000");
  XCTAssertEqual(*(c_metadata.get_change_address()), "38BhTc8HcgUwdsafFQqd2TSN8iFGgsLQZK");
  uint32_t expectedPurpose = 0x80000031;
  uint32_t expectedCoin = 0x80000000;
  uint32_t expectedAccount = 0x80000000;
  uint32_t expectedChange = 0x00000001;
  uint32_t expectedIndex = 0x0000000A;
  auto purpose = c_metadata.get_change_path()->get_hardened_purpose();
  auto coin = c_metadata.get_change_path()->get_hardened_coin();
  auto account = c_metadata.get_change_path()->get_hardened_account();
  auto change = c_metadata.get_change_path()->get_change();
  auto index = c_metadata.get_change_path()->get_index();
  XCTAssertEqual(purpose, expectedPurpose);
  XCTAssertEqual(coin, expectedCoin);
  XCTAssertEqual(account, expectedAccount);
  XCTAssertEqual(change, expectedChange);
  XCTAssertEqual(index, expectedIndex);
}

@end
