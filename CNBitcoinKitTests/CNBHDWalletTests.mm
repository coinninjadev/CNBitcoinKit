//
//  CNBHDWalletTests.mm
//  CNBHDWalletTests
//
//  Created by BJ Miller on 1/20/18.
//  Copyright © 2018 Coin Ninja, LLC. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "CNBitcoinKit.h"
#import "MockBitcoinCoin.h"
#import "NSData+CNBitcoinKit.h"
#import "CNBAddressResult.h"
#import "CNBBaseCoin.h"
#import "CNBTransactionData.h"
#import "CNBTransactionData+Project.h"
#import "NSString+NSData.h"
#import "CNBCipherKeys.h"
#import "CNBEncryptionCipherKeys.h"
#import "GeneratedWordsHelper.h"

@interface CNBHDWalletTests : XCTestCase

@property NSArray *words;
@property CNBBaseCoin *tempCoin;

@end

@implementation CNBHDWalletTests

- (void)setUp {
	[super setUp];

  self.words = [GeneratedWordsHelper words4];
  self.tempCoin = [[CNBBaseCoin alloc] initWithPurpose:BIP49 coin:MainNet account:0];
}

- (void)tearDown {
	[super tearDown];
}

- (void)testHDWalletIsNotNil {
	CNBHDWallet *wallet = [[CNBHDWallet alloc] init];
	XCTAssertNotNil(wallet);
}

- (void)testWalletReturnsMnemonicWords {
	CNBHDWallet *wallet = [[CNBHDWallet alloc] init];
	NSArray *words = [wallet mnemonicWords];
	XCTAssertEqual(words.count, 12);
}

- (void)testAllWords {
  NSArray *words = [CNBHDWallet allWords];
  XCTAssertEqual(words.count, 2048);

  NSSet *uniqueWords = [[NSSet alloc] initWithArray:words];
  XCTAssertEqual([uniqueWords count], [words count], "all words should be unique");
}

- (void)testReceiveAddressesAreGeneratedCorrectly {
	MockBitcoinCoin *coin = [[MockBitcoinCoin alloc] initWithPurpose:BIP49 coin:MainNet account:0 networkURL:@""];
	CNBHDWallet *wallet = [[CNBHDWallet alloc] initWithMnemonic:self.words coin:coin];

	XCTAssertEqualObjects([[wallet receiveAddressForIndex:0] address], @"35dKN7xvHH3xnBWUrWzJtkjfrAFXk6hyH8");
	XCTAssertEqualObjects([[wallet receiveAddressForIndex:1] address], @"39v5KMcxSjRQ2Ub9nMm92Nacg6FVzxVdRv");
	XCTAssertEqualObjects([[wallet receiveAddressForIndex:2] address], @"35zUEPEzmEWuNXWu62NcNS2JQGSuMqrmpr");

  NSString *expectedPath0 = @"m/49'/0'/0'/0/0";
  NSString *expectedPath1 = @"m/49'/0'/0'/0/1";
  NSString *expectedPath2 = @"m/49'/0'/0'/0/2";
  XCTAssertEqualObjects([[[wallet receiveAddressForIndex:0] derivationPath] description], expectedPath0);
  XCTAssertEqualObjects([[[wallet receiveAddressForIndex:1] derivationPath] description], expectedPath1);
  XCTAssertEqualObjects([[[wallet receiveAddressForIndex:2] derivationPath] description], expectedPath2);
}

- (void)testChangeAddressesAreGeneratedCorrectly {
	MockBitcoinCoin *coin = [[MockBitcoinCoin alloc] initWithPurpose:BIP49 coin:MainNet account:0 networkURL:@""];
	CNBHDWallet *wallet = [[CNBHDWallet alloc] initWithMnemonic:self.words coin:coin];

	XCTAssertEqualObjects([[wallet changeAddressForIndex:0] address], @"3Ab7CADa9pzZKBx17q82S4cAakoEEW4qya");
	XCTAssertEqualObjects([[wallet changeAddressForIndex:1] address], @"3GJP6WziAzpxH3ksPi6SaWJZNPMaNt3eQn");
	XCTAssertEqualObjects([[wallet changeAddressForIndex:2] address], @"3CxEPyTdkEjgJDbRSjrqeGKtRtXjYnpBzP");

  NSString *expectedPath0 = @"m/49'/0'/0'/1/0";
  NSString *expectedPath1 = @"m/49'/0'/0'/1/1";
  NSString *expectedPath2 = @"m/49'/0'/0'/1/2";
  XCTAssertEqualObjects([[[wallet changeAddressForIndex:0] derivationPath] description], expectedPath0);
  XCTAssertEqualObjects([[[wallet changeAddressForIndex:1] derivationPath] description], expectedPath1);
  XCTAssertEqualObjects([[[wallet changeAddressForIndex:2] derivationPath] description], expectedPath2);
}

