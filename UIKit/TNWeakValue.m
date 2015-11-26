//
//  TNWeakValue.m
//  UIKit
//
//  Created by TaoZeyu on 15/11/24.
//  Copyright © 2015年 Shanghai Tinynetwork Inc. All rights reserved.
//

#import "TNWeakValue.h"

@implementation TNWeakValue
{
    NSUInteger _valueHash;
    void *_valuePointer; // only use to check if equal.
}

- (instancetype)initWithValue:(id)value
{
    if (self = [self init]) {
        self.value = value;
    }
    return self;
}

- (void)setValue:(id)value
{
    _value = value;
    _valueHash = [value hash];
    _valuePointer = (__bridge void *) value;
}

+ (instancetype)valueWithWeakObject:(id)value
{
    return [[TNWeakValue alloc] initWithValue:value];
}

- (NSUInteger)hash
{
    return _valueHash;
}

- (BOOL)isEqual: (id)anObject
{
    if ([anObject isKindOfClass:self.class]) {
        return [self isEqualToWeakValue: (TNWeakValue *)anObject];
    }
    return NO;
}

- (BOOL)isEqualTo:(id)object
{
    return [self isEqual:object];
}

- (BOOL)isEqualToWeakValue:(TNWeakValue *)other
{
    return self->_valuePointer == other->_valuePointer;
}

@end
