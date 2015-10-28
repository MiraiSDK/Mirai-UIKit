//
//  TNNextBookIssueTestViewController.m
//  UIKitDemo
//
//  Created by TaoZeyu on 15/10/26.
//  Copyright © 2015年 Shanghai TinyNetwork Inc. All rights reserved.
//

#import "TNNextBookIssueTestViewController.h"
#import "TNInteractiveImageWidgetTestViewController.h"

@implementation TNNextBookIssueTestViewController

+ (NSString *)testName
{
    return @"NextBook issue test";
}

+ (void)load
{
    [self regisiterTestClass:self];
}

- (NSArray *)subTests
{
    return @[TNInteractiveImageWidgetTestViewController.class];
}

@end
