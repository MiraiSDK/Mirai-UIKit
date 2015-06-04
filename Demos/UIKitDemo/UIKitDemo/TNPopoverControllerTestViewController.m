//
//  TNPopoverControllerTestViewController.m
//  UIKitDemo
//
//  Created by TaoZeyu on 15/6/4.
//  Copyright (c) 2015年 Shanghai TinyNetwork Inc. All rights reserved.
//

#import "TNPopoverControllerTestViewController.h"
#import "TNPopoverPositionTestViewController.h"

@interface TNPopoverControllerTestViewController ()

@end

@implementation TNPopoverControllerTestViewController

+ (NSString *)testName
{
    return @"UIPopoverController Test";
}

+ (void)load
{
    [self regisiterTestClass:self];
}

+ (NSArray *)subTests
{
    return @[
             TNPopoverPositionTestViewController.class,
             ];
}


@end