- (void)testTestnetReceiveAddressesAreGeneratedCorrectly {
	MockBitcoinCoin *coin = [[MockBitcoinCoin alloc] initWithPurpose:BIP49 coin:TestNet account:0 networkURL:@""];
	CNBHDWallet *wallet = [[CNBHDWallet alloc] initWithMnemonic:self.words coin:coin];

	XCTAssertEqualObjects([[wallet receiveAddressForIndex:0] address], @"2NAX969W3VPpjQqhQZsrU8WtR23ojMfzYpV");
	XCTAssertEqualObjects([[wallet receiveAddressForIndex:1] address], @"2N4QkJoFhbzy4JAg7H3LdegxF5ADSChAQEb");
	XCTAssertEqualObjects([[wallet receiveAddressForIndex:2] address], @"2N1ipKwRBczxmnLEsYTdXmF1EY5YtEgnDhv");

  NSString *expectedPath0 = @"m/49'/1'/0'/0/0";
  NSString *expectedPath1 = @"m/49'/1'/0'/0/1";
  NSString *expectedPath2 = @"m/49'/1'/0'/0/2";
  XCTAssertEqualObjects([[[wallet receiveAddressForIndex:0] derivationPath] description], expectedPath0);
  XCTAssertEqualObjects([[[wallet receiveAddressForIndex:1] derivationPath] description], expectedPath1);
  XCTAssertEqualObjects([[[wallet receiveAddressForIndex:2] derivationPath] description], expectedPath2);
}

- (void)testTestnetChangeAddressesAreGeneratedCorrectly {
	MockBitcoinCoin *coin = [[MockBitcoinCoin alloc] initWithPurpose:BIP49 coin:TestNet account:0 networkURL:@""];
	CNBHDWallet *wallet = [[CNBHDWallet alloc] initWithMnemonic:self.words coin:coin];

	XCTAssertEqualObjects([[wallet changeAddressForIndex:0] address], @"2Mt5ENwbv75BZ9nNJKj6XzBqGFbpfCnpWb8");
	XCTAssertEqualObjects([[wallet changeAddressForIndex:1] address], @"2NGWcoMrwLywaCCnFyzbXDZ7NkEUzmHAqK7");
	XCTAssertEqualObjects([[wallet changeAddressForIndex:2] address], @"2Mtx6rqTXyZxNS2Dkhq8Jp6J3K7r4hB6hQP");

  NSString *expectedPath0 = @"m/49'/1'/0'/1/0";
  NSString *expectedPath1 = @"m/49'/1'/0'/1/1";
  NSString *expectedPath2 = @"m/49'/1'/0'/1/2";
  XCTAssertEqualObjects([[[wallet changeAddressForIndex:0] derivationPath] description], expectedPath0);
  XCTAssertEqualObjects([[[wallet changeAddressForIndex:1] derivationPath] description], expectedPath1);
  XCTAssertEqualObjects([[[wallet changeAddressForIndex:2] derivationPath] description], expectedPath2);
}

- (void)testPublicKeyHexString {
	CNBHDWallet *wallet = [[CNBHDWallet alloc] initWithMnemonic:self.words coin:self.tempCoin];

	NSString *pubKey = wallet.coinNinjaVerificationKeyHexString;
	XCTAssertTrue([pubKey isEqualToString:@"02bfce58afc49224fdd4a5fc369421b4ba45dfe5ab6bcd3b7286ccff50b52a7910"]);
}

