//
//  TNSearchControllerTestMenu.m
//  UIKitDemo
//
//  Created by TaoZeyu on 15/6/24.
//  Copyright (c) 2015年 Shanghai TinyNetwork Inc. All rights reserved.
//

#import "TNSearchControllerTestMenu.h"
#import "TNSearchBarTestViewController.h"

@implementation TNSearchControllerTestMenu

+ (NSString *)testName
{
    return @"UISearchController Test";
}

+ (void)load
{
    [self regisiterTestClass:self];
}

+ (NSArray *)subTests
{
    return @[TNSearchBarTestViewController.class,];
}

@end
