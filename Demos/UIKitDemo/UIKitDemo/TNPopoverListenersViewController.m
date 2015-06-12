//
//  TNPopoverListenersViewController.m
//  UIKitDemo
//
//  Created by TaoZeyu on 15/6/12.
//  Copyright (c) 2015年 Shanghai TinyNetwork Inc. All rights reserved.
//

#import "TNPopoverListenersViewController.h"

@interface TNPopoverListenersViewController ()

@end

@implementation TNPopoverListenersViewController

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    NSLog(@"TNPopoverListenersViewController - %s", __FUNCTION__);
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    NSLog(@"TNPopoverListenersViewController - %s", __FUNCTION__);
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    NSLog(@"TNPopoverListenersViewController - %s", __FUNCTION__);
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    NSLog(@"TNPopoverListenersViewController - %s", __FUNCTION__);
}

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    NSLog(@"TNPopoverListenersViewController - %s", __FUNCTION__);
}

- (void)viewDidLoad {
    [super viewDidLoad];
    NSLog(@"TNPopoverListenersViewController - %s", __FUNCTION__);
}

- (void)popoverController:(UIPopoverController *)popoverController willRepositionPopoverToRect:(inout CGRect *)rect inView:(inout UIView *__autoreleasing *)view
{
    NSLog(@"TNPopoverListenersViewController - %s %@ %@", __FUNCTION__, NSStringFromCGRect(*rect), *view);
}

- (BOOL)popoverControllerShouldDismissPopover:(UIPopoverController *)popoverController
{
    NSLog(@"TNPopoverListenersViewController - %s", __FUNCTION__);
    return YES;
}

- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController
{
    NSLog(@"TNPopoverListenersViewController - %s", __FUNCTION__);
}

@end
