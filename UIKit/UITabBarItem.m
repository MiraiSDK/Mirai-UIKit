//
//  UITabBarItem.m
//  UIKit
//
//  Created by Chen Yonghui on 11/7/14.
//  Copyright (c) 2014 Shanghai Tinynetwork Inc. All rights reserved.
//

#import "UITabBarItem.h"

@implementation UITabBarItem
- (instancetype)initWithTitle:(NSString *)title image:(UIImage *)image tag:(NSInteger)tag
{
    self = [super init];
    return self;
}

- (instancetype)initWithTitle:(NSString *)title image:(UIImage *)image selectedImage:(UIImage *)selectedImage
{
    self = [super init];
    return self;
}

- (instancetype)initWithTabBarSystemItem:(UITabBarSystemItem)systemItem tag:(NSInteger)tag
{
    self = [super init];
    return self;
}

- (void)setFinishedSelectedImage:(UIImage *)selectedImage withFinishedUnselectedImage:(UIImage *)unselectedImage
{
    
}

- (UIImage *)finishedSelectedImage
{
    return nil;
}

- (UIImage *)finishedUnselectedImage
{
    return nil;
}

- (void)setTitlePositionAdjustment:(UIOffset)adjustment
{
    
}

- (UIOffset)titlePositionAdjustment
{
    return UIOffsetZero;
}

@end
