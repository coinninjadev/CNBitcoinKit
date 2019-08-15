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

@property (nonatomic, retain) NSArray *words;
@property (nonatomic, retain) CNBBaseCoin *coin;

@end

@implementation TransactionBuilderMainnetTests

- (void)setUp {
  [super setUp];

  self.coin = [[CNBBaseCoin alloc] initWithPurpose:BIP49 coin:MainNet account:0];
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

  CNBTransactionData *data = [[CNBTransactionData alloc] initWithAddress:@"3BgxxADLtnoKu9oytQiiVzYUqvo8weCVy9"
                                                                    coin:self.coin
                                               unspentTransactionOutputs:utxos
                                                                  amount:amount
                                                               feeAmount:feesAmount
                                                            changeAmount:changeAmount
                                                              changePath:changePath
                                                             blockHeight:539943];

  NSString *expectedTransaction = @"01000000000101878fc7978e6b76b5b959e791320174997af9888c9861c6fd17dc3f99feda081a0100000017160014640a808191fc22f8eeb2f5628bd550e74b1acf5cffffffff02103500000000000017a9146daec6ddb6faaf01f83f515045822a94d0c2331e87804b2a000000000017a9145cb1adb4a2c5333e5eb6277552b4208a114326e68702483045022100c7b4ab9726292aa6534022be1d044a2f3fb7dac0140dab9405027c3f3556dc7e0220511e38f2708784631dea44f43c6daf2e9104a1924f7990718a505839ad4e24c8012102f2918e0270621ede0a39e5054e420b96b94ec51e75c4df2e8884fe57f4c8b2e0273d0800";

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

  CNBTransactionData *data = [[CNBTransactionData alloc] initWithAddress:@"3CkiUcj5vU4TGZJeDcrmYGWH8GYJ5vKcQq"
                                                                    coin:self.coin
                                               unspentTransactionOutputs:utxos
                                                                  amount:amount
                                                               feeAmount:feesAmount
                                                            changeAmount:changeAmount
                                                              changePath:changePath
                                                             blockHeight:540220];

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
                                                                    coin:self.coin
                                               unspentTransactionOutputs:utxos
                                                                  amount:amount
                                                               feeAmount:feesAmount
                                                            changeAmount:changeAmount
                                                              changePath:changePath
                                                             blockHeight:500000];

  NSString *expectedTransaction = @"01000000000101fa3ecda170cdb6d1b4c6a668e70428f6944691ff83294770b5fe0ea01ee38034010000001716001467e1283a55cc51f4fdb7540af3fbb3104639dc11ffffffff02105503000000000017a9148ba60342bf59f73327fecab2bef17c1612888c3587b98503000000000017a9145c7b481bedbfe029d605059a08e8f6b1caa2c8cf870247304402204d3985ff6329745d10bd91ca37c114f2e3206dcca0ac9563e186c9a9f4147d5702202988c2a3937a5131fbc6714935826ed6afd4970e2ea0490b4081dc7ac94ee2ee012103a1b571e7bcb067f24bd5cb6685a3dd85ca1993f3cc31044c41a58d2a89949a2f20a10700";

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
                                                                    coin:self.coin
                                               unspentTransactionOutputs:utxos
                                                                  amount:amount
                                                               feeAmount:feesAmount
                                                            changeAmount:0
                                                              changePath:changePath
                                                             blockHeight:500000];

  NSString *expectedTransaction = @"010000000001014e38dce64bc188318e2fe1fd5038c954b821b0828ca6a51a0c6ed26af71449f1010000001716001474467d2f21270193dcca9cf36bddf57db2d886a3ffffffff016b5a0000000000001976a914b4716e71b900b957e49f749c8432b910417788e888ac0247304402200649fded915506b55678b59904cc0582ec1893cd3bb20f67c98f4c5abf9079a702205af5d71118a8161c87efca725962f775a34bbe9461e771f9db236600eff88ba101210289923788a78703322eba5b7fc9bf607bcd19c291e9f6e085ae7c913d6ff56f7620a10700";

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
                                                                    coin:self.coin
                                               unspentTransactionOutputs:utxos
                                                                  amount:amount
                                                               feeAmount:feesAmount
                                                            changeAmount:changeAmount
                                                              changePath:changePath
                                                             blockHeight:541133];

  NSString *expectedTransaction = @"01000000000101c2fa1f3dfcc8d121f423885bfbb4579b1f1b653b7b7b86393aeddde154b58b9a010000001716001443ce1f475df701b3e26007578619054fadf75720ffffffff01be5202000000000017a9146282dd071fc766f3749136dd0fee99c4f3db17038702483045022100e9677d64c1a184aad45d7de7c0a28bc466773d0cde8bc9cec38321a5c5ecdb56022039afed6dc9ff1c4a2252d3dd8ee07f4f4b7e23048737336ab175a42c464751be0121033fde0485b998f456fa20a38ac73666f129fe07192d7b56246b7074c8c0204840cd410800";

  CNBTransactionBuilder *builder = [[CNBTransactionBuilder alloc] init];

  NSString *actualEncodedTransaction = [[builder generateTxMetadataWithTransactionData:data wallet:wallet] encodedTx];

  XCTAssertEqualObjects(actualEncodedTransaction, expectedTransaction);
}

