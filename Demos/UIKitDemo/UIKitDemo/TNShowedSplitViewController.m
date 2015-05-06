//
//  TNShowedSpitViewController.m
//  UIKitDemo
//
//  Created by TaoZeyu on 15/5/6.
//  Copyright (c) 2015年 Shanghai TinyNetwork Inc. All rights reserved.
//

#import "TNShowedSplitViewController.h"

@implementation TNShowedSplitViewController

+ (NSString *)testName
{
    return @"have a fun.";
}

- (void)loadView
{
    self.viewControllers = @[
                             [self _createPrimaryViewController],
                             [self _createSecondaryViewController],
                             ];
    [super loadView];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self _settingSplitViewController];
}

- (UIViewController *)_createPrimaryViewController
{
    UIViewController *primaryViewController = [[UIViewController alloc] initWithNibName:nil bundle:nil];
    primaryViewController.view.backgroundColor = [UIColor redColor];
    return [[UINavigationController alloc] initWithRootViewController:primaryViewController];
}

- (UIViewController *)_createSecondaryViewController
{
    UIViewController *secondaryViewController = [[UIViewController alloc] initWithNibName:nil bundle:nil];
    secondaryViewController.view.backgroundColor = [UIColor blueColor];
    return [[UINavigationController alloc] initWithRootViewController:secondaryViewController];
}

- (void)_settingSplitViewController
{
    [self.displayModeButtonItem setTitle:@"let's see something."];
    NSLog(@"-> displayModeButtonItem = %@", self.displayModeButtonItem);
    NSLog(@"-> %@", self.displayModeButtonItem.title);
}

@end
