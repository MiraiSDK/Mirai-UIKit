//
//  UISlider.m
//  UIKit
//
//  Created by Chen Yonghui on 10/20/14.
//  Copyright (c) 2014 Shanghai Tinynetwork Inc. All rights reserved.
//

#import "UISlider.h"

@implementation UISlider
+ (BOOL)isUnimplemented
{
    return YES;
}

- (void)setValue:(float)value animated:(BOOL)animated;
{
    
}


- (void)setThumbImage:(UIImage *)image forState:(UIControlState)state
{
    
}
- (void)setMinimumTrackImage:(UIImage *)image forState:(UIControlState)state
{
    
}
- (void)setMaximumTrackImage:(UIImage *)image forState:(UIControlState)state
{
    
}

- (UIImage *)thumbImageForState:(UIControlState)state
{
    return nil;
}

- (UIImage *)minimumTrackImageForState:(UIControlState)state
{
    return nil;
}

- (UIImage *)maximumTrackImageForState:(UIControlState)state
{
    return nil;
}

- (CGRect)minimumValueImageRectForBounds:(CGRect)bounds
{
    return CGRectZero;
}

- (CGRect)maximumValueImageRectForBounds:(CGRect)bounds
{
    return CGRectZero;
}

- (CGRect)trackRectForBounds:(CGRect)bounds
{
    return CGRectZero;
}

- (CGRect)thumbRectForBounds:(CGRect)bounds trackRect:(CGRect)rect value:(float)value
{
    return CGRectZero;
}

@end
