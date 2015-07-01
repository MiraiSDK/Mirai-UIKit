//
//  TNJavaBrigeProxy.h
//  UIKit
//
//  Created by TaoZeyu on 15/6/30.
//  Copyright (c) 2015年 Shanghai Tinynetwork Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TNJavaBrigeDefinition.h"
#import "TNJavaBrigeCallbackContext.h"
#include <jni.h>

@interface TNJavaBrigeProxy : NSObject

@property (nonatomic, readonly) jobject jProxy;

- (instancetype)initWithDefinition:(TNJavaBrigeDefinition *)definition;
- (instancetype)initWithDefinition:(TNJavaBrigeDefinition *)definition
                      withCallback:(void (^)(TNJavaBrigeCallbackContext *context))callback;

- (void)callback:(void (^)(TNJavaBrigeCallbackContext *context))callback;
- (void)target:(id)target action:(SEL)action;

- (void)methodIndex:(NSUInteger)methodIndex callback:(void (^)(TNJavaBrigeCallbackContext *context))callback;
- (void)methodIndex:(NSUInteger)methodIndex target:(id)target action:(SEL)action;

- (void)unbindAllCallback;
- (void)unbindCallbackWithMethodIndex:(NSUInteger)methodIndex;

@end
