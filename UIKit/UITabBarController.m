//
//  UITabBarController.m
//  UIKit
//
//  Created by Chen Yonghui on 10/20/14.
//  Copyright (c) 2014 Shanghai Tinynetwork Inc. All rights reserved.
//

#import "UITabBarController.h"
#import "UITabBar.h"
#import "UITabBarItem.h"
#import "UIView.h"

#define IndexNotFound NSIntegerMax
#define DefaultTabBarHeight 50

@interface UITabBarController ()
@property (nonatomic, strong) UIView *viewControllerContainer;
@property (nonatomic, strong) NSArray *tabBarItemsBuffered;
@end

@implementation UITabBarController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self _initViewControllersAndSubviews];
}

- (void)_initViewControllersAndSubviews
{
    _viewControllers = @[];
    [self _makeTabBarAndControllerContainer];
    [self _showSubViewControllerWithIndex:0];
}

- (void)_makeTabBarAndControllerContainer
{
    _viewControllerContainer = [self _createViewControllerContainer];
    _tabBar = [self _createDefaultTabBar];
    [self.view addSubview:_viewControllerContainer];
    [self.view addSubview:_tabBar];
}

- (UITabBar *)_createDefaultTabBar
{
    CGRect frame = self.view.frame;
    CGRect tabBarFrame = CGRectMake(frame.origin.x, frame.origin.y + frame.size.height - DefaultTabBarHeight,
                      frame.size.width, DefaultTabBarHeight);
    UITabBar *tabBar = [[UITabBar alloc] initWithFrame:tabBarFrame];
    tabBar.delegate = self;
    return tabBar;
}

- (UIView *)_createViewControllerContainer
{
    CGRect frame = self.view.frame;
    CGRect containerFrame = CGRectMake(frame.origin.x, frame.origin.y,
                                       frame.size.width, frame.size.height - DefaultTabBarHeight);
    return [[UIView alloc] initWithFrame:containerFrame];
}

- (void)setCustomizableViewControllers:(NSArray *)customizableViewControllers
{
    [self setViewControllers:customizableViewControllers animated:NO];
}

- (void)setViewControllers:(NSArray *)viewControllers
{
    [self setViewControllers:viewControllers animated:NO];
}

- (void)setViewControllers:(NSArray *)viewControllers animated:(BOOL)animated
{
    self.tabBarItemsBuffered = [self _createTabBarItemsByViewControllers:viewControllers];
    [self.tabBar setItems:self.tabBarItemsBuffered animated:animated];
}

- (void)setSelectedViewController:(UIViewController *)selectedViewController
{
    NSUInteger selectedIndex = [self _findIndexFromArray:self.customizableViewControllers
                                              withObject:selectedViewController];
    if (selectedIndex != IndexNotFound) {
        self.selectedIndex = selectedIndex;
    }
}

- (UIViewController *)selectedViewController
{
    return [self _getViewControllerAt:self.selectedIndex];
}

- (NSArray *)_createTabBarItemsByViewControllers:(NSArray *)viewControlelrs
{
    NSMutableArray *tabBarItems = [[NSMutableArray alloc] init];
    for (NSUInteger i = 0; i < viewControlelrs.count; i++) {
        UIViewController *controller = [viewControlelrs objectAtIndex:i];
        UITabBarItem *tabBarItem = [self _createTabBarItemWithTitle:controller.title at:i];
        [tabBarItems insertObject:tabBarItem atIndex:i];
    }
    return tabBarItems;
}

- (UITabBarItem *)_createTabBarItemWithTitle:(NSString *)title at:(NSUInteger)index
{
    return [[UITabBarItem alloc] initWithTitle:title image:nil tag:index];
}

- (void)setSelectedIndex:(NSUInteger)selectedIndex
{
    if (_selectedIndex != selectedIndex) {
        [self _changeSelectedIndex:selectedIndex notifyTabBar:YES];
    }
}

#pragma mark - delegate methods.

- (void)tabBar:(UITabBar *)tabBar didSelectItem:(UITabBarItem *)item
{
    NSUInteger selectedIndex = [self _findIndexFromArray:self.tabBarItemsBuffered withObject:item];
    if (selectedIndex != IndexNotFound && self.selectedIndex != selectedIndex) {
        [self _showSubViewControllerWithIndex:selectedIndex];
        [self _changeSelectedIndex:selectedIndex notifyTabBar:NO];
    }
}

- (void)_changeSelectedIndex:(NSUInteger)selectedIndex notifyTabBar:(BOOL)willNotify
{
    _selectedIndex = selectedIndex;
    if (willNotify) {
        [self.tabBar setSelectedItem:[self _getTabBarItemAt:selectedIndex]];
    }
}

- (void)_showSubViewControllerWithIndex:(NSUInteger)index
{
    UIViewController *oldController = [self _getViewControllerAt:self.selectedIndex];
    UIViewController *newController = [self _getViewControllerAt:index];
    
    [oldController.view removeFromSuperview];
    [self.viewControllerContainer addSubview:newController.view];
    
    CGSize containerSize = self.viewControllerContainer.frame.size;
    newController.view.frame = CGRectMake(0, 0, containerSize.width, containerSize.height);
}

#pragma mark - items operation.

- (NSUInteger)_findIndexFromArray:(NSArray *)array withObject:(id)object
{
    for (NSUInteger i = 0; i < array.count; i ++) {
        if ([array objectAtIndex:i] == object) {
            return i;
        }
    }
    return IndexNotFound;
}

- (UITabBarItem *)_getTabBarItemAt:(NSUInteger)index
{
    return (UITabBarItem *)[self.tabBarItemsBuffered objectAtIndex:index];
}

- (UIViewController *)_getViewControllerAt:(NSUInteger)index
{
    return (UIViewController *)[self.viewControllers objectAtIndex:index];
}

@end