- (void)testSigning {
	CNBHDWallet *wallet = [[CNBHDWallet alloc] initWithMnemonic:self.words coin:self.tempCoin];

	NSData *data = [@"Hello World" dataUsingEncoding:NSUTF8StringEncoding];
	NSData *signature = [wallet signData:data];
    NSString *signatureString = [signature hexString];
    XCTAssertTrue([signatureString isEqualToString:@"304402204562136060d2eba85a48692c4f8fc06f6775d5a20bb3a6986c313baaaa45227302207b86380fafda917e95a2fa0e5ba3cf1365e3bed0c1a970808dadbcf8f65ea176"]);

    XCTAssertTrue([wallet verifySignedData:data signature:signature]);
    XCTAssertFalse([wallet verifySignedData:[@"olleH dlroW" dataUsingEncoding:NSUTF8StringEncoding] signature:signature]);
}

// MARK: check for receive address up to index
- (void)testValidReceiveAddressWithinRangeReturnsTrue {
  CNBBaseCoin *coin = [[CNBBaseCoin alloc] initWithPurpose:BIP49 coin:MainNet account:0];
  NSString *validAddress = @"35dKN7xvHH3xnBWUrWzJtkjfrAFXk6hyH8";  // 0th index
  CNBHDWallet *wallet = [[CNBHDWallet alloc] initWithMnemonic:self.words coin:coin];

  CNBAddressResult *result = [wallet checkForAddress:validAddress upToIndex:10];

  XCTAssertEqualObjects([result address], validAddress, @"should have found valid address");
  XCTAssertTrue([result isReceiveAddress], @"should be a receive address");
}

- (void)testValidReceiveAddressOutsideRangeReturnsFalse {
  NSString *validAddress = @"34ZWxddBarGDrngPgSpEe8n7Zv8snf5M7G";  // 11th index
  CNBHDWallet *wallet = [[CNBHDWallet alloc] initWithMnemonic:self.words coin:self.tempCoin];

  CNBAddressResult *result = [wallet checkForAddress:validAddress upToIndex:10];

  XCTAssertNil(result, @"should not have found valid address");
}

- (void)testInvalidReceiveAddressReturnsNil {
  NSString *validAddress = @"bad address";
  CNBHDWallet *wallet = [[CNBHDWallet alloc] initWithMnemonic:self.words coin:self.tempCoin];

  CNBAddressResult *result = [wallet checkForAddress:validAddress upToIndex:10];

  XCTAssertNil(result, @"should not have found valid address");
}

// MARK: check for change address up to index
- (void)testValidChangeAddressWithinRangeReturnsTrue {
  CNBBaseCoin *coin = [[CNBBaseCoin alloc] initWithPurpose:BIP49 coin:MainNet account:0];
  NSString *validAddress = @"3Ab7CADa9pzZKBx17q82S4cAakoEEW4qya";  // 0th index
  CNBHDWallet *wallet = [[CNBHDWallet alloc] initWithMnemonic:self.words coin:coin];

  CNBAddressResult *result = [wallet checkForAddress:validAddress upToIndex:10];

  XCTAssertEqualObjects([result address], validAddress, @"should have found valid address");
  XCTAssertFalse([result isReceiveAddress], @"should not be a receive address");
}

- (void)testValidChangeAddressOutsideRangeReturnsFalse {
  NSString *validAddress = @"3BRw7C58scBnpTeKFjfxYXjWjoEMmkSLPd";  // 11th index
  CNBHDWallet *wallet = [[CNBHDWallet alloc] initWithMnemonic:self.words coin:self.tempCoin];

  CNBAddressResult *result = [wallet checkForAddress:validAddress upToIndex:10];

  XCTAssertNil(result, @"should not have found valid address");
}

