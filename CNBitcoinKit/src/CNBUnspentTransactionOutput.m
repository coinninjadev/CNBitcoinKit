//
//  CNBUnspentTransactionOutput.m
//  CNBitcoinKit
//
//  Created by Mitchell on 5/14/18.
//  Copyright © 2018 Coin Ninja, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CNBUnspentTransactionOutput.h"

@implementation CNBUnspentTransactionOutput

-(instancetype)initWithId:(NSString *)txId
                    index:(NSUInteger)index
                   amount:(NSUInteger)amount
           derivationPath:(CNBDerivationPath *)path
              isConfirmed:(BOOL)confirmed{
  if(self = [super init]) {
    self.txId = txId;
    self.index = index;
    self.amount = amount;
    self.path = path;
    self.isConfirmed = confirmed;
  }

  return self;
}

@end
