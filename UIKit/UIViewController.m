//
//  UIViewController.m
//  UIKit
//
//  Created by Chen Yonghui on 2/11/14.
//  Copyright (c) 2014 Shanghai Tinynetwork Inc. All rights reserved.
//

#import "UIViewController.h"

@implementation UIViewController
- (id)init
{
    return [self initWithNibName:nil bundle:nil];
}

- (id)initWithNibName:(NSString *)nibName bundle:(NSBundle *)nibBundle
{
    self = [super init];
    if (self) {
//        _contentSizeForViewInPopover = CGSizeMake(320,1100);
//        _hidesBottomBarWhenPushed = NO;
        _navigationItem = nil;
    }
    return self;
}

- (UIResponder *)nextResponder
{
    return _view.superview;
}

- (BOOL)isViewLoaded
{
    return (_view != nil);
}

- (UIView *)view
{
    if ([self isViewLoaded]) {
        return _view;
    } else {
        [self loadView];
        [self viewDidLoad];
        return _view;
    }
}

- (void)loadView
{
    self.view = [[UIView alloc] initWithFrame:CGRectMake(0,0,320,480)];
}

- (void)viewDidLoad
{
}

- (void)viewDidUnload
{
}

- (void)didReceiveMemoryWarning
{
}

- (void)viewWillAppear:(BOOL)animated
{
    for (UIViewController *child in self.childViewControllers) {
        [child viewWillAppear:animated];
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    
    for (UIViewController *child in self.childViewControllers) {
        [child viewDidAppear:animated];
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    for (UIViewController *child in self.childViewControllers) {
        [child viewWillDisappear:animated];
    }
}

- (void)viewDidDisappear:(BOOL)animated
{
    for (UIViewController *child in self.childViewControllers) {
        [child viewDidDisappear:animated];
    }
}

- (void)viewWillLayoutSubviews
{
}

- (void)viewDidLayoutSubviews
{
}

- (UIInterfaceOrientation)interfaceOrientation
{
    return (UIInterfaceOrientation)UIDeviceOrientationPortrait;
}

@end
