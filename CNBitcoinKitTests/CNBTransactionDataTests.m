//
//  CNBTransactionDataTests.m
//  CNBitcoinKitTests
//
//  Created by BJ Miller on 5/29/18.
//  Copyright © 2018 Coin Ninja, LLC. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "CNBTransactionData.h"

@interface CNBTransactionDataTests : XCTestCase
@property (nonatomic) NSInteger bytesPerInOrOut;
@end

@implementation CNBTransactionDataTests

- (void)setUp {
  [super setUp];
  self.bytesPerInOrOut = 100;
}

- (void)tearDown {
  // Put teardown code here. This method is called after the invocation of each test method in the class.
  [super tearDown];
}

- (void)testSingleOutputWithSingleInputAndChangeSatisfies {
  // given
  NSUInteger paymentAmount = 50000000;
  NSUInteger utxoAmount = 100000000;
  CNBDerivationPath *changePath = [[CNBDerivationPath alloc] initWithPurpose:BIP49 coinType:MainNet account:0 change:1 index:0];
  CNBDerivationPath *utxoPath = [[CNBDerivationPath  alloc] initWithPurpose:BIP49 coinType:MainNet account:0 change:0 index:0];
  CNBUnspentTransactionOutput *utxo = [[CNBUnspentTransactionOutput alloc] initWithId:@"previous txid" index:0 amount:utxoAmount derivationPath:utxoPath isConfirmed:YES];
  NSUInteger feeRate = 30;
  NSUInteger numberOfInsAndOuts = 3;
  NSUInteger expectedFeeAmount = numberOfInsAndOuts * self.bytesPerInOrOut * feeRate;
  NSUInteger expectedChangeAmount = utxoAmount - paymentAmount - expectedFeeAmount;
  NSUInteger expectedNumberOfUTXOs = 1;
  NSUInteger expectedLocktime = 500000;

  // when
  CNBTransactionData *txData = [[CNBTransactionData alloc] initWithAddress:@"test address"
                                                   fromAllAvailableOutputs:@[utxo]
                                                             paymentAmount:paymentAmount
                                                                   feeRate:feeRate
                                                                changePath:changePath
                                                               blockHeight:500000];

  // then
  XCTAssertEqual(txData.amount, paymentAmount);
  XCTAssertEqual(txData.feeAmount, expectedFeeAmount);
  XCTAssertEqual(txData.changeAmount, expectedChangeAmount);
  XCTAssertEqual(txData.unspentTransactionOutputs.count, expectedNumberOfUTXOs);
  XCTAssertEqual(txData.locktime, expectedLocktime);
}

- (void)testSingleOutputWithDoubleInputAndChangeSatisfies {
  // given
  NSUInteger paymentAmount = 50000000;  // 0.5 BTC
  NSUInteger utxoAmount = 30000000;     // 0.3 BTC
  CNBDerivationPath *changePath = [[CNBDerivationPath alloc] initWithPurpose:BIP49 coinType:MainNet account:0 change:1 index:0];
  CNBDerivationPath *utxoPath = [[CNBDerivationPath alloc] initWithPurpose:BIP49 coinType:MainNet account:0 change:0 index:0];
  CNBUnspentTransactionOutput *utxo1 = [[CNBUnspentTransactionOutput alloc] initWithId:@"previous txid" index:0 amount:utxoAmount derivationPath:utxoPath isConfirmed:YES];
  CNBUnspentTransactionOutput *utxo2 = [[CNBUnspentTransactionOutput alloc] initWithId:@"previous txid" index:1 amount:utxoAmount derivationPath:utxoPath isConfirmed:YES];
  NSUInteger feeRate = 30;
  NSUInteger numberOfInsAndOuts = 4;
  NSUInteger expectedFeeAmount = numberOfInsAndOuts * self.bytesPerInOrOut * feeRate;
  NSUInteger amountFromUTXOs = 0;
  for (CNBUnspentTransactionOutput *utxo in @[utxo1, utxo2]) {
    amountFromUTXOs += utxo.amount;
  }
  NSUInteger expectedChangeAmount = amountFromUTXOs - paymentAmount - expectedFeeAmount;
  NSUInteger expectedNumberOfUTXOs = 2;
  NSUInteger expectedLocktime = 500000;

  // when
  CNBTransactionData *txData = [[CNBTransactionData alloc] initWithAddress:@"test address"
                                                   fromAllAvailableOutputs:@[utxo1, utxo2]
                                                             paymentAmount:paymentAmount
                                                                   feeRate:feeRate
                                                                changePath:changePath
                                                               blockHeight:500000];

  // then
  XCTAssertEqual(txData.amount, paymentAmount);
  XCTAssertEqual(txData.feeAmount, expectedFeeAmount);
  XCTAssertEqual(txData.changeAmount, expectedChangeAmount);
  XCTAssertEqual(txData.unspentTransactionOutputs.count, expectedNumberOfUTXOs);
  XCTAssertEqual(txData.locktime, expectedLocktime);
}