- (void)testTestNetMetadataCreation {
  NSArray *newWords = [GeneratedWordsHelper words1];
  MockBitcoinCoin *coin = [[MockBitcoinCoin alloc] initWithPurpose:BIP49 coin:TestNet account:0];
  CNBHDWallet *wallet = [[CNBHDWallet alloc] initWithMnemonic:newWords coin:coin];
  CNBDerivationPath *path = [[CNBDerivationPath alloc] initWithPurpose:BIP49 coinType:TestNet account:0 change:0 index:0];
  CNBUnspentTransactionOutput *utxo = [[CNBUnspentTransactionOutput alloc] initWithId:@"1cfd000efbe248c48b499b0a5d76ea7687ee76cad8481f71277ee283df32af26" index:0 amount:1250000000 derivationPath:path isConfirmed:YES];

  NSArray<CNBUnspentTransactionOutput *> *utxos = @[utxo];
  NSUInteger amount = 9523810;
  NSUInteger feesAmount = 830;
  NSUInteger changeAmount = 1240475360;
  CNBDerivationPath *changePath = [[CNBDerivationPath alloc] initWithPurpose:BIP49 coinType:TestNet account:0 change:1 index:0]; //Hardcoded for now

  CNBTransactionData *data = [[CNBTransactionData alloc] initWithAddress:@"2N8o4Mu5PRAR27TC2eai62CRXarTbQmjyCx"
                                                                    coin:coin
                                                 fromAllAvailableOutputs:utxos
                                                           paymentAmount:amount
                                                                 flatFee:feesAmount
                                                              changePath:changePath
                                                             blockHeight:644];

  CNBTransactionBuilder *builder = [[CNBTransactionBuilder alloc] init];
  CNBTransactionMetadata *metadata = [builder generateTxMetadataWithTransactionData:data wallet:wallet];
  XCTAssertNotNil([metadata changeAddress]);
  XCTAssertNotNil([metadata voutIndex]);
}

- (void)testSendToNaviteSegwitBuildProperly {
  NSArray *words = @[@"abandon", @"abandon", @"abandon", @"abandon", @"abandon", @"abandon", @"abandon", @"abandon", @"abandon", @"abandon", @"abandon", @"about"];
  MockBitcoinCoin *coin = [[MockBitcoinCoin alloc] initWithPurpose:BIP49 coin:MainNet account:0];
  CNBHDWallet *wallet = [[CNBHDWallet alloc] initWithMnemonic:words coin:coin];
  CNBDerivationPath *path = [[CNBDerivationPath alloc] initWithPurpose:BIP49 coinType:MainNet account:0 change:0 index:80];
  CNBUnspentTransactionOutput *utxo = [[CNBUnspentTransactionOutput alloc] initWithId:@"94b5bcfbd52a405b291d906e636c8e133407e68a75b0a1ccc492e131ff5d8f90" index: 0 amount:10261 derivationPath:path isConfirmed:YES];
  NSArray *utxos = @[utxo];
  NSUInteger amount = 5000;
  NSUInteger feeAmount = 1000;
  NSUInteger changeAmount = 4261;
  CNBDerivationPath *changePath = [[CNBDerivationPath alloc] initWithPurpose:BIP49 coinType:MainNet account:0 change:1 index:102];
  NSString *toAddress = @"bc1ql2sdag2nm9csz4wmlj735jxw88ym3yukyzmrpj";

  CNBTransactionData *data = [[CNBTransactionData alloc] initWithAddress:toAddress
                                                                    coin:coin
                                               unspentTransactionOutputs:utxos
                                                                  amount:amount
                                                               feeAmount:feeAmount
                                                            changeAmount:changeAmount
                                                              changePath:changePath
                                                             blockHeight:500000];

  CNBTransactionBuilder *builder = [[CNBTransactionBuilder alloc] init];
  CNBTransactionMetadata *metadata = [builder generateTxMetadataWithTransactionData:data wallet:wallet];

  NSString *expectedEncodedTx = @"01000000000101908f5dff31e192c4cca1b0758ae60734138e6c636e901d295b402ad5fbbcb594000000001716001442288ee31111f7187e8cfe8c82917c4734da4c2effffffff028813000000000000160014faa0dea153d9710155dbfcbd1a48ce39c9b89396a51000000000000017a914aa71651e8f7c618a4576873254ec80c4dfaa068b8702483045022100fc142e1aa34627b880363427e07fc8de82542eba5593030160fbc33d22101c4302207478c3407a15daf613f458eb32223fb6d89a62b93b1a701c404a1a2f3977aee701210270d4003d27b5340df1895ef3a5aee2ae2fe3ed7383c01ba623723e702b6c83c120a10700";
  NSString *expectedTxid = @"ff3033d6f7029ec366a9fe146d9941dddaa6edb3cd6543a6d285f84c5d4d22c3";
  NSString *expectedChangeAddress = @"3HEEdyeVwoGZf86jq8ovUhw9FiXkwCdY79";

  NSString *encodedTx = [metadata encodedTx];
  NSString *txid = [metadata txid];
  NSString *changeAddresss = [metadata changeAddress];

  XCTAssertEqualObjects(encodedTx, expectedEncodedTx);
  XCTAssertEqualObjects(txid, expectedTxid);
  XCTAssertEqualObjects(changeAddresss, expectedChangeAddress);
}

@end
