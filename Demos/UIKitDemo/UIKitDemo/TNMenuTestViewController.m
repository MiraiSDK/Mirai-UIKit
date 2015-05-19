//
//  TNMenuTestViewController.m
//  UIKitDemo
//
//  Created by TaoZeyu on 15/5/18.
//  Copyright (c) 2015年 Shanghai TinyNetwork Inc. All rights reserved.
//

#import "TNMenuTestViewController.h"
#import "TNMenuPositionTestViewController.h"


@implementation TNMenuTestViewController

+ (NSString *)testName
{
    return @"UIMenuController Test";
}

+ (void)load
{
    [self regisiterTestClass:self];
}

+ (NSArray *)subTests
{
    return @[
             TNMenuPositionTestViewController.class,
             ];
}

@end
