//
//  TNTabBarControlTestViewController.m
//  UIKitDemo
//
//  Created by TaoZeyu on 15/3/22.
//  Copyright (c) 2015年 Shanghai TinyNetwork Inc. All rights reserved.
//

#import "TNTabBarControlTestViewController.h"
#import "TNChangeTabTestViewController.h"
#import "TNTabBarItemTestController.h"
#import "TNMoreNavigationTestViewController.h"

@interface TNTabBarControlTestViewController ()

@end

@implementation TNTabBarControlTestViewController

+ (void)load
{
    [self regisiterTestClass:self];
}

+ (NSString *)testName
{
    return @"UITabBarControl Test";
}

+ (NSArray *)subTests
{
    return @[
             [TNChangeTabTestViewController class],
             [TNTabBarItemTestController class],
             [TNMoreNavigationTestViewController class],
             ];
}

@end