// MARK: transaction metadata tests
- (void)testChangeAddressAndIndexAreReturned {
  CNBHDWallet *wallet = [self walletForTestingMetadata];
  CNBDerivationPath *path = [[CNBDerivationPath alloc] initWithPurpose:BIP49 coinType:MainNet account:0 change:1 index:53];
  CNBUnspentTransactionOutput *utxo = [[CNBUnspentTransactionOutput alloc] initWithId:@"1a08dafe993fdc17fdc661988c88f97a9974013291e759b9b5766b8e97c78f87" index:1 amount:2788424 derivationPath:path isConfirmed:YES];

  NSArray<CNBUnspentTransactionOutput *> *utxos = @[utxo];
  NSUInteger amount = 13584;
  NSUInteger feesAmount = 3000;
  NSUInteger changeAmount = 2771840;
  CNBDerivationPath *changePath = [[CNBDerivationPath alloc] initWithPurpose:BIP49 coinType:MainNet account:0 change:1 index:56]; //Hardcoded for now

  CNBTransactionData *data = [[CNBTransactionData alloc] initWithAddress:@"3BgxxADLtnoKu9oytQiiVzYUqvo8weCVy9"
                                                                    coin:self.tempCoin
                                               unspentTransactionOutputs:utxos
                                                                  amount:amount
                                                               feeAmount:feesAmount
                                                            changeAmount:changeAmount
                                                              changePath:changePath
                                                             blockHeight:539943];

  CNBTransactionBuilder *builder = [[CNBTransactionBuilder alloc] init];
  CNBTransactionMetadata *metadata = [builder generateTxMetadataWithTransactionData:data wallet:wallet];

  XCTAssertEqualObjects([metadata txid], @"58384bdb193a57b0766cfb24865860806cb4b0b75cc0a19d276b695b7ee7e230");
  XCTAssertEqualObjects([metadata encodedTx], @"01000000000101878fc7978e6b76b5b959e791320174997af9888c9861c6fd17dc3f99feda081a0100000017160014640a808191fc22f8eeb2f5628bd550e74b1acf5cffffffff02103500000000000017a9146daec6ddb6faaf01f83f515045822a94d0c2331e87804b2a000000000017a9145cb1adb4a2c5333e5eb6277552b4208a114326e68702483045022100c7b4ab9726292aa6534022be1d044a2f3fb7dac0140dab9405027c3f3556dc7e0220511e38f2708784631dea44f43c6daf2e9104a1924f7990718a505839ad4e24c8012102f2918e0270621ede0a39e5054e420b96b94ec51e75c4df2e8884fe57f4c8b2e0273d0800");
  XCTAssertEqual([[metadata voutIndex] integerValue], 1);
  XCTAssertEqualObjects([metadata changeAddress], @"3A98wWjDyJECXTCKJSiXgTZ5hrvRTdHsmg");
  XCTAssertEqual([[metadata changePath] change], [changePath change]);
  XCTAssertEqual([[metadata changePath] index], [changePath index]);
}

- (void)testNoChangeInTransactionReturnsNilForChangeAndIndex {
  CNBHDWallet *wallet = [self walletForTestingMetadata];
  CNBDerivationPath *path = [[CNBDerivationPath alloc] initWithPurpose:BIP49 coinType:MainNet account:0 change:1 index:53];
  CNBUnspentTransactionOutput *utxo = [[CNBUnspentTransactionOutput alloc] initWithId:@"1a08dafe993fdc17fdc661988c88f97a9974013291e759b9b5766b8e97c78f87" index:1 amount:2788424 derivationPath:path isConfirmed:YES];

  NSArray<CNBUnspentTransactionOutput *> *utxos = @[utxo];
  NSUInteger amount = 2785424;
  NSUInteger feesAmount = 3000;
  NSUInteger changeAmount = 0;

  CNBTransactionData *data = [[CNBTransactionData alloc] initWithAddress:@"3BgxxADLtnoKu9oytQiiVzYUqvo8weCVy9"
                                                                    coin:self.tempCoin
                                               unspentTransactionOutputs:utxos
                                                                  amount:amount
                                                               feeAmount:feesAmount
                                                            changeAmount:changeAmount
                                                              changePath:nil
                                                             blockHeight:539943];

  CNBTransactionBuilder *builder = [[CNBTransactionBuilder alloc] init];
  CNBTransactionMetadata *metadata = [builder generateTxMetadataWithTransactionData:data wallet:wallet];

  XCTAssertEqualObjects([metadata txid], @"d6c666e88ede980ca4c53423187723fd39197f6f39f4d4b0e37739b1a846988a");
  XCTAssertEqualObjects([metadata encodedTx], @"01000000000101878fc7978e6b76b5b959e791320174997af9888c9861c6fd17dc3f99feda081a0100000017160014640a808191fc22f8eeb2f5628bd550e74b1acf5cffffffff0190802a000000000017a9146daec6ddb6faaf01f83f515045822a94d0c2331e870247304402206f96276bb11748e380e53857f26afbd9ddca4fe8b691d701d6cd22eb80f06b95022040b4b8c714715d5fb06feba2e609bd53d0227c0868f10dc84f11139352b7e181012102f2918e0270621ede0a39e5054e420b96b94ec51e75c4df2e8884fe57f4c8b2e0273d0800");
  XCTAssertNil([metadata voutIndex]);
  XCTAssertNil([metadata changeAddress]);
  XCTAssertNil([metadata changePath]);
}

