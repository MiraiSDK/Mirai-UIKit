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
#import "UINavigationController.h"
#import "UIMoreListController.h"
#import "UIImage.h"
#import "UIView.h"
#import "UIControl.h"

#define DefaultTabBarHeight 135
#define MaxShowedTabBarCount 5

@interface UITabBarController ()
@property BOOL hasShowedAnyViewController;
@property (nonatomic, strong) UIControl *viewControllerContainer;
@property (nonatomic, strong) NSArray *tabBarItemsBuffered;
@property (nonatomic, strong) UITabBarItem *moreTabItem;
@property (nonatomic, strong) UIMoreListController *moreListController;
@end

@implementation UITabBarController

- (instancetype)init
{
    if (self = [super init]) {
        [self _initDefaultValues];
        [self _initViewControllersAndSubviews];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super initWithCoder:aDecoder]) {
        [self _initDefaultValues];
        [self _initViewControllersAndSubviews];
    }
    return self;
}

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        [self _initDefaultValues];
        [self _initViewControllersAndSubviews];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self _refreshSubviewsSizeToAdaptScreen];
    [self _addSubviewsToSelf];
}

- (void)_initDefaultValues
{
    self.hasShowedAnyViewController = NO;
}

- (void)_initViewControllersAndSubviews
{
    [self _initAllPropertiesDefaultValues];
    [self _makeTabBarAndControllerContainer];
}

- (void)_refreshSubviewsSizeToAdaptScreen
{
    [self _refreshTabBarSizeToAdaptScreen];
    [self _refreshContainerSizeToAdaptScreen];
}

- (void)_addSubviewsToSelf
{
    [self.view addSubview:_viewControllerContainer];
    [self.view addSubview:_tabBar];
}

- (void)_refreshTabBarSizeToAdaptScreen
{
    CGRect frame = self.view.frame;
    self.tabBar.frame = CGRectMake(frame.origin.x, frame.origin.y + frame.size.height - DefaultTabBarHeight,
                                   frame.size.width, DefaultTabBarHeight);
}

- (void)_refreshContainerSizeToAdaptScreen
{
    CGRect frame = self.view.frame;
    self.viewControllerContainer.frame = CGRectMake(frame.origin.x, frame.origin.y,
                                           frame.size.width, frame.size.height - DefaultTabBarHeight);
}

- (void)_initAllPropertiesDefaultValues
{
    _selectedIndex = NSNotFound;
    _viewControllers = @[];
}

- (void)_makeTabBarAndControllerContainer
{
    _viewControllerContainer = [self _createViewControllerContainer];
    _tabBar = [self _createDefaultTabBar];
}

- (UITabBar *)_createDefaultTabBar
{
    UITabBar *tabBar = [[UITabBar alloc] initWithFrame:CGRectZero];
    tabBar.delegate = self;
    return tabBar;
}

- (UIControl *)_createViewControllerContainer
{
    return [[UIControl alloc] initWithFrame:CGRectZero];
}

- (void)setCustomizableViewControllers:(NSArray *)customizableViewControllers
{
    [self setViewControllers:customizableViewControllers animated:NO];
}

# pragma mark - viewControllers setting.

- (void)setViewControllers:(NSArray *)viewControllers
{
    [self setViewControllers:viewControllers animated:NO];
}

- (void)setViewControllers:(NSArray *)viewControllers animated:(BOOL)animated
{
    _viewControllers = viewControllers;
    self.tabBarItemsBuffered = [self _createTabBarItemsByViewControllers:viewControllers];
    [self.tabBar setItems:self.tabBarItemsBuffered animated:animated];
    [self _setContentsForMoreListViewControllers];
    [self _showFirstViewControllerIfThereIsNotAnyViewControllerBeforeSetting];
}

