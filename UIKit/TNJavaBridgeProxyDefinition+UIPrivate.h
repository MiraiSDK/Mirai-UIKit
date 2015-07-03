//
//  TNJavaBridgeProxyDefinition+UIPrivate.h
//  UIKit
//
//  Created by TaoZeyu on 15/7/3.
//  Copyright (c) 2015年 Shanghai Tinynetwork Inc. All rights reserved.
//

#import "TNJavaBridgeDefinition.h"
#include <jni.h>

@interface TNJavaBridgeDefinition (UIPrivate)

- (jobject)newJProxyWithId:(jint)proxyId;

@end
