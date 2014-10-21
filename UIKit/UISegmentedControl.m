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

- (void)insertSegmentWithImage:(UIImage *)image  atIndex:(NSUInteger)segment animated:(BOOL)animated
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

- (void)setImage:(UIImage *)image forSegmentAtIndex:(NSUInteger)segment
{
    
}

- (UIImage *)imageForSegmentAtIndex:(NSUInteger)segment
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

- (void)setContentOffset:(CGSize)offset forSegmentAtIndex:(NSUInteger)segment
{
    
}

- (CGSize)contentOffsetForSegmentAtIndex:(NSUInteger)segment
{
    return CGSizeZero;
}

- (void)setEnabled:(BOOL)enabled forSegmentAtIndex:(NSUInteger)segment
{
    
}

- (BOOL)isEnabledForSegmentAtIndex:(NSUInteger)segment
{
    return NO;
}

- (void)setBackgroundImage:(UIImage *)backgroundImage forState:(UIControlState)state barMetrics:(UIBarMetrics)barMetrics
{
    
}

- (UIImage *)backgroundImageForState:(UIControlState)state barMetrics:(UIBarMetrics)barMetrics
{
    return nil;
}

- (void)setDividerImage:(UIImage *)dividerImage forLeftSegmentState:(UIControlState)leftState rightSegmentState:(UIControlState)rightState barMetrics:(UIBarMetrics)barMetrics
{
    
}

- (UIImage *)dividerImageForLeftSegmentState:(UIControlState)leftState rightSegmentState:(UIControlState)rightState barMetrics:(UIBarMetrics)barMetrics
{
    return nil;
}

- (void)setTitleTextAttributes:(NSDictionary *)attributes forState:(UIControlState)state
{
    
}

- (NSDictionary *)titleTextAttributesForState:(UIControlState)state
{
    return nil;
}

- (void)setContentPositionAdjustment:(UIOffset)adjustment forSegmentType:(UISegmentedControlSegment)leftCenterRightOrAlone barMetrics:(UIBarMetrics)barMetrics
{
    
}

- (UIOffset)contentPositionAdjustmentForSegmentType:(UISegmentedControlSegment)leftCenterRightOrAlone barMetrics:(UIBarMetrics)barMetrics
{
    return UIOffsetZero;
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
