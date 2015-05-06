//
//  UISplitViewController.m
//  UIKit
//
//  Created by Chen Yonghui on 11/4/14.
//  Copyright (c) 2014 Shanghai Tinynetwork Inc. All rights reserved.
//

#import "UISplitViewController.h"

@interface UISplitViewController ()
@property (nonatomic) CGFloat primaryColumnWidth;
@property (nonatomic, strong) UIViewController *primaryViewController;
@property (nonatomic, strong) UIViewController *secondaryViewController;
@end

@implementation UISplitViewController

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        [self _settingDefaultValues];
    }
    return self;
}

- (void)_settingDefaultValues
{
    _viewControllers = @[];
    _preferredPrimaryColumnWidthFraction = 0.4;
    _maximumPrimaryColumnWidth = 400.0;
    _minimumPrimaryColumnWidth = 0.0;
}

- (void)loadView
{
    if (_viewControllers.count == 0) {
        NSLog(@"%@ is expected to have a view controller at index 0 before it's used!", self);
    }
    [super loadView];
    [self _refreshPrimaryColumnWidth];
    [self _synchronizeSubViewControllerAppearnce];
}

# pragma mark - setting about primary size.

- (BOOL)collapsed
{
    return self.viewControllers.count <= 1;
}

- (void)viewWillTransitionToSize:(CGSize)size
{
    [self _refreshPrimaryColumnWidth];
    [self _synchronizeSubViewControllerAppearnce];
}

- (void)setPreferredPrimaryColumnWidthFraction:(CGFloat)preferredPrimaryColumnWidthFraction
{
    preferredPrimaryColumnWidthFraction = MAX(0.0, MIN(1.0, preferredPrimaryColumnWidthFraction));
    if (_preferredPrimaryColumnWidthFraction != preferredPrimaryColumnWidthFraction) {
        _preferredPrimaryColumnWidthFraction = preferredPrimaryColumnWidthFraction;
        [self _refreshPrimaryColumnWidth];
        [self _synchronizeSubViewControllerAppearnce];
    }
}

- (void)setPrimaryColumnWidth:(CGFloat)primaryColumnWidth
{
    _primaryColumnWidth = MAX(_minimumPrimaryColumnWidth, MIN(_maximumPrimaryColumnWidth, primaryColumnWidth));
}

- (void)setMaximumPrimaryColumnWidth:(CGFloat)maximumPrimaryColumnWidth
{
    _maximumPrimaryColumnWidth = MAX(0.0, maximumPrimaryColumnWidth);
    _minimumPrimaryColumnWidth = MIN(maximumPrimaryColumnWidth, _minimumPrimaryColumnWidth);
    _primaryColumnWidth = MIN(maximumPrimaryColumnWidth, _primaryColumnWidth);
}

- (void)setMinimumPrimaryColumnWidth:(CGFloat)minimumPrimaryColumnWidth
{
    _minimumPrimaryColumnWidth = MAX(0.0, minimumPrimaryColumnWidth);
    _maximumPrimaryColumnWidth = MAX(minimumPrimaryColumnWidth, _maximumPrimaryColumnWidth);
    _primaryColumnWidth = MAX(minimumPrimaryColumnWidth, _primaryColumnWidth);
}

- (void)_refreshPrimaryColumnWidth
{
    if (self.collapsed) {
        self.primaryColumnWidth = self.view.bounds.size.width;
    } else {
        self.primaryColumnWidth = self.view.bounds.size.width*self.preferredPrimaryColumnWidthFraction;
    }
}

#pragma mark - set and get view controllers.

- (void)setViewControllers:(NSArray *)viewControllers
{
    [self _synchronizeSubViewControllerPropertiesWithArray:viewControllers];
    [self _synchronizeSubViewControllerAppearnce];
}

- (void)_synchronizeSubViewControllerPropertiesWithArray:(NSArray *)viewControllers
{
    _viewControllers = [[NSArray alloc] initWithArray:viewControllers];
    [self _clearOldViewController:_primaryViewController];
    [self _clearOldViewController:_secondaryViewController];
    _primaryViewController = [self _getObjectAt:0 returnNilIfNotExistsFromArray:viewControllers];
    _secondaryViewController = [self _getObjectAt:1 returnNilIfNotExistsFromArray:viewControllers];
}

- (void)_synchronizeSubViewControllerAppearnce
{
    [self _letViewController:_primaryViewController onStage:YES
                   withFrame:[self _getPrimaryViewControllerFrame]];
    [self _letViewController:_secondaryViewController onStage:!self.collapsed
                    withFrame:[self _getSecondaryViewControllerFrame]];
}

- (void)_clearOldViewController:(UIViewController *)oldViewController
{
    if (oldViewController != nil) {
        [oldViewController.view removeFromSuperview];
    }
}

- (CGRect)_getPrimaryViewControllerFrame
{
    return [self _getAreaWithRangeFrom:0 to:self.primaryColumnWidth];
}

- (CGRect)_getSecondaryViewControllerFrame
{
    return [self _getAreaWithRangeFrom:self.primaryColumnWidth to:self.view.bounds.size.width];
}

- (void)_letViewController:(UIViewController *)viewController onStage:(BOOL)onStage withFrame:(CGRect)frame
{
    if (viewController) {
        [self _synchronizeView:viewController.view onStage:onStage];
        if (onStage) {
            viewController.view.frame = frame;
        }
    }
}

- (id)_getObjectAt:(NSUInteger)index returnNilIfNotExistsFromArray:(NSArray *)array
{
    if (index >= array.count) {
        return nil;
    }
    return [array objectAtIndex:index];
}

- (CGRect)_getAreaWithRangeFrom:(CGFloat)startXLocation to:(CGFloat)endXLocation
{
    return CGRectMake(startXLocation, 0, endXLocation - startXLocation, self.view.bounds.size.height);
}

- (void)_synchronizeView:(UIView *)view onStage:(BOOL)onStage
{
    if (onStage && view.superview != self.view) {
        [self.view addSubview:view];
    } else if (!onStage && view.superview == self.view) {
        [view removeFromSuperview];
    }
}

- (UISplitViewController *)splitViewController
{
    return self;
}

@end
