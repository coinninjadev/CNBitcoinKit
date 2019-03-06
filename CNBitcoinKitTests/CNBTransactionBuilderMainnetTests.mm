//
//  TransactionBuilderMainnetTests.m
//  CNBitcoinKitTests
//
//  Created by Mitchell on 5/15/18.
//  Copyright © 2018 Coin Ninja, LLC. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "CNBitcoinKit.h"
#import "MockBitcoinCoin.h"
#import "CNBDerivationPath.h"
#import "CNBTransactionData.h"
#import "CNBTransactionData+Project.h"
#import "CNBUnspentTransactionOutput.h"
#import "CNBTransactionBuilder.h"
#import "GeneratedWordsHelper.h"

@interface CNBTransactionBuilder (Testing)

- (NSString *)generateEncodedStringWithTransactionData:(CNBTransactionData *)data wallet:(CNBHDWallet *)wallet;

@end

@interface TransactionBuilderMainnetTests : XCTestCase

@property NSArray *words;

@end

@implementation TransactionBuilderMainnetTests

- (void)setUp {
  [super setUp];

  self.words = [GeneratedWordsHelper words2];
}

- (void)tearDown {
  [super tearDown];
}

- (void)testCorrectTransactionGetsBuilt {
  NSArray *newWords = [GeneratedWordsHelper words1];
  MockBitcoinCoin *coin = [[MockBitcoinCoin alloc] initWithPurpose:BIP49 coin:MainNet account:0 networkURL:@""];
  CNBHDWallet *wallet = [[CNBHDWallet alloc] initWithMnemonic:newWords coin:coin];
  CNBDerivationPath *path = [[CNBDerivationPath alloc] initWithPurpose:BIP49 coinType:MainNet account:0 change:1 index:53];
  CNBUnspentTransactionOutput *utxo = [[CNBUnspentTransactionOutput alloc] initWithId:@"1a08dafe993fdc17fdc661988c88f97a9974013291e759b9b5766b8e97c78f87" index:1 amount:2788424 derivationPath:path isConfirmed:YES];

  NSArray<CNBUnspentTransactionOutput *> *utxos = @[utxo];
  NSUInteger amount = 13584;
  NSUInteger feesAmount = 3000;
  NSUInteger changeAmount = 2771840;
  CNBDerivationPath *changePath = [[CNBDerivationPath alloc] initWithPurpose:BIP49 coinType:MainNet account:0 change:1 index:56]; //Hardcoded for now

  CNBTransactionData *data = [[CNBTransactionData alloc] initWithAddress:@"3BgxxADLtnoKu9oytQiiVzYUqvo8weCVy9" unspentTransactionOutputs:utxos amount:amount feeAmount:feesAmount changeAmount:changeAmount changePath:changePath blockHeight:539943];

  NSString *expectedTransaction = @"01000000000101878fc7978e6b76b5b959e791320174997af9888c9861c6fd17dc3f99feda081a0100000017160014640a808191fc22f8eeb2f5628bd550e74b1acf5cfeffffff02103500000000000017a9146daec6ddb6faaf01f83f515045822a94d0c2331e87804b2a000000000017a9145cb1adb4a2c5333e5eb6277552b4208a114326e68702483045022100f95c602fb4f7e13216ad6111abf67d240dd6c9d8598051614799fca69de0df9b022038abddb59599dc15687c5cc325e5ff77b7b927c08290352c40d36288a70967b5012102f2918e0270621ede0a39e5054e420b96b94ec51e75c4df2e8884fe57f4c8b2e0273d0800";

  CNBTransactionBuilder *builder = [[CNBTransactionBuilder alloc] init];

  NSString *actualEncodedTransaction = [[builder generateTxMetadataWithTransactionData:data wallet:wallet] encodedTx];

  XCTAssertEqualObjects(actualEncodedTransaction, expectedTransaction);
}

