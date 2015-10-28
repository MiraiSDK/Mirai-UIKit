//
//  TNMultiTouchTestViewController.m
//  UIKitDemo
//
//  Created by TaoZeyu on 15/10/3.
//  Copyright © 2015年 Shanghai TinyNetwork Inc. All rights reserved.
//

#import "TNMultiTouchTestViewController.h"
#import "TNMultiTouchTapCountTestViewController.h"

@implementation TNMultiTouchTestViewController

+ (NSString *)testName
{
    return @"MultiTouchTestViewController Test";
}

+ (void)load
{
    [self regisiterTestClass:self];
}

+ (NSArray *)subTests
{
    return @[TNMultiTouchTapCountTestViewController.class];
}

@end