- (void)testSingleOutputWithSingleInputAndNoChangeSatisfies {
  // given
  NSUInteger paymentAmount = 50000000;  // 0.5 BTC
  NSUInteger utxoAmount = 50006000;     // 0.50006000 BTC
  CNBDerivationPath *changePath = [[CNBDerivationPath alloc] initWithPurpose:BIP49 coinType:MainNet account:0 change:1 index:0];
  CNBDerivationPath *utxoPath = [[CNBDerivationPath alloc] initWithPurpose:BIP49 coinType:MainNet account:0 change:0 index:0];
  CNBUnspentTransactionOutput *utxo1 = [[CNBUnspentTransactionOutput alloc] initWithId:@"previous txid" index:0 amount:utxoAmount derivationPath:utxoPath isConfirmed:YES];
  NSUInteger feeRate = 30;
  NSUInteger numberOfInsAndOuts = 2;
  NSUInteger expectedFeeAmount = numberOfInsAndOuts * self.bytesPerInOrOut * feeRate;
  NSUInteger expectedChangeAmount = 0;
  NSUInteger expectedNumberOfUTXOs = 1;
  NSUInteger expectedLocktime = 500000;

  // when
  CNBTransactionData *txData = [[CNBTransactionData alloc] initWithAddress:@"test address"
                                                   fromAllAvailableOutputs:@[utxo1]
                                                             paymentAmount:paymentAmount
                                                                   feeRate:feeRate
                                                                changePath:changePath
                                                               blockHeight:500000];

  // then
  XCTAssertEqual(txData.amount, paymentAmount);
  XCTAssertEqual(txData.feeAmount, expectedFeeAmount);
  XCTAssertEqual(txData.changeAmount, expectedChangeAmount);
  XCTAssertEqual(txData.unspentTransactionOutputs.count, expectedNumberOfUTXOs);
  XCTAssertEqual(txData.locktime, expectedLocktime);
}

- (void)testSingleOutputWithDoubleInputAndNoChangeSatisfies {
  // given
  NSUInteger paymentAmount = 50000000;  // 0.5 BTC
  NSUInteger utxoAmount1 = 20006000;    // 0.20006000 BTC
  NSUInteger utxoAmount2 = 30003000;    // 0.30003000 BTC
  CNBDerivationPath *changePath = [[CNBDerivationPath alloc] initWithPurpose:BIP49 coinType:MainNet account:0 change:1 index:0];
  CNBDerivationPath *utxoPath = [[CNBDerivationPath alloc] initWithPurpose:BIP49 coinType:MainNet account:0 change:0 index:0];
  CNBUnspentTransactionOutput *utxo1 = [[CNBUnspentTransactionOutput alloc] initWithId:@"previous txid" index:0 amount:utxoAmount1 derivationPath:utxoPath isConfirmed:YES];
  CNBUnspentTransactionOutput *utxo2 = [[CNBUnspentTransactionOutput alloc] initWithId:@"previous txid" index:1 amount:utxoAmount2 derivationPath:utxoPath isConfirmed:YES];
  NSUInteger feeRate = 30;
  NSUInteger numberOfInsAndOuts = 3;
  NSUInteger expectedFeeAmount = numberOfInsAndOuts * self.bytesPerInOrOut * feeRate;
  NSUInteger expectedChangeAmount = 0;
  NSUInteger expectedNumberOfUTXOs = 2;
  NSUInteger expectedLocktime = 500000;

  // when
  CNBTransactionData *txData = [[CNBTransactionData alloc] initWithAddress:@"test address"
                                                   fromAllAvailableOutputs:@[utxo1, utxo2]
                                                             paymentAmount:paymentAmount
                                                                   feeRate:feeRate
                                                                changePath:changePath
                                                               blockHeight:500000];

  // then
  XCTAssertEqual(txData.amount, paymentAmount);
  XCTAssertEqual(txData.feeAmount, expectedFeeAmount);
  XCTAssertEqual(txData.changeAmount, expectedChangeAmount);
  XCTAssertEqual(txData.unspentTransactionOutputs.count, expectedNumberOfUTXOs);
  XCTAssertEqual(txData.locktime, expectedLocktime);
}

