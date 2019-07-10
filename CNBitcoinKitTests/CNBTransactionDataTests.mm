//
//  CNBTransactionDataTests.m
//  CNBitcoinKitTests
//
//  Created by BJ Miller on 5/29/18.
//  Copyright © 2018 Coin Ninja, LLC. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "CNBTransactionData.h"
#import "CNBAddressHelper.h"
#import "CNBBaseCoin.h"

@interface CNBTransactionDataTests : XCTestCase
@property (nonatomic, retain) CNBAddressHelper *helper;
@property (nonatomic, retain) NSString *testAddress;
@property (nonatomic, retain) CNBBaseCoin *coin;
@end

@implementation CNBTransactionDataTests

- (void)setUp {
  [super setUp];
  self.testAddress = @"37VucYSaXLCAsxYyAPfbSi9eh4iEcbShgf";
  self.coin = [[CNBBaseCoin alloc] initWithPurpose:BIP49 coin:MainNet account:0];
  self.helper = [[CNBAddressHelper alloc] initWithCoin:self.coin];
}

- (void)tearDown {
  self.helper = nil;
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

  bc::wallet::payment_address payment_address = [[self helper] paymentAddressFromString:[self testAddress]];
  NSUInteger totalBytes = [[self helper] totalBytesWithInputCount:1 paymentAddress:payment_address includeChangeAddress:YES];
  NSUInteger expectedFeeAmount = feeRate * totalBytes; // 4,980
  NSUInteger expectedChangeAmount = utxoAmount - paymentAmount - expectedFeeAmount;
  NSUInteger expectedNumberOfUTXOs = 1;
  NSUInteger expectedLocktime = 500000;

  // when
  CNBTransactionData *txData = [[CNBTransactionData alloc] initWithAddress:[self testAddress]
                                                                      coin:self.coin
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
  NSArray *utxos = @[utxo1, utxo2];
  NSUInteger feeRate = 30;

  bc::wallet::payment_address payment_address = [[self helper] paymentAddressFromString:[self testAddress]];
  NSUInteger totalBytes = [[self helper] totalBytesWithInputCount:[utxos count] paymentAddress:payment_address includeChangeAddress:YES];
  NSUInteger expectedFeeAmount = feeRate * totalBytes; // 7,710

  NSUInteger amountFromUTXOs = 0;
  for (CNBUnspentTransactionOutput *utxo in utxos) {
    amountFromUTXOs += utxo.amount;
  }
  NSUInteger expectedChangeAmount = amountFromUTXOs - paymentAmount - expectedFeeAmount;
  NSUInteger expectedNumberOfUTXOs = 2;
  NSUInteger expectedLocktime = 500000;

  // when
  CNBTransactionData *txData = [[CNBTransactionData alloc] initWithAddress:[self testAddress]
                                                                      coin:self.coin
                                                   fromAllAvailableOutputs:utxos
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
  NSUInteger utxoAmount = 50004020;     // 0.50004020 BTC
  CNBDerivationPath *changePath = [[CNBDerivationPath alloc] initWithPurpose:BIP49 coinType:MainNet account:0 change:1 index:0];
  CNBDerivationPath *utxoPath = [[CNBDerivationPath alloc] initWithPurpose:BIP49 coinType:MainNet account:0 change:0 index:0];
  CNBUnspentTransactionOutput *utxo1 = [[CNBUnspentTransactionOutput alloc] initWithId:@"previous txid" index:0 amount:utxoAmount derivationPath:utxoPath isConfirmed:YES];
  NSArray *utxos = @[utxo1];
  NSUInteger feeRate = 30;

  bc::wallet::payment_address payment_address = [[self helper] paymentAddressFromString:[self testAddress]];
  NSUInteger totalBytes = [[self helper] totalBytesWithInputCount:[utxos count] paymentAddress:payment_address includeChangeAddress:NO];
  NSUInteger expectedFeeAmount = feeRate * totalBytes; // 4,020

  NSUInteger expectedChangeAmount = 0;
  NSUInteger expectedNumberOfUTXOs = 1;
  NSUInteger expectedLocktime = 500000;

  // when
  CNBTransactionData *txData = [[CNBTransactionData alloc] initWithAddress:[self testAddress]
                                                                      coin:self.coin
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
  NSUInteger utxoAmount1 = 20001750;    // 0.20001750 BTC
  NSUInteger utxoAmount2 = 30005000;    // 0.30005000 BTC
  CNBDerivationPath *changePath = [[CNBDerivationPath alloc] initWithPurpose:BIP49 coinType:MainNet account:0 change:1 index:0];
  CNBDerivationPath *utxoPath = [[CNBDerivationPath alloc] initWithPurpose:BIP49 coinType:MainNet account:0 change:0 index:0];
  CNBUnspentTransactionOutput *utxo1 = [[CNBUnspentTransactionOutput alloc] initWithId:@"previous txid" index:0 amount:utxoAmount1 derivationPath:utxoPath isConfirmed:YES];
  CNBUnspentTransactionOutput *utxo2 = [[CNBUnspentTransactionOutput alloc] initWithId:@"previous txid" index:1 amount:utxoAmount2 derivationPath:utxoPath isConfirmed:YES];

  NSArray *utxos = @[utxo1, utxo2];
  NSUInteger feeRate = 30;

  bc::wallet::payment_address payment_address = [[self helper] paymentAddressFromString:[self testAddress]];
  NSUInteger totalBytes = [[self helper] totalBytesWithInputCount:[utxos count] paymentAddress:payment_address includeChangeAddress:NO];
  NSUInteger expectedFeeAmount = feeRate * totalBytes; // 6,750

  NSUInteger expectedChangeAmount = 0;
  NSUInteger expectedNumberOfUTXOs = 2;
  NSUInteger expectedLocktime = 500000;

  // when
  CNBTransactionData *txData = [[CNBTransactionData alloc] initWithAddress:[self testAddress]
                                                                      coin:self.coin
                                                   fromAllAvailableOutputs:utxos
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
  NSArray *utxos = @[utxo1, utxo2];
  NSUInteger feeRate = 30;

  // when
  CNBTransactionData *txData = [[CNBTransactionData alloc] initWithAddress:[self testAddress]
                                                                      coin:self.coin
                                                   fromAllAvailableOutputs:utxos
                                                             paymentAmount:paymentAmount
                                                                   feeRate:feeRate
                                                                changePath:changePath
                                                               blockHeight:500000];

  // then
  XCTAssertNil(txData);
}

- (void)testCostOfChangeBeneficial {
  // given
  CNBDerivationPath *path1 = [[CNBDerivationPath alloc] initWithPurpose:BIP49 coinType:MainNet account:0 change:1 index:3];
  CNBUnspentTransactionOutput *out1 = [[CNBUnspentTransactionOutput alloc] initWithId:@"909ac6e0a31c68fe345cc72d568bbab75afb5229b648753c486518f11c0d0009"
                                                                                index:1
                                                                               amount:100000
                                                                       derivationPath:path1
                                                                          isConfirmed:YES];
  CNBDerivationPath *path2 = [[CNBDerivationPath alloc] initWithPurpose:BIP49 coinType:MainNet account:0 change:0 index:2];
  CNBUnspentTransactionOutput *out2 = [[CNBUnspentTransactionOutput alloc] initWithId:@"419a7a7d27e0c4341ca868d0b9744ae7babb18fd691e39be608b556961c00ade"
                                                                                index:0
                                                                               amount:100000
                                                                       derivationPath:path2
                                                                          isConfirmed:YES];
  NSArray *utxos = @[out1, out2];
  CNBDerivationPath *changePath = [[CNBDerivationPath alloc] initWithPurpose:BIP49 coinType:MainNet account:0 change:1 index:5];

  NSUInteger feeRate = 10;
  bc::wallet::payment_address payment_address = [[self helper] paymentAddressFromString:[self testAddress]];
  NSUInteger totalBytes = [[self helper] totalBytesWithInputCount:[utxos count] paymentAddress:payment_address includeChangeAddress:NO];
  NSUInteger dustyChange = 1100;
  NSUInteger expectedFeeAmount = feeRate * totalBytes + dustyChange; // 2,250 + 1,100 = 3,350
  NSUInteger paymentAmount = out1.amount + out2.amount - expectedFeeAmount; // 200,000 - 3,350 = 196,650

  // when, with not enough to satisfy change threshold
  CNBTransactionData *txData = [[CNBTransactionData alloc] initWithAddress:[self testAddress]
                                                                      coin:self.coin
                                                   fromAllAvailableOutputs:utxos
                                                             paymentAmount:paymentAmount
                                                                   feeRate:feeRate
                                                                changePath:changePath
                                                               blockHeight:500000];

  // then
  // NOT ANYMORE when change would only be 1454, so cost to add change would not be beneficial, let miner have dust
  XCTAssertEqual([txData amount], paymentAmount);
  XCTAssertEqual([txData feeAmount], expectedFeeAmount);
  XCTAssertEqual([[txData unspentTransactionOutputs] count], [utxos count]);
  XCTAssertEqual([txData changeAmount], 0);
  XCTAssertNil([txData changePath]);

  // when again, with enough to satisfy change threshold
  paymentAmount = 194000;
  expectedFeeAmount = 2570;
  NSUInteger expectedChange = 3430;
  CNBTransactionData *goodTxData = [[CNBTransactionData alloc] initWithAddress:[self testAddress]
                                                                          coin:self.coin
                                                       fromAllAvailableOutputs:utxos
                                                                 paymentAmount:paymentAmount
                                                                       feeRate:feeRate
                                                                    changePath:changePath
                                                                   blockHeight:500000];

  // and then
  XCTAssertEqual([goodTxData amount], paymentAmount);
  XCTAssertEqual([goodTxData feeAmount], expectedFeeAmount);
  XCTAssertEqual([[goodTxData unspentTransactionOutputs] count], [utxos count]);
  XCTAssertEqual([goodTxData changeAmount], expectedChange);
  XCTAssertEqualObjects([goodTxData changePath], changePath);
}

// MARK: flat fee tests
- (void)testTransactionDataWithFlatFeeCalculatesUTXOsAndChangeProperly {
  // given
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
  NSArray *utxos = @[out1, out2, out3];
  CNBDerivationPath *changePath = [[CNBDerivationPath alloc] initWithPurpose:BIP49 coinType:MainNet account:0 change:1 index:5];
  NSUInteger paymentAmount = 20000;
  NSUInteger flatFeeAmount = 10000;
  NSUInteger expectedChange = 3682;

  // when
  CNBTransactionData *txData = [[CNBTransactionData alloc] initWithAddress:[self testAddress]
                                                                      coin:self.coin
                                                   fromAllAvailableOutputs:utxos
                                                             paymentAmount:paymentAmount
                                                                   flatFee:flatFeeAmount
                                                                changePath:changePath
                                                               blockHeight:500000];

  // then
  XCTAssertEqual([txData amount], paymentAmount);
  XCTAssertEqual([txData feeAmount], flatFeeAmount);
  XCTAssertEqual([txData changeAmount], expectedChange);
  XCTAssertNotNil([txData changePath]);
}

- (void)testDustyTransactionDataWithFlatFeeCalculatesUTXOsAndNoChangeProperly {
  // given
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
  NSArray *utxos = @[out1, out2];
  CNBDerivationPath *changePath = [[CNBDerivationPath alloc] initWithPurpose:BIP49 coinType:MainNet account:0 change:1 index:5];
  NSUInteger paymentAmount = 20000;
  NSUInteger expectedFeeAmount = 10000;

  // when
  CNBTransactionData *txData = [[CNBTransactionData alloc] initWithAddress:[self testAddress]
                                                                      coin:self.coin
                                                   fromAllAvailableOutputs:utxos
                                                             paymentAmount:paymentAmount
                                                                   flatFee:expectedFeeAmount
                                                                changePath:changePath
                                                               blockHeight:500000];

  // then
  XCTAssertEqual([txData amount], paymentAmount);
  XCTAssertEqual([txData feeAmount], expectedFeeAmount);
  XCTAssertEqual([txData changeAmount], 0);
  XCTAssertNil([txData changePath]);
}

// MARK: send max
- (void)testSendMaxUsesAllUTXOsAndAmountIsTotalValueMinusFee {
  // given
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
  bc::wallet::payment_address payment_address = [[self helper] paymentAddressFromString:[self testAddress]];
  NSUInteger totalBytes = [[self helper] totalBytesWithInputCount:[utxos count] paymentAddress:payment_address includeChangeAddress:NO];
  NSUInteger expectedFeeAmount = feeRate * totalBytes; // 1,125
  NSUInteger expectedAmount = inputAmount - expectedFeeAmount;

  // when
  CNBTransactionData *txData = [[CNBTransactionData alloc] initWithAllUsableOutputs:utxos
                                                                               coin:self.coin
                                                                sendingMaxToAddress:[self testAddress]
                                                                            feeRate:feeRate
                                                                        blockHeight:500000];

  // then
  XCTAssertEqual([txData amount], expectedAmount);
  XCTAssertEqual([txData feeAmount], expectedFeeAmount);
  XCTAssertEqual([txData changeAmount], 0);
  XCTAssertNil([txData changePath]);
}

- (void)testSendMaxWithInsufficientFundsReturnsNil {
  // given
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
                                                                               coin:self.coin
                                                                sendingMaxToAddress:[self testAddress]
                                                                            feeRate:feeRate
                                                                        blockHeight:500000];

  // then
  XCTAssertNil(txData);
}

- (void)testSendMaxWithJustEnoughFundsReturnsObject {
  // given
  NSUInteger feeRate = 5;
  CNBDerivationPath *path1 = [[CNBDerivationPath alloc] initWithPurpose:BIP49 coinType:MainNet account:0 change:1 index:3];
  CNBUnspentTransactionOutput *out1 = [[CNBUnspentTransactionOutput alloc] initWithId:@"909ac6e0a31c68fe345cc72d568bbab75afb5229b648753c486518f11c0d0009"
                                                                                index:1
                                                                               amount:670
                                                                       derivationPath:path1
                                                                          isConfirmed:YES];
  NSArray *utxos = @[out1];
  NSUInteger inputAmount = out1.amount;
  bc::wallet::payment_address payment_address = [[self helper] paymentAddressFromString:[self testAddress]];
  NSUInteger totalBytes = [[self helper] totalBytesWithInputCount:[utxos count] paymentAddress:payment_address includeChangeAddress:NO];
  NSUInteger expectedFeeAmount = feeRate * totalBytes; // 670
  NSUInteger expectedAmount = inputAmount - expectedFeeAmount;

  // when
  CNBTransactionData *txData = [[CNBTransactionData alloc] initWithAllUsableOutputs:utxos
                                                                               coin:self.coin
                                                                sendingMaxToAddress:[self testAddress]
                                                                            feeRate:feeRate
                                                                        blockHeight:500000];

  // then
  XCTAssertEqual([txData amount], expectedAmount);
  XCTAssertEqual([txData amount], 0);
  XCTAssertEqual([txData feeAmount], expectedFeeAmount);
  XCTAssertEqual([txData feeAmount], 670);
  XCTAssertEqual([txData changeAmount], 0);
  XCTAssertNil([txData changePath]);
}

@end
