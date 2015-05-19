//
//  TNSpliteViewControllerTestViewController.m
//  UIKitDemo
//
//  Created by TaoZeyu on 15/5/6.
//  Copyright (c) 2015年 Shanghai TinyNetwork Inc. All rights reserved.
//

#import "TNSplitViewControllerTestViewController.h"
#import "TNShowedSplitViewController.h"
#import "TNSplitNavigationTestViewController.h"
#import "TNDisplayModeTestViewController.h"
#import "AppDelegate.h"

@implementation TNSplitViewControllerTestViewController

+ (NSString *)testName
{
    return @"UISplitViewController Test";
}

+ (void)load
{
    [self regisiterTestClass:self];
}

+ (NSArray *)subTests
{
    return @[
             TNShowedSplitViewController.class,
             TNSplitNavigationTestViewController.class,
             TNDisplayModeTestViewController.class,
             ];
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    Class testClass = self.class.subTests[indexPath.row];
    appDelegate.window.rootViewController = [[testClass alloc] init];
}

@end