// MARK: meta address tests
- (void)testReceiveAddressForIndexContainsInfo {
  CNBHDWallet *wallet = [self walletForTestingMetadata];
  CNBMetaAddress *receiveAddress = [wallet receiveAddressForIndex:0];
  XCTAssertEqualObjects([receiveAddress address], @"3Aftutd9VvzLcGxD9VraNhWiHyjR5pvn5N");
  XCTAssertEqual([[receiveAddress derivationPath] index], 0);
  XCTAssertEqualObjects([receiveAddress uncompressedPublicKey], @"04884f3e8997a197a6c28efd1a000869f8e5575c2b71b6d964a20af0a1668da6c547cdfd37215d2fa7f4e440e7723f0629d8de4fc049fd38f47c0be6b3cd030f30");
}

- (void)testChangeAddressForIndexContainsAddressNotUncompressedPubkey {
  CNBHDWallet *wallet = [self walletForTestingMetadata];
  CNBMetaAddress *receiveAddress = [wallet changeAddressForIndex:0];
  XCTAssertNil([receiveAddress uncompressedPublicKey]);
}

// MARK: private methods
- (CNBHDWallet *)walletForTestingMetadata {
  NSArray *newWords = [GeneratedWordsHelper words1];
  MockBitcoinCoin *coin = [[MockBitcoinCoin alloc] initWithPurpose:BIP49 coin:MainNet account:0 networkURL:@""];
  CNBHDWallet *wallet = [[CNBHDWallet alloc] initWithMnemonic:newWords coin:coin];
  return wallet;
}

- (void)testECDH {
  CNBHDWallet *wallet = [self walletForTestingMetadata];
  NSString *uncompressedPubkeyString = @"04904240a0aaec6af6f9b6c331f71feea2a4ed1549c06e5a6409fe92c5824dc4c54e26c2b2e27cfc224a6b782b35a2872b666f568cf37456262fbb065601b4d73a";
  NSData *uncompressedPubkeyData = [uncompressedPubkeyString dataFromHexString];

  CNBCipherKeys *keys1 = [wallet encryptionCipherKeysForPublicKey:uncompressedPubkeyData];
  CNBCipherKeys *keys2 = [wallet encryptionCipherKeysForPublicKey:uncompressedPubkeyData];
  XCTAssertNotEqualObjects([keys1 encryptionKey], [keys2 encryptionKey]);
  XCTAssertNotEqualObjects([keys1 hmacKey], [keys2 encryptionKey]);
}

- (void)testBech32FirstReceiveAddress {
  NSString *address = [[[self tempSegwitWallet] receiveAddressForIndex:0] address];
  NSString *expected = @"bc1qcr8te4kr609gcawutmrza0j4xv80jy8z306fyu";
  XCTAssertEqualObjects(address, expected);
}

- (void)testBech32SecondReceiveAddress {
  NSString *address = [[[self tempSegwitWallet] receiveAddressForIndex:1] address];
  NSString *expected = @"bc1qnjg0jd8228aq7egyzacy8cys3knf9xvrerkf9g";
  XCTAssertEqualObjects(address, expected);
}

- (void)testBech32FirstChangeAddress {
  NSString *address = [[[self tempSegwitWallet] changeAddressForIndex:0] address];
  NSString *expected = @"bc1q8c6fshw2dlwun7ekn9qwf37cu2rn755upcp6el";
  XCTAssertEqualObjects(address, expected);
}

- (NSArray *)tempWords {
  return @[@"abandon", @"abandon", @"abandon", @"abandon", @"abandon", @"abandon", @"abandon", @"abandon", @"abandon", @"abandon", @"abandon", @"about"];
}

- (CNBBaseCoin *)tempSegwitCoin {
  return [[CNBBaseCoin alloc] initWithPurpose:BIP84 coin:MainNet account:0];
}

- (CNBHDWallet *)tempSegwitWallet {
  return [[CNBHDWallet alloc] initWithMnemonic:[self tempWords] coin:[self tempSegwitCoin]];
}

@end
