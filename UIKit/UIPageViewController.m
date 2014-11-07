//
//  UIPageViewController.m
//  UIKit
//
//  Created by Chen Yonghui on 11/7/14.
//  Copyright (c) 2014 Shanghai Tinynetwork Inc. All rights reserved.
//

#import "UIPageViewController.h"
NSString * const UIPageViewControllerOptionSpineLocationKey = @"UIPageViewControllerOptionSpineLocationKey";
NSString * const UIPageViewControllerOptionInterPageSpacingKey = @"UIPageViewControllerOptionInterPageSpacingKey";

@implementation UIPageViewController
- (instancetype)initWithTransitionStyle:(UIPageViewControllerTransitionStyle)style navigationOrientation:(UIPageViewControllerNavigationOrientation)navigationOrientation options:(NSDictionary *)options
{
    self = [super init];
    return self;
}

- (void)setViewControllers:(NSArray *)viewControllers direction:(UIPageViewControllerNavigationDirection)direction animated:(BOOL)animated completion:(void (^)(BOOL finished))completion
{
    
}
@end