- (void)setSelectedViewController:(UIViewController *)selectedViewController
{
    NSUInteger selectedIndex = [self _findIndexFromArray:self.customizableViewControllers
                                              withObject:selectedViewController];
    if (selectedIndex != NSNotFound) {
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
    [self _addShowedTabsIntoArray:tabBarItems from:viewControlelrs];
    [self _addMoreTabIfNeedIntoArray:tabBarItems];
    return tabBarItems;
}

- (void)_addShowedTabsIntoArray:(NSMutableArray *)tabBarItems from:(NSArray *)viewControllers
{
    NSUInteger showedTabBarItemCount = [self _getCountOfViewControllersWhichWillShowOnTabBar];
    for (NSUInteger i = 0; i < showedTabBarItemCount; i++) {
        UIViewController *controller = [viewControllers objectAtIndex:i];
        UITabBarItem *tabBarItem = [self _createTabBarItemWithTitle:controller.title at:i];
        [tabBarItems insertObject:tabBarItem atIndex:i];
    }
}

- (void)_addMoreTabIfNeedIntoArray:(NSMutableArray *)tabBarItems
{
    UITabBarItem *moreTabItem = nil;
    
    if ([self _willShowMoreItemsOnTabBar]) {
        NSUInteger moreTabIndex = [self _getCountOfViewControllersWhichWillShowOnTabBar];
        moreTabItem = [[UITabBarItem alloc] initWithTabBarSystemItem:UITabBarSystemItemMore
                                                                              tag:moreTabIndex];
        [tabBarItems addObject:moreTabItem];
    }
    self.moreTabItem = moreTabItem;
}

- (void)_setContentsForMoreListViewControllers
{
    if ([self _willShowMoreItemsOnTabBar]) {
        self.moreListController.viewControllers = [self.viewControllers subarrayWithRange:[self _getRangeOfMoreViewControllerIndexes]];
    } else {
        self.moreListController.viewControllers = @[];
    }
}

- (NSRange)_getRangeOfMoreViewControllerIndexes
{
    NSUInteger startIndex = [self _getCountOfViewControllersWhichWillShowOnTabBar];
    return NSMakeRange(startIndex, self.viewControllers.count - startIndex);
}

- (void)_showFirstViewControllerIfThereIsNotAnyViewControllerBeforeSetting
{
    if ([self _getCurrentShowedViewController] != nil && [self _numberOfViewControllers] > 0) {
        UIViewController *firstController = [self _getViewControllerAt:0];
        [self _showSubViewController:firstController];
    }
}

- (UITabBarItem *)_createTabBarItemWithTitle:(NSString *)title at:(NSUInteger)index
{
    UIImage *image = [UIImage imageNamed:@"loveheart.png"];
    image = [image imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    return [[UITabBarItem alloc] initWithTitle:title image:image tag:index];
}

- (void)setSelectedIndex:(NSUInteger)selectedIndex
{
    if (_selectedIndex != selectedIndex) {
        [self _changeSelectedIndex:selectedIndex notifyTabBar:YES];
    }
}

- (NSUInteger)_getCountOfViewControllersWhichWillShowOnMoreListController
{
    NSUInteger viewControllersCount = self.viewControllers.count;
    NSUInteger countWillShowOnTabBar = [self _getCountOfViewControllersWhichWillShowOnTabBar];
    
    if (viewControllersCount < countWillShowOnTabBar) {
        return 0;
    }
    return viewControllersCount - countWillShowOnTabBar;
}

- (NSUInteger)_getCountOfViewControllersWhichWillShowOnTabBar
{
    if ([self _willShowMoreItemsOnTabBar]) {
        //The "more" tab which will show moreNavigationController. It will take up a position.
        //So, there are one less positions for customized tabs.
        return MaxShowedTabBarCount - 1;
    } else {
        return self.viewControllers.count;
    }
}

- (BOOL)_willShowMoreItemsOnTabBar
{
    return self.viewControllers.count > MaxShowedTabBarCount;
}

#pragma mark - delegate methods.

- (void)tabBar:(UITabBar *)tabBar didSelectItem:(UITabBarItem *)item
{
    NSUInteger selectedIndex = [self _findIndexFromArray:self.tabBarItemsBuffered withObject:item];
    
    if ([self _isIllegalWithSelectedIndex:selectedIndex withSelectedItem:item]) {
        return;
    }
    
    if (selectedIndex != self.selectedIndex) {
        [self _clearOldShowedViewController];
        [self _changeSelectedIndex:selectedIndex notifyTabBar:NO];
        [self _resetCurrentSelectedViewController];
    }
}

- (BOOL)_isIllegalWithSelectedIndex:(NSUInteger)selectedIndex withSelectedItem:(UITabBarItem *)item
{
    return selectedIndex == NSNotFound && item != self.moreTabItem;
}

- (void)_clearOldShowedViewController
{
    UIViewController *oldController = [self _getCurrentShowedViewController];
    if (oldController) {
        [oldController.view removeFromSuperview];
    }
}

- (void)_showSubViewController:(UIViewController *)controller
{
    [self.viewControllerContainer addSubview:controller.view];
    CGSize containerSize = self.viewControllerContainer.frame.size;
    controller.view.frame = CGRectMake(0, 0, containerSize.width, containerSize.height);
    self.hasShowedAnyViewController = YES;
}

- (void)_changeSelectedIndex:(NSUInteger)selectedIndex notifyTabBar:(BOOL)willNotify
{
    _selectedIndex = selectedIndex;
    if (willNotify) {
        if (selectedIndex == NSNotFound) {
            selectedIndex = [self _getCountOfViewControllersWhichWillShowOnTabBar];
        }
        [self.tabBar setSelectedItem:[self _getTabBarItemAt:selectedIndex]];
    }
}

- (void)_resetCurrentSelectedViewController
{
    UIViewController *selectedViewController;
    if ([self _isMoreViewControllerSelected]) {
        selectedViewController = self.moreListController;
    } else {
        selectedViewController = [self _getViewControllerAt:self.selectedIndex];
    }
    [self _showSubViewController: selectedViewController];
}

- (UIViewController *)_getCurrentShowedViewController
{
    if (!self.hasShowedAnyViewController) {
        return nil;
    } else if (self.selectedIndex == NSNotFound) {
        return self.moreNavigationController;
    } else {
        return [self _getViewControllerAt:self.selectedIndex];
    }
}

- (BOOL)_isMoreViewControllerSelected
{
    return self.selectedIndex == NSNotFound && self.hasShowedAnyViewController;
}

#pragma mark - moreViewController.

- (UIMoreListController *)moreListController
{
    if (_moreListController == nil) {
        _moreListController = [self _createMoreListController];
    }
    return _moreListController;
}

- (UIMoreListController *)_createMoreListController
{
    return [[UIMoreListController alloc] init];;
}

#pragma mark - items operation.

- (NSUInteger)_findIndexFromArray:(NSArray *)array withObject:(id)object
{
    for (NSUInteger i = 0; i < array.count; i ++) {
        if ([array objectAtIndex:i] == object) {
            return i;
        }
    }
    return NSNotFound;
}

- (UITabBarItem *)_getTabBarItemAt:(NSUInteger)index
{
    return (UITabBarItem *)[self.tabBarItemsBuffered objectAtIndex:index];
}

- (UIViewController *)_getViewControllerAt:(NSUInteger)index
{
    return (UIViewController *)[self.viewControllers objectAtIndex:index];
}

- (NSUInteger)_numberOfViewControllers
{
    return self.tabBarItemsBuffered.count;
}

@end
