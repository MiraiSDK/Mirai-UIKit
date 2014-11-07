//
//  NSTextContainer.m
//  UIKit
//
//  Created by Chen Yonghui on 11/7/14.
//  Copyright (c) 2014 Shanghai Tinynetwork Inc. All rights reserved.
//

#import "NSTextContainer.h"

@implementation NSTextContainer
- (instancetype)initWithSize:(CGSize)size
{
    self = [super init];
    if (self) {
        _size = size;
    }
    return self;
}

- (CGRect)lineFragmentRectForProposedRect:(CGRect)proposedRect atIndex:(NSUInteger)characterIndex writingDirection:(NSWritingDirection)baseWritingDirection remainingRect:(CGRect *)remainingRect
{
    return CGRectZero;
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