- (void)testSingleOutputWithDoubleInputAndInsufficientfundsReturnsNil {
  // given
  NSUInteger paymentAmount = 50000000;  // 0.5 BTC
  NSUInteger utxoAmount1 = 20000000;    // 0.2 BTC
  NSUInteger utxoAmount2 = 10000000;    // 0.1 BTC
  CNBDerivationPath *changePath = [[CNBDerivationPath alloc] initWithPurpose:BIP49 coinType:MainNet account:0 change:1 index:0];
  CNBDerivationPath *utxoPath = [[CNBDerivationPath alloc] initWithPurpose:BIP49 coinType:MainNet account:0 change:0 index:0];
  CNBUnspentTransactionOutput *utxo1 = [[CNBUnspentTransactionOutput alloc] initWithId:@"previous txid" index:0 amount:utxoAmount1 derivationPath:utxoPath isConfirmed:YES];
  CNBUnspentTransactionOutput *utxo2 = [[CNBUnspentTransactionOutput alloc] initWithId:@"previous txid" index:1 amount:utxoAmount2 derivationPath:utxoPath isConfirmed:YES];
  NSUInteger feeRate = 30;

  // when
  CNBTransactionData *txData = [[CNBTransactionData alloc] initWithAddress:@"test address"
                                                   fromAllAvailableOutputs:@[utxo1, utxo2]
                                                             paymentAmount:paymentAmount
                                                                   feeRate:feeRate
                                                                changePath:changePath
                                                               blockHeight:500000];

  // then
  XCTAssertNil(txData);
}

- (void)testDustyChangeShouldBeRemoved {
  // given
  NSString *address = @"374Cb65dKaQj8sXHRcQybCFSCSDSNu6k6A";
  CNBDerivationPath *path1 = [[CNBDerivationPath alloc] initWithPurpose:BIP49 coinType:MainNet account:0 change:1 index:3];
  CNBUnspentTransactionOutput *out1 = [[CNBUnspentTransactionOutput alloc] initWithId:@"909ac6e0a31c68fe345cc72d568bbab75afb5229b648753c486518f11c0d0009"
                                                                                index:1
                                                                               amount:2221
                                                                       derivationPath:path1
                                                                          isConfirmed:YES];
  CNBDerivationPath *path2 = [[CNBDerivationPath alloc] initWithPurpose:BIP49 coinType:MainNet account:0 change:0 index:2];
  CNBUnspentTransactionOutput *out2 = [[CNBUnspentTransactionOutput alloc] initWithId:@"419a7a7d27e0c4341ca868d0b9744ae7babb18fd691e39be608b556961c00ade"
                                                                                index:0
                                                                               amount:15935
                                                                       derivationPath:path2
                                                                          isConfirmed:YES];
  CNBDerivationPath *path3 = [[CNBDerivationPath alloc] initWithPurpose:BIP49 coinType:MainNet account:0 change:0 index:8];
  CNBUnspentTransactionOutput *out3 = [[CNBUnspentTransactionOutput alloc] initWithId:@"3013fcd9ea8fd65a69709f07fed2c1fd765d57664486debcb72ef47f2ea415f6"
                                                                                index:0
                                                                               amount:15526
                                                                       derivationPath:path3
                                                                          isConfirmed:YES];
  CNBDerivationPath *path4 = [[CNBDerivationPath alloc] initWithPurpose:BIP49 coinType:MainNet account:0 change:1 index:4];
  CNBUnspentTransactionOutput *out4 = [[CNBUnspentTransactionOutput alloc] initWithId:@"4afc03bc6ca8b49e46990da8e7be0defc44e2b43b8981409c250659adef7314b"
                                                                                index:1
                                                                               amount:4044
                                                                       derivationPath:path4
                                                                          isConfirmed:YES];
  CNBDerivationPath *changePath = [[CNBDerivationPath alloc] initWithPurpose:BIP49 coinType:MainNet account:0 change:1 index:5];

  // when
  CNBTransactionData *txData = [[CNBTransactionData alloc] initWithAddress:address
                                                   fromAllAvailableOutputs:@[out1, out2, out3, out4]
                                                             paymentAmount:28273
                                                                   feeRate:15
                                                                changePath:changePath
                                                               blockHeight:500000];

  // then
  XCTAssertEqual([txData amount], 28273);
  XCTAssertEqual([txData feeAmount], 9000);
  XCTAssertEqual([[txData unspentTransactionOutputs] count], 4);
  XCTAssertEqual([txData changeAmount], 0);
  XCTAssertNil([txData changePath]);
}

