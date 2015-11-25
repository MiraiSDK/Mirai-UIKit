//
//  TNWeakValue.m
//  UIKit
//
//  Created by TaoZeyu on 15/11/24.
//  Copyright © 2015年 Shanghai Tinynetwork Inc. All rights reserved.
//

#import "TNWeakValue.h"

@implementation TNWeakValue

- (instancetype)initWithValue:(id)value
{
    if (self = [self init]) {
        _value = value;
    }
    return self;
}

+ (instancetype)valueWithWeakObject:(id)value
{
    return [[TNWeakValue alloc] initWithValue:value];
}

@end
