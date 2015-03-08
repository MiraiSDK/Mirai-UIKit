//
//  UISegmentedControl.m
//  UIKit
//
//  Created by Chen Yonghui on 10/20/14.
//  Copyright (c) 2014 Shanghai Tinynetwork Inc. All rights reserved.
//

#import "UISegmentedControl.h"

@implementation UISegmentedControl
+ (BOOL)isUnimplemented
{
    return YES;
}

- (instancetype)initWithItems:(NSArray *)items
{
    self = [super initWithFrame:CGRectMake(0, 0, 200, 44)];
    if (self) {
        
    }
    return self;
}

- (void)insertSegmentWithTitle:(NSString *)title atIndex:(NSUInteger)segment animated:(BOOL)animated
{
    
}

- (void)removeSegmentAtIndex:(NSUInteger)segment animated:(BOOL)animated
{
    
}

- (void)removeAllSegments
{
    
}

- (void)setTitle:(NSString *)title forSegmentAtIndex:(NSUInteger)segment
{
    
}

- (NSString *)titleForSegmentAtIndex:(NSUInteger)segment
{
    return nil;
}

- (void)setWidth:(CGFloat)width forSegmentAtIndex:(NSUInteger)segment
{
    
}

- (CGFloat)widthForSegmentAtIndex:(NSUInteger)segment
{
    return 0.0f;
}

- (void)setEnabled:(BOOL)enabled forSegmentAtIndex:(NSUInteger)segment
{
    
}

- (BOOL)isEnabledForSegmentAtIndex:(NSUInteger)segment
{
    return NO;
}

- (void)setTitleTextAttributes:(NSDictionary *)attributes forState:(UIControlState)state
{
    
}

- (NSDictionary *)titleTextAttributesForState:(UIControlState)state
{
    return nil;
}

#pragma mark -
- (void)encodeWithCoder:(NSCoder *)aCoder
{
    
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    return self;
}
@end
