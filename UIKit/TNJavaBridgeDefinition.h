//
//  TNJavaBridgeDefinition.h
//  UIKit
//
//  Created by TaoZeyu on 15/6/30.
//  Copyright (c) 2015年 Shanghai Tinynetwork Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TNJavaBridgeDefinition : NSObject

@property (nonatomic, readonly) NSUInteger classesCount;
@property (nonatomic, readonly) NSUInteger methodsCount;

- (instancetype)initWithProxiedClassName:(NSString *)proxiedClassName
                    withMethodSignatures:(NSArray *)methodSignatures;

- (instancetype)initWithProxiedClassName:(NSString *)proxiedClassName
                    withMethodSignature:(NSString *)methodSignature;

- (instancetype)initWithProxiedClassNames:(NSArray *)proxiedClassNames
                     withMethodSignatures:(NSArray *)methodSignatures;

@end
