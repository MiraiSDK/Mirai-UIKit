//
//  TNJavaBrigeDefinition.h
//  UIKit
//
//  Created by TaoZeyu on 15/6/30.
//  Copyright (c) 2015年 Shanghai Tinynetwork Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TNJavaBrigeProxy.h"
#include <jni.h>

@interface TNJavaBrigeDefinition : NSObject

- (instancetype)initWithProxiedClassName:(NSString *)proxiedClassName
                     withMethodSignatures:(NSArray *)methodSignatures;

- (instancetype)initWithProxiedClassNames:(NSArray *)proxiedClassNames
                     withMethodSignatures:(NSArray *)methodSignatures;

- (TNJavaBrigeProxy *)newProxy;

@end
