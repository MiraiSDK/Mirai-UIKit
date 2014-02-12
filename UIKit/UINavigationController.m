//
//  UINavigationController.m
//  UIKit
//
//  Created by Chen Yonghui on 2/12/14.
//  Copyright (c) 2014 Shanghai Tinynetwork Inc. All rights reserved.
//

#import "UINavigationController.h"

@interface UINavigationController ()

@end

@implementation UINavigationController

- (instancetype)initWithNavigationBarClass:(Class)navigationBarClass toolbarClass:(Class)toolbarClass
{
    return nil;
}

- (id)initWithRootViewController:(UIViewController *)rootViewController
{
    return nil;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)setViewControllers:(NSArray *)viewControllers
{
    [self setViewControllers:viewControllers animated:NO];
}

- (void)setViewControllers:(NSArray *)viewControllers animated:(BOOL)animated
{
    
}

- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    
}

- (UIViewController *)popViewControllerAnimated:(BOOL)animated
{
    NS_UNIMPLEMENTED_LOG;
    return nil;
}

- (NSArray *)popToViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    NS_UNIMPLEMENTED_LOG;
    return nil;
}

- (NSArray *)popToRootViewControllerAnimated:(BOOL)animated
{
    NS_UNIMPLEMENTED_LOG;
    return nil;
}

- (void)setNavigationBarHidden:(BOOL)navigationBarHidden
{
    [self setNavigationBarHidden:navigationBarHidden animated:NO];
}

- (void)setNavigationBarHidden:(BOOL)hidden animated:(BOOL)animated
{
    NS_UNIMPLEMENTED_LOG;
}

- (void)setToolbarItems:(NSArray *)toolbarItems
{
    [self setToolbarItems:toolbarItems animated:NO];
}

- (void)setToolbarItems:(NSArray *)toolbarItems animated:(BOOL)animated
{
    NS_UNIMPLEMENTED_LOG;
}

- (void)setToolbarHidden:(BOOL)toolbarHidden
{
    [self setToolbarHidden:toolbarHidden animated:NO];
}

- (void)setToolbarHidden:(BOOL)hidden animated:(BOOL)animated
{
    NS_UNIMPLEMENTED_LOG;
}
@end

@implementation UIViewController (UINavigationControllerItem)

- (UINavigationItem *)navigationItem
{
    NS_UNIMPLEMENTED_LOG;
    return nil;
}

- (BOOL)hidesBottomBarWhenPushed
{
    NS_UNIMPLEMENTED_LOG;
    return NO;
}

- (void)setHidesBottomBarWhenPushed:(BOOL)hidesBottomBarWhenPushed
{
    NS_UNIMPLEMENTED_LOG;
}

- (UINavigationController *)navigationController
{
    NS_UNIMPLEMENTED_LOG;
    return nil;
}

@end

@implementation UIViewController (UINavigationControllerContextualToolbarItems)

- (NSArray *)toolbarItems
{
    NS_UNIMPLEMENTED_LOG;
    return nil;
}

- (void)setToolbarItems:(NSArray *)toolbarItems
{
    [self setToolbarItems:toolbarItems animated:NO];
}

- (void)setToolbarItems:(NSArray *)toolbarItems animated:(BOOL)animated
{
    NS_UNIMPLEMENTED_LOG;
}

@end