- (void)testCostOfChangeIsEquitable {
  // given
  NSString *address = @"374Cb65dKaQj8sXHRcQybCFSCSDSNu6k6A";
  CNBDerivationPath *path1 = [[CNBDerivationPath alloc] initWithPurpose:BIP49 coinType:MainNet account:0 change:1 index:3];
  CNBUnspentTransactionOutput *out1 = [[CNBUnspentTransactionOutput alloc] initWithId:@"909ac6e0a31c68fe345cc72d568bbab75afb5229b648753c486518f11c0d0009"
                                                                                index:1
                                                                               amount:2221
                                                                       derivationPath:path1
                                                                          isConfirmed:YES];
  CNBDerivationPath *path2 = [[CNBDerivationPath alloc] initWithPurpose:BIP49 coinType:MainNet account:0 change:0 index:2];
  CNBUnspentTransactionOutput *out2 = [[CNBUnspentTransactionOutput alloc] initWithId:@"419a7a7d27e0c4341ca868d0b9744ae7babb18fd691e39be608b556961c00ade"
                                                                                index:0
                                                                               amount:15935
                                                                       derivationPath:path2
                                                                          isConfirmed:YES];
  CNBDerivationPath *path3 = [[CNBDerivationPath alloc] initWithPurpose:BIP49 coinType:MainNet account:0 change:0 index:8];
  CNBUnspentTransactionOutput *out3 = [[CNBUnspentTransactionOutput alloc] initWithId:@"3013fcd9ea8fd65a69709f07fed2c1fd765d57664486debcb72ef47f2ea415f6"
                                                                                index:0
                                                                               amount:15526
                                                                       derivationPath:path3
                                                                          isConfirmed:YES];
  CNBDerivationPath *path4 = [[CNBDerivationPath alloc] initWithPurpose:BIP49 coinType:MainNet account:0 change:1 index:4];
  CNBUnspentTransactionOutput *out4 = [[CNBUnspentTransactionOutput alloc] initWithId:@"4afc03bc6ca8b49e46990da8e7be0defc44e2b43b8981409c250659adef7314b"
                                                                                index:1
                                                                               amount:4044
                                                                       derivationPath:path4
                                                                          isConfirmed:YES];
  CNBDerivationPath *changePath = [[CNBDerivationPath alloc] initWithPurpose:BIP49 coinType:MainNet account:0 change:1 index:5];

  // when, with not enough to satisfy change threshold
  CNBTransactionData *txData = [[CNBTransactionData alloc] initWithAddress:address
                                                   fromAllAvailableOutputs:@[out1, out2, out3, out4]
                                                             paymentAmount:26228
                                                                   feeRate:15
                                                                changePath:changePath
                                                               blockHeight:500000];

  // then
  XCTAssertEqual([txData amount], 26228);
  XCTAssertEqual([txData feeAmount], 9000);
  XCTAssertEqual([[txData unspentTransactionOutputs] count], 4);
  XCTAssertEqual([txData changeAmount], 0);
  XCTAssertNil([txData changePath]);

  // when again, with enough to satisfy change threshold
  CNBTransactionData *goodTxData = [[CNBTransactionData alloc] initWithAddress:address
                                                       fromAllAvailableOutputs:@[out1, out2, out3, out4]
                                                                 paymentAmount:26226
                                                                       feeRate:15
                                                                    changePath:changePath
                                                                   blockHeight:500000];

  // and then
  XCTAssertEqual([goodTxData amount], 26226);
  XCTAssertEqual([goodTxData feeAmount], 9000);
  XCTAssertEqual([[goodTxData unspentTransactionOutputs] count], 4);
  XCTAssertEqual([goodTxData changeAmount], 2500);
  XCTAssertEqualObjects([goodTxData changePath], changePath);
}

