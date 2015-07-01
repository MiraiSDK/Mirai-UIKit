//
//  TNJavaBridgeCallbackContext.h
//  UIKit
//
//  Created by TaoZeyu on 15/7/1.
//  Copyright (c) 2015年 Shanghai Tinynetwork Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TNJavaBridgeCallbackContext : NSObject

- (int)integerParameterAt:(NSUInteger)index;
- (float)floatParameterAt:(NSUInteger)index;
- (double)doubleParameterAt:(NSUInteger)index;
- (NSString *)stringParameterAt:(NSUInteger)index;

- (void)setIntegerResult:(int)result;
- (void)setFloatResult:(float)result;
- (void)setDoubleResult:(double)result;
- (void)setStringResult:(NSString *)result;

@end
