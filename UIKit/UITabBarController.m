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
#import "UIMoreNavigationController.h"
#import "UIImage.h"
#import "UIView.h"
#import "UIControl.h"

#define DefaultTabBarHeight 135
#define MaxShowedTabBarCount 5

@interface UITabBarController ()
@property BOOL hasShowedAnyViewController;
@property (nonatomic, strong) UINavigationController *moreNavigationController;
@property (nonatomic, strong) UIControl *viewControllerContainer;
@property (nonatomic, strong) NSArray *tabBarItemsBuffered;
@property (nonatomic, strong) UITabBarItem *moreTabItem;
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

- (void)loadView
{
    [super loadView];
    [self _refreshSubviewsSizeToAdaptScreen];
    [self _addSubviewsToSelf];
}

- (void)viewWillLayoutSubviews
{
    [self _refreshSubviewsSizeToAdaptScreen];
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
    [self _refreshCurrentViewToAdaptContainer];
}

- (void)_addSubviewsToSelf
{
    [self.view addSubview:_viewControllerContainer];
    [self.view addSubview:_tabBar];
}

- (void)_refreshTabBarSizeToAdaptScreen
{
    CGRect frame = self.view.frame;
    self.tabBar.frame = CGRectMake(0, frame.size.height - DefaultTabBarHeight, frame.size.width, DefaultTabBarHeight);
}

- (void)_refreshContainerSizeToAdaptScreen
{
    CGRect frame = self.view.frame;
    self.viewControllerContainer.frame = CGRectMake(0, 0, frame.size.width, frame.size.height - DefaultTabBarHeight);
}

- (void)_refreshCurrentViewToAdaptContainer
{
    UIViewController *controller = [self _getCustomizedViewControllerWithSelectedIndex:self.selectedIndex];
    CGSize containerSize = self.viewControllerContainer.frame.size;
    if (controller) {
        controller.view.frame = CGRectMake(0, 0, containerSize.width, containerSize.height);
    }
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
    [[self _getMoreNavigationControllerOperator] setCustomizableViewControllers:customizableViewControllers];
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
    [self _refreshMoreListOfMoreNavigationControllerWith];
    [self _showFirstViewControllerIfThereIsNotAnyViewControllerBeforeSetting];
    self.customizableViewControllers = viewControllers;
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
    return [self _getCustomizedViewControllerWithSelectedIndex:self.selectedIndex];
}

- (NSArray *)_createTabBarItemsByViewControllers:(NSArray *)viewControlelrs
{
    NSMutableArray *tabBarItems = [[NSMutableArray alloc] init];
    [self _addShowedTabsIntoArray:tabBarItems from:viewControlelrs];
    [self _addMoreTabIfNeedIntoArray:tabBarItems withViewControllers:viewControlelrs];
    return tabBarItems;
}

- (void)_refreshMoreListOfMoreNavigationControllerWith
{
    UIMoreNavigationController *moreNavigationController = [self _getMoreNavigationControllerOperator];
    NSArray *moreListViewControllers = [self _getMoreListNeedsViewControllers];
    [moreNavigationController setMoreListViewControllers:moreListViewControllers];
}

- (void)_showFirstViewControllerIfThereIsNotAnyViewControllerBeforeSetting
{
    if ([self _getCustomizedViewControllerWithSelectedIndex:self.selectedIndex] == nil &&
        [self _numberOfViewControllers] > 0) {
        self.tabBar.selectedItem = [self.tabBarItemsBuffered objectAtIndex:0];
    }
}

- (void)_addShowedTabsIntoArray:(NSMutableArray *)tabBarItems from:(NSArray *)viewControllers
{
    NSUInteger showedTabBarItemCount = [self _getCountOfShowedOnTabBarFromViewControllers:viewControllers];
    for (NSUInteger i = 0; i < showedTabBarItemCount; i++) {
        UIViewController *controller = [viewControllers objectAtIndex:i];
        UITabBarItem *tabBarItem = [self _createTabBarItemWithTitle:controller.title at:i];
        [tabBarItems addObject:tabBarItem];
    }
}

- (void)_addMoreTabIfNeedIntoArray:(NSMutableArray *)tabBarItems withViewControllers:(NSArray *)viewControllers
{
    UITabBarItem *moreTabItem = nil;
    
    if ([self _willShowMoreItemsOnTabBarWithViewControllers:viewControllers]) {
        NSUInteger moreTabIndex = [self _getCountOfShowedOnTabBarFromViewControllers:viewControllers];
        moreTabItem = [[UITabBarItem alloc] initWithTabBarSystemItem:UITabBarSystemItemMore
                                                                              tag:moreTabIndex];
        [tabBarItems addObject:moreTabItem];
    }
    self.moreTabItem = moreTabItem;
}

- (NSArray *)_getMoreListNeedsViewControllers
{
    if ([self _willShowMoreItemsOnTabBarWithViewControllers:self.viewControllers]) {
        return [self.viewControllers subarrayWithRange:[self _getRangeOfMoreViewControllerIndexes]];
    } else {
        return @[];
    }
}