// MARK: flat fee tests
- (void)testTransactionDataWithFlatFeeCalculatesUTXOsAndChangeProperly {
  // given
  NSString *address = @"374Cb65dKaQj8sXHRcQybCFSCSDSNu6k6A";
  CNBDerivationPath *path1 = [[CNBDerivationPath alloc] initWithPurpose:BIP49 coinType:MainNet account:0 change:1 index:3];
  CNBUnspentTransactionOutput *out1 = [[CNBUnspentTransactionOutput alloc] initWithId:@"909ac6e0a31c68fe345cc72d568bbab75afb5229b648753c486518f11c0d0009"
                                                                                index:1
                                                                               amount:2221
                                                                       derivationPath:path1
                                                                          isConfirmed:YES];
  CNBDerivationPath *path2 = [[CNBDerivationPath alloc] initWithPurpose:BIP49 coinType:MainNet account:0 change:0 index:2];
  CNBUnspentTransactionOutput *out2 = [[CNBUnspentTransactionOutput alloc] initWithId:@"419a7a7d27e0c4341ca868d0b9744ae7babb18fd691e39be608b556961c00ade"
                                                                                index:0
                                                                               amount:15935
                                                                       derivationPath:path2
                                                                          isConfirmed:YES];
  CNBDerivationPath *path3 = [[CNBDerivationPath alloc] initWithPurpose:BIP49 coinType:MainNet account:0 change:0 index:8];
  CNBUnspentTransactionOutput *out3 = [[CNBUnspentTransactionOutput alloc] initWithId:@"3013fcd9ea8fd65a69709f07fed2c1fd765d57664486debcb72ef47f2ea415f6"
                                                                                index:0
                                                                               amount:15526
                                                                       derivationPath:path3
                                                                          isConfirmed:YES];
  CNBDerivationPath *changePath = [[CNBDerivationPath alloc] initWithPurpose:BIP49 coinType:MainNet account:0 change:1 index:5];

  // when
  CNBTransactionData *txData = [[CNBTransactionData alloc] initWithAddress:address
                                                   fromAllAvailableOutputs:@[out1, out2, out3]
                                                             paymentAmount:20000
                                                                   flatFee:10000
                                                                changePath:changePath
                                                               blockHeight:500000];

  // then
  XCTAssertEqual([txData amount], 20000);
  XCTAssertEqual([txData feeAmount], 10000);
  XCTAssertEqual([txData changeAmount], 3682);
  XCTAssertNotNil([txData changePath]);
}

- (void)testDustyTransactionDataWithFlatFeeCalculatesUTXOsAndNoChangeProperly {
  // given
  NSString *address = @"374Cb65dKaQj8sXHRcQybCFSCSDSNu6k6A";
  CNBDerivationPath *path1 = [[CNBDerivationPath alloc] initWithPurpose:BIP49 coinType:MainNet account:0 change:1 index:3];
  CNBUnspentTransactionOutput *out1 = [[CNBUnspentTransactionOutput alloc] initWithId:@"909ac6e0a31c68fe345cc72d568bbab75afb5229b648753c486518f11c0d0009"
                                                                                index:1
                                                                               amount:20000
                                                                       derivationPath:path1
                                                                          isConfirmed:YES];
  CNBDerivationPath *path2 = [[CNBDerivationPath alloc] initWithPurpose:BIP49 coinType:MainNet account:0 change:0 index:2];
  CNBUnspentTransactionOutput *out2 = [[CNBUnspentTransactionOutput alloc] initWithId:@"419a7a7d27e0c4341ca868d0b9744ae7babb18fd691e39be608b556961c00ade"
                                                                                index:0
                                                                               amount:10100
                                                                       derivationPath:path2
                                                                          isConfirmed:YES];
  CNBDerivationPath *changePath = [[CNBDerivationPath alloc] initWithPurpose:BIP49 coinType:MainNet account:0 change:1 index:5];

  // when
  CNBTransactionData *txData = [[CNBTransactionData alloc] initWithAddress:address
                                                   fromAllAvailableOutputs:@[out1, out2]
                                                             paymentAmount:20000
                                                                   flatFee:10000
                                                                changePath:changePath
                                                               blockHeight:500000];

  // then
  XCTAssertEqual([txData amount], 20000);
  XCTAssertEqual([txData feeAmount], 10000);
  XCTAssertEqual([txData changeAmount], 0);
  XCTAssertNil([txData changePath]);
}

