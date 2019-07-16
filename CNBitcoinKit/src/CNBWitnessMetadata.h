//
//  CNBWitnessMetadata.h
//  CNBitcoinKit
//
//  Created by BJ Miller on 7/9/19.
//  Copyright © 2019 Coin Ninja, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface CNBWitnessMetadata : NSObject

@property (nonatomic, assign) NSInteger witver;
@property (nonatomic, retain) NSData *witprog;

- (instancetype)initWithWitVer:(NSInteger)witver witProg:(NSData *)witprog;

@end

NS_ASSUME_NONNULL_END
