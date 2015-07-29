//
//  TNJavaBridgeProxy+UIJniObj.h
//  UIKit
//
//  Created by TaoZeyu on 15/7/3.
//  Copyright (c) 2015年 Shanghai Tinynetwork Inc. All rights reserved.
//

#import "TNJavaBridgeProxy.h"
#include <jni.h>

@interface TNJavaBridgeProxy (UIJniObj)

@property (nonatomic, readonly) jobject jProxiedInstance;

@end
