//
//  TNJavaBridgeProxy.h
//  UIKit
//
//  Created by TaoZeyu on 15/6/30.
//  Copyright (c) 2015年 Shanghai Tinynetwork Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TNJavaBridgeDefinition.h"
#import "TNJavaBridgeCallbackContext.h"
#include <jni.h>

@interface TNJavaBridgeProxy : NSObject

@property (nonatomic, readonly) jobject jProxiedInstance;

- (instancetype)initWithDefinition:(TNJavaBridgeDefinition *)definition;
- (instancetype)initWithDefinition:(TNJavaBridgeDefinition *)definition
                      withCallback:(void (^)(TNJavaBridgeCallbackContext *context))callback;

- (void)callback:(void (^)(TNJavaBridgeCallbackContext *context))callback;
- (void)target:(id)target action:(SEL)action;

- (void)methodIndex:(NSUInteger)methodIndex callback:(void (^)(TNJavaBridgeCallbackContext *context))callback;
- (void)methodIndex:(NSUInteger)methodIndex target:(id)target action:(SEL)action;

- (void)unbindAllCallback;
- (void)unbindCallbackWithMethodIndex:(NSUInteger)methodIndex;

@end
