//
//  TNJavaBrigeProxy.h
//  UIKit
//
//  Created by TaoZeyu on 15/6/30.
//  Copyright (c) 2015年 Shanghai Tinynetwork Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#include <jni.h>

@interface TNJavaBrigeProxy : NSObject

+ (jint)newId;
- (instancetype)initWith:(jobject)jProxy;

@end