- (void)testCorrectTransactionGetsBuiltWithTwoInputs {
  NSArray *newWords = [GeneratedWordsHelper words1];
  MockBitcoinCoin *coin = [[MockBitcoinCoin alloc] initWithPurpose:BIP49 coin:MainNet account:0 networkURL:@""];
  CNBHDWallet *wallet = [[CNBHDWallet alloc] initWithMnemonic:newWords coin:coin];
  CNBDerivationPath *path1 = [[CNBDerivationPath alloc] initWithPurpose:BIP49 coinType:MainNet account:0 change:1 index:56];
  CNBUnspentTransactionOutput *utxo1 = [[CNBUnspentTransactionOutput alloc] initWithId:@"24cc9150963a2369d7f413af8b18c3d0243b438ba742d6d083ec8ed492d312f9" index:1 amount:2769977 derivationPath:path1 isConfirmed:NO];
  CNBDerivationPath *path2 = [[CNBDerivationPath alloc] initWithPurpose:BIP49 coinType:MainNet account:0 change:1 index:57];
  CNBUnspentTransactionOutput *utxo2 = [[CNBUnspentTransactionOutput alloc] initWithId:@"ed611c20fc9088aa5ec1c86de88dd017965358c150c58f71eda721cdb2ac0a48" index:1 amount:314605 derivationPath:path2 isConfirmed:NO];

  NSArray<CNBUnspentTransactionOutput *> *utxos = @[utxo1, utxo2];
  NSUInteger amount = 3000000;
  NSUInteger feesAmount = 4000;
  NSUInteger changeAmount = 80582;
  CNBDerivationPath *changePath = [[CNBDerivationPath alloc] initWithPurpose:BIP49 coinType:MainNet account:0 change:1 index:58]; //Hardcoded for now

  CNBTransactionData *data = [[CNBTransactionData alloc] initWithAddress:@"3CkiUcj5vU4TGZJeDcrmYGWH8GYJ5vKcQq" unspentTransactionOutputs:utxos amount:amount feeAmount:feesAmount changeAmount:changeAmount changePath:changePath blockHeight:540220];

  NSString *expectedTransaction = @"01000000000102f912d392d48eec83d0d642a78b433b24d0c3188baf13f4d769233a965091cc240100000017160014caaf023740cfef2ada9f1790c759bf538a049ef2fdffffff480aacb2cd21a7ed718fc550c158539617d08de86dc8c15eaa8890fc201c61ed010000001716001420e182808e2967d758ed0540e66a55a771cfbaf9fdffffff02c0c62d000000000017a914795c7bc23aebac7ddea222bb13c5357b32ed0cd487c63a01000000000017a9142679d6827ab2f8e711e74f9d51478f86d0b39f9b87024730440220754feb454885f8a3c2b7e9187561430865c6b7f4c66dd92359c134e6265d01a302207aa9fa044c5308ef884ac634d82c816ec4cfec56b3462f5689ca2ff71ff1dc61012102fece2f4f601a120a3a5259682b944fab1015103b93e9605f96a64f9f4077755f02473044022070aaa61c4fae5afbcbfc5ea954399cdf529254a7045406ec89e0729f357f43d5022020106a6092b82e9ca77ce3ea8ac7a336028e0fbfe6957028efafcd6820eff6570121028f130ffb3d33a819af818ae091a9fc50316efd3fdc8c3d594c4339f5ee40eac33c3e0800";

  CNBTransactionBuilder *builder = [[CNBTransactionBuilder alloc] init];

  NSString *actualEncodedTransaction = [[builder generateTxMetadataWithTransactionData:data wallet:wallet] encodedTx];

  XCTAssertEqualObjects(actualEncodedTransaction, expectedTransaction);
}