- (NSRange)_getRangeOfMoreViewControllerIndexes
{
    NSUInteger startIndex = [self _getCountOfShowedOnTabBarFromViewControllers:self.viewControllers];
    return NSMakeRange(startIndex, self.viewControllers.count - startIndex);
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

- (NSUInteger)_getCountOfShowedOnTabBarFromViewControllers:(NSArray *)viewControllers
{
    if ([self _willShowMoreItemsOnTabBarWithViewControllers:viewControllers]) {
        //The "more" tab which will show moreNavigationController. It will take up a position.
        //So, there are one less positions for customized tabs.
        return MaxShowedTabBarCount - 1;
    } else {
        return viewControllers.count;
    }
}

- (BOOL)_willShowMoreItemsOnTabBarWithViewControllers:(NSArray *)viewControllers
{
    return viewControllers.count > MaxShowedTabBarCount;
}

- (BOOL)_isIndexAtMoreList:(NSUInteger)index withViewControllers:(NSArray *)viewControllers
{
    return index >= [self _getCountOfShowedOnTabBarFromViewControllers:viewControllers];
}

#pragma mark - delegate methods.

- (void)tabBar:(UITabBar *)tabBar didSelectItem:(UITabBarItem *)item
{
    NSUInteger selectedIndex = [self _findSelectedIndexWithSelectedItem:item];
    UIViewController *oldController = [self _getCustomizedViewControllerWithSelectedIndex:self.selectedIndex];
    UIViewController *newController = [self _getCustomizedViewControllerWithSelectedIndex:selectedIndex];
    
    if (oldController != newController) {
        
        [self _notifyWillAppearWithOldController:oldController withNewController:newController];
        [self _clearOldControllerFromScreenWith:oldController];
        [self _changeSelectedIndex:selectedIndex notifyTabBar:NO];
        [self _resetCurrentSelectedViewController];
        [self _notifyDidAppearWithOldController:oldController withNewController:newController];
    }
}

- (NSUInteger)_findSelectedIndexWithSelectedItem:(UITabBarItem *)item
{
    if (item == self.moreTabItem) {
        return NSNotFound; //NSNotFound means "more" is selected.
    } else {
        return [self _findIndexFromArray:self.tabBarItemsBuffered withObject:item];
    }
}

- (void)_notifyWillAppearWithOldController:(UIViewController *)oldController withNewController:(UIViewController *)newController
{
    if (oldController) {
        [oldController viewWillDisappear:NO];
    }
    [newController viewWillAppear:NO];
}

- (void)_notifyDidAppearWithOldController:(UIViewController *)oldController withNewController:(UIViewController *)newController
{
    if (oldController) {
        [oldController viewDidDisappear:NO];
    }
    [newController viewDidAppear:NO];
}

- (void)_clearOldControllerFromScreenWith:(UIViewController *)oldController
{
    if (oldController) {
        [oldController.view removeFromSuperview];
    }
}

- (void)_showSubViewController:(UIViewController *)controller
{
    CGSize containerSize = self.viewControllerContainer.frame.size;
    controller.view.frame = CGRectMake(0, 0, containerSize.width, containerSize.height);
    [self.viewControllerContainer addSubview:controller.view];
    self.hasShowedAnyViewController = YES;
}

- (void)_changeSelectedIndex:(NSUInteger)selectedIndex notifyTabBar:(BOOL)willNotify
{
    _selectedIndex = selectedIndex;
    if (willNotify) {
        if ([self _isIndexAtMoreList:selectedIndex withViewControllers:self.viewControllers]) {
            [self _showSubViewController:[self.viewControllers objectAtIndex:selectedIndex]];
        } else {
            if (selectedIndex == NSNotFound) {
                selectedIndex = [self _getCountOfShowedOnTabBarFromViewControllers:self.viewControllers];
            }
            [self.tabBar setSelectedItem:[self _getTabBarItemAt:selectedIndex]];
        }
    }
}

- (void)_resetCurrentSelectedViewController
{
    [self _showSubViewController: [self _getCustomizedViewControllerWithSelectedIndex:self.selectedIndex]];
}

- (UIViewController *)_getCustomizedViewControllerWithSelectedIndex:(NSUInteger)selectedIndex
{
    if (selectedIndex == NSNotFound) {
        return self.hasShowedAnyViewController? self.moreNavigationController: nil;
    } else {
        return [self _getViewControllerAt:selectedIndex];
    }
}

#pragma mark - moreViewController.

- (UINavigationController *)moreNavigationController
{
    if (_moreNavigationController == nil) {
        _moreNavigationController = [[UIMoreNavigationController alloc] initWithTitle:self.moreTabItem.title];
        // I have to invoke viewWillAppear here, otherwise, the rootViewController won't appear.
        // because, once the UINavigationController's instance method "view" was invoked, viewWillApear would
        // not work.
        [_moreNavigationController viewWillAppear:NO];
    }
    return _moreNavigationController;
}

- (UIMoreNavigationController *)_getMoreNavigationControllerOperator
{
    return (UIMoreNavigationController *) self.moreNavigationController;
}

- (void)_onSelectedIndexOfMoreListController:(NSNumber *)selectedIndexNumber
{
    NSUInteger selectedIndexAtMoreList = [selectedIndexNumber unsignedIntegerValue];
    NSUInteger firstIndexAtMoreList = [self _getCountOfShowedOnTabBarFromViewControllers:self.viewControllers];
    self.selectedIndex = selectedIndexAtMoreList + firstIndexAtMoreList;
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