// MARK: send max
- (void)testSendMaxUsesAllUTXOsAndAmountIsTotalValueMinusFee {
  // given
  NSString *address = @"374Cb65dKaQj8sXHRcQybCFSCSDSNu6k6A";
  NSUInteger feeRate = 5;
  CNBDerivationPath *path1 = [[CNBDerivationPath alloc] initWithPurpose:BIP49 coinType:MainNet account:0 change:1 index:3];
  CNBUnspentTransactionOutput *out1 = [[CNBUnspentTransactionOutput alloc] initWithId:@"909ac6e0a31c68fe345cc72d568bbab75afb5229b648753c486518f11c0d0009"
                                                                                index:1
                                                                               amount:20000
                                                                       derivationPath:path1
                                                                          isConfirmed:YES];
  CNBDerivationPath *path2 = [[CNBDerivationPath alloc] initWithPurpose:BIP49 coinType:MainNet account:0 change:0 index:2];
  CNBUnspentTransactionOutput *out2 = [[CNBUnspentTransactionOutput alloc] initWithId:@"419a7a7d27e0c4341ca868d0b9744ae7babb18fd691e39be608b556961c00ade"
                                                                                index:0
                                                                               amount:10000
                                                                       derivationPath:path2
                                                                          isConfirmed:YES];
  NSArray *utxos = @[out1, out2];
  NSUInteger inputAmount = out1.amount + out2.amount;
  NSUInteger numOutputs = 1;
  NSUInteger expectedFeeAmount = feeRate * (utxos.count + numOutputs) * self.bytesPerInOrOut;
  NSUInteger expectedAmount = inputAmount - expectedFeeAmount;

  // when
  CNBTransactionData *txData = [[CNBTransactionData alloc] initWithAllUsableOutputs:utxos
                                                                sendingMaxToAddress:address
                                                                            feeRate:feeRate
                                                                        blockHeight:500000];

  // then
  XCTAssertEqual([txData amount], expectedAmount);
  XCTAssertEqual([txData feeAmount], expectedFeeAmount);
  XCTAssertEqual([txData feeAmount], 1500);
  XCTAssertEqual([txData changeAmount], 0);
  XCTAssertNil([txData changePath]);
}

- (void)testSendMaxWithInsufficientFundsReturnsNil {
  // given
  NSString *address = @"374Cb65dKaQj8sXHRcQybCFSCSDSNu6k6A";
  NSUInteger feeRate = 5;
  CNBDerivationPath *path1 = [[CNBDerivationPath alloc] initWithPurpose:BIP49 coinType:MainNet account:0 change:1 index:3];
  CNBUnspentTransactionOutput *out1 = [[CNBUnspentTransactionOutput alloc] initWithId:@"909ac6e0a31c68fe345cc72d568bbab75afb5229b648753c486518f11c0d0009"
                                                                                index:1
                                                                               amount:100
                                                                       derivationPath:path1
                                                                          isConfirmed:YES];
  NSArray *utxos = @[out1];

  // when
  CNBTransactionData *txData = [[CNBTransactionData alloc] initWithAllUsableOutputs:utxos
                                                                sendingMaxToAddress:address
                                                                            feeRate:feeRate
                                                                        blockHeight:500000];

  // then
  XCTAssertNil(txData);
}

- (void)testSendMaxWithJustEnoughFundsReturnsObject {
  // given
  NSString *address = @"374Cb65dKaQj8sXHRcQybCFSCSDSNu6k6A";
  NSUInteger feeRate = 5;
  CNBDerivationPath *path1 = [[CNBDerivationPath alloc] initWithPurpose:BIP49 coinType:MainNet account:0 change:1 index:3];
  CNBUnspentTransactionOutput *out1 = [[CNBUnspentTransactionOutput alloc] initWithId:@"909ac6e0a31c68fe345cc72d568bbab75afb5229b648753c486518f11c0d0009"
                                                                                index:1
                                                                               amount:1000
                                                                       derivationPath:path1
                                                                          isConfirmed:YES];
  NSArray *utxos = @[out1];
  NSUInteger inputAmount = out1.amount;
  NSUInteger numOutputs = 1;
  NSUInteger expectedFeeAmount = feeRate * (utxos.count + numOutputs) * self.bytesPerInOrOut;
  NSUInteger expectedAmount = inputAmount - expectedFeeAmount;

  // when
  CNBTransactionData *txData = [[CNBTransactionData alloc] initWithAllUsableOutputs:utxos
                                                                sendingMaxToAddress:address
                                                                            feeRate:feeRate
                                                                        blockHeight:500000];

  // then
  XCTAssertEqual([txData amount], expectedAmount);
  XCTAssertEqual([txData amount], 0);
  XCTAssertEqual([txData feeAmount], expectedFeeAmount);
  XCTAssertEqual([txData feeAmount], 1000);
  XCTAssertEqual([txData changeAmount], 0);
  XCTAssertNil([txData changePath]);
}

@end
