//
//  NSShadow.m
//  UIKit
//
//  Created by Chen Yonghui on 11/7/14.
//  Copyright (c) 2014 Shanghai Tinynetwork Inc. All rights reserved.
//

#import "NSShadow.h"

@implementation NSShadow

#pragma mark - NSCopying
- (instancetype)copyWithZone:(NSZone *)zone
{
    id theCopy = [[[self class] alloc] init];
    return theCopy;
}

#pragma mark - NSCoding
- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    
}
@end