- (void)testBuildSingleUtxoMainnet {
  MockBitcoinCoin *coin = [[MockBitcoinCoin alloc] initWithPurpose:BIP49 coin:MainNet account:0 networkURL:@""];
  CNBHDWallet *wallet = [[CNBHDWallet alloc] initWithMnemonic:self.words coin:coin];
  CNBDerivationPath *path = [[CNBDerivationPath alloc] initWithPurpose:BIP49 coinType:MainNet account:0 change:0 index:0];
  CNBUnspentTransactionOutput *utxo = [[CNBUnspentTransactionOutput alloc] initWithId:@"3480e31ea00efeb570472983ff914694f62804e768a6c6b4d1b6cd70a1cd3efa" index:1 amount:449893 derivationPath:path isConfirmed:YES];

  NSArray<CNBUnspentTransactionOutput *> *utxos = @[utxo];
  NSUInteger amount = 218384;
  NSUInteger feesAmount = 668;
  NSUInteger changeAmount = 230841;
  CNBDerivationPath *changePath = [[CNBDerivationPath alloc] initWithPurpose:BIP49 coinType:MainNet account:0 change:1 index:0]; //Hardcoded for now

  CNBTransactionData *data = [[CNBTransactionData alloc] initWithAddress:@"3ERQiyXSeUYmxxqKyg8XwqGo4W7utgDrTR"
                                               unspentTransactionOutputs:utxos
                                                                  amount:amount
                                                               feeAmount:feesAmount
                                                            changeAmount:changeAmount
                                                              changePath:changePath
                                                             blockHeight:500000];

  NSString *expectedTransaction = @"01000000000101fa3ecda170cdb6d1b4c6a668e70428f6944691ff83294770b5fe0ea01ee38034010000001716001467e1283a55cc51f4fdb7540af3fbb3104639dc11feffffff02105503000000000017a9148ba60342bf59f73327fecab2bef17c1612888c3587b98503000000000017a9145c7b481bedbfe029d605059a08e8f6b1caa2c8cf8702483045022100f874361e847737b7c92533bad8ded3c135ba2d8fe1face6d5490eadc9e311cb20220700b22b5a17c65c54b29ab41703670ef1da6e7d91f10ee2ead712434db29381d012103a1b571e7bcb067f24bd5cb6685a3dd85ca1993f3cc31044c41a58d2a89949a2f20a10700";

  CNBTransactionBuilder *builder = [[CNBTransactionBuilder alloc] init];

  NSString *actualEncodedTransaction = [[builder generateTxMetadataWithTransactionData:data wallet:wallet] encodedTx];

  XCTAssertEqualObjects(actualEncodedTransaction, expectedTransaction);
}

- (void)testBuildPayToPublicKeyHashNoChangeMainNet {
  MockBitcoinCoin *coin = [[MockBitcoinCoin alloc] initWithPurpose:BIP49 coin:MainNet account:0 networkURL:@""];
  CNBHDWallet *wallet = [[CNBHDWallet alloc] initWithMnemonic:self.words coin:coin];
  CNBDerivationPath *path = [[CNBDerivationPath alloc] initWithPurpose:BIP49 coinType:MainNet account:0 change:1 index:7];
  CNBUnspentTransactionOutput *utxo = [[CNBUnspentTransactionOutput alloc] initWithId:@"f14914f76ad26e0c1aa5a68c82b021b854c93850fde12f8e3188c14be6dc384e" index:1 amount:33253 derivationPath:path isConfirmed:YES];

  NSArray<CNBUnspentTransactionOutput *> *utxos = @[utxo];
  NSUInteger amount = 23147;
  NSUInteger feesAmount = 10108;
  CNBDerivationPath *changePath = [[CNBDerivationPath alloc] initWithPurpose:BIP49 coinType:MainNet account:0 change:1 index:2]; //Hardcoded for now

  CNBTransactionData *data = [[CNBTransactionData alloc] initWithAddress:@"1HT6WtD5CAToc8wZdacCgY4XjJR4jV5Q5d"
                                               unspentTransactionOutputs:utxos
                                                                  amount:amount
                                                               feeAmount:feesAmount
                                                            changeAmount:0
                                                              changePath:changePath
                                                             blockHeight:500000];

  NSString *expectedTransaction = @"010000000001014e38dce64bc188318e2fe1fd5038c954b821b0828ca6a51a0c6ed26af71449f1010000001716001474467d2f21270193dcca9cf36bddf57db2d886a3feffffff016b5a0000000000001976a914b4716e71b900b957e49f749c8432b910417788e888ac0247304402204ea29f2f1b901fda657904932771ca68bcb14626b599810af4f1e01d495b5dff02200716d1dc1e7312691931a8d406c24ffc472c60342dfdf6d3ed4e43f8748a497401210289923788a78703322eba5b7fc9bf607bcd19c291e9f6e085ae7c913d6ff56f7620a10700";

  CNBTransactionBuilder *builder = [[CNBTransactionBuilder alloc] init];

  NSString *actualEncodedTransaction = [[builder generateTxMetadataWithTransactionData:data wallet:wallet] encodedTx];

  XCTAssertEqualObjects(actualEncodedTransaction, expectedTransaction);
}

