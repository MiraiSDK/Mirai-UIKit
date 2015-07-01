//
//  TNJavaBridgeCallbackContext+UIPrivate.h
//  UIKit
//
//  Created by TaoZeyu on 15/7/1.
//  Copyright (c) 2015年 Shanghai Tinynetwork Inc. All rights reserved.
//

#import "TNJavaBridgeCallbackContext.h"
#include <jni.h>
#import <TNJavaHelper/TNJavaHelper.h>

@interface TNJavaBridgeCallbackContext (UIPrivate)

@property (nonatomic, readonly) jobject jReturnObject;

- (instancetype)initWithArgs:(jarray)args;
- (void)setInvalid;

@end