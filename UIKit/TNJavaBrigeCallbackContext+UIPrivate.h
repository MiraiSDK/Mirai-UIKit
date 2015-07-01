//
//  TNJavaBrigeCallbackContext+UIPrivate.h
//  UIKit
//
//  Created by TaoZeyu on 15/7/1.
//  Copyright (c) 2015年 Shanghai Tinynetwork Inc. All rights reserved.
//

#import "TNJavaBrigeCallbackContext.h"
#include <jni.h>
#import <TNJavaHelper/TNJavaHelper.h>

@interface TNJavaBrigeCallbackContext (UIPrivate)

@property (nonatomic, readonly) jobject returnObject;

- (instancetype)initWithArgs:(jarray)args;
- (void)setInvalid;

@end