- (void)testBuildSingleUtxoNoChangeMainnet {
  NSArray *newWords = [GeneratedWordsHelper words3];
  MockBitcoinCoin *coin = [[MockBitcoinCoin alloc] initWithPurpose:BIP49 coin:MainNet account:0 networkURL:@""];
  CNBHDWallet *wallet = [[CNBHDWallet alloc] initWithMnemonic:newWords coin:coin];
  CNBDerivationPath *path = [[CNBDerivationPath alloc] initWithPurpose:BIP49 coinType:MainNet account:0 change:0 index:0];
  CNBUnspentTransactionOutput *utxo = [[CNBUnspentTransactionOutput alloc] initWithId:@"9a8bb554e1dded3a39867b7b3b651b1f9b57b4fb5b8823f421d1c8fc3d1ffac2" index:1 amount:154254 derivationPath:path isConfirmed:YES];

  NSArray<CNBUnspentTransactionOutput *> *utxos = @[utxo];
  NSUInteger amount = 152254;
  NSUInteger feesAmount = 2000;
  NSUInteger changeAmount = 0;
  CNBDerivationPath *changePath = [[CNBDerivationPath alloc] initWithPurpose:BIP49 coinType:MainNet account:0 change:1 index:0]; //Hardcoded for now

  CNBTransactionData *data = [[CNBTransactionData alloc] initWithAddress:@"3Aftutd9VvzLcGxD9VraNhWiHyjR5pvn5N"
                                               unspentTransactionOutputs:utxos
                                                                  amount:amount
                                                               feeAmount:feesAmount
                                                            changeAmount:changeAmount
                                                              changePath:changePath
                                                             blockHeight:541133];

  NSString *expectedTransaction = @"01000000000101c2fa1f3dfcc8d121f423885bfbb4579b1f1b653b7b7b86393aeddde154b58b9a010000001716001443ce1f475df701b3e26007578619054fadf75720feffffff01be5202000000000017a9146282dd071fc766f3749136dd0fee99c4f3db170387024730440220690a1814e27c8f21f337f440e9dbb972bca8434d7834e16ebeeae3cc814bf4ef022019e4172b00c7a664b7dfb3ae827bafcc9b23e714bb2b7ac69133eb1b4d322e9f0121033fde0485b998f456fa20a38ac73666f129fe07192d7b56246b7074c8c0204840cd410800";

  CNBTransactionBuilder *builder = [[CNBTransactionBuilder alloc] init];

  NSString *actualEncodedTransaction = [[builder generateTxMetadataWithTransactionData:data wallet:wallet] encodedTx];

  XCTAssertEqualObjects(actualEncodedTransaction, expectedTransaction);
}

@end
