//
//  UISplitViewController.m
//  UIKit
//
//  Created by Chen Yonghui on 11/4/14.
//  Copyright (c) 2014 Shanghai Tinynetwork Inc. All rights reserved.
//

#import "UISplitViewController.h"

#define kChangeSplitAppearanceNeedTime 0.7

typedef enum {
    UISplitViewControllerSplitAppearncePrimaryHidden    = 1 << 0,
    UISplitViewControllerSplitAppearncePrimaryOverlay   = 1 << 1,
    UISplitViewControllerSplitAppearnceBoth             = 1 << 2,
} UISplitViewControllerSplitAppearnce;

@interface UISplitViewController ()
@property (nonatomic) CGFloat primaryColumnWidth;
@property (nonatomic) UISplitViewControllerSplitAppearnce splitAppearance;
@property (nonatomic) UISplitViewControllerDisplayMode displayMode;
@property (nonatomic, strong) UIBarButtonItem *displayModeButtonItem;
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
    _preferredDisplayMode = UISplitViewControllerDisplayModeAutomatic;
    _displayMode = UISplitViewControllerDisplayModeAutomatic;
    _splitAppearance = UISplitViewControllerSplitAppearncePrimaryOverlay;
}

- (void)loadView
{
    if (_viewControllers.count == 0) {
        NSLog(@"%@ is expected to have a view controller at index 0 before it's used!", self);
    }
    [super loadView];
    [self _refreshPrimaryColumnWidth];
    [self _synchronizeSubViewControllerAppearnce];
    [self _makeSplitAppearanceChangeGesture];
}

# pragma mark - setting about primary size.

- (BOOL)isCollapsed
{
    return self.viewControllers.count <= 1 || _splitAppearance == UISplitViewControllerSplitAppearncePrimaryHidden;
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
    // this method must be called before loadView:
    // so, when call this method, self.view may be probable not ready to invoke.
    if (self.isViewLoaded) {
        [self _synchronizeSubViewControllerAppearnce];
    }
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
    [self _letViewController:_primaryViewController onStage:!self.collapsed
                   withFrame:[self _getPrimaryViewControllerFrameWithSplitAppearnce:_splitAppearance]];
    [self _letViewController:_secondaryViewController onStage:YES
                   withFrame:[self _getSecondaryViewControllerFrameWithSplitAppearnce:_splitAppearance]];
}

- (void)_clearOldViewController:(UIViewController *)oldViewController
{
    if (oldViewController != nil) {
        [oldViewController.view removeFromSuperview];
    }
}

- (CGRect)_getPrimaryViewControllerFrameWithSplitAppearnce:(UISplitViewControllerSplitAppearnce)splitAppearance
{
    switch (splitAppearance) {
        case UISplitViewControllerSplitAppearncePrimaryHidden:
            return [self _getAreaWithRangeFrom:-self.primaryColumnWidth to:0];
            
        case UISplitViewControllerSplitAppearncePrimaryOverlay:
        case UISplitViewControllerSplitAppearnceBoth:
            return [self _getAreaWithRangeFrom:0 to:self.primaryColumnWidth];
    }
}

- (CGRect)_getSecondaryViewControllerFrameWithSplitAppearnce:(UISplitViewControllerSplitAppearnce)splitAppearance
{
    switch (splitAppearance) {
        case UISplitViewControllerSplitAppearncePrimaryHidden:
        case UISplitViewControllerSplitAppearncePrimaryOverlay:
            return [self _getAreaWithRangeFrom:0 to:self.view.bounds.size.width];
            
        case UISplitViewControllerSplitAppearnceBoth:
            return [self _getAreaWithRangeFrom:self.primaryColumnWidth to:self.view.bounds.size.width];
    }
}

- (CGRect)_getSecondaryVisibleAreaWithSplitAppearance:(UISplitViewControllerSplitAppearnce)splitApperance
{
    switch (splitApperance) {
        case UISplitViewControllerSplitAppearncePrimaryHidden:
            return [self _getAreaWithRangeFrom:0 to:self.view.bounds.size.width];
            
        case UISplitViewControllerSplitAppearncePrimaryOverlay:
        case UISplitViewControllerSplitAppearnceBoth:
            return [self _getAreaWithRangeFrom:self.primaryColumnWidth to:self.view.bounds.size.width];
    }
}

- (void)_letViewController:(UIViewController *)viewController onStage:(BOOL)onStage withFrame:(CGRect)frame{
    if (viewController) {
        if (onStage) {
            viewController.view.frame = frame;
        }
        [self _synchronizeView:viewController.view onStage:onStage];
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
        if (view == _primaryViewController.view) {
            [self.view insertSubview:view aboveSubview:_secondaryViewController.view];
        } else if (view == _secondaryViewController.view) {
            [self.view insertSubview:view belowSubview:_primaryViewController.view];
        }
    } else if (!onStage && view.superview == self.view) {
        [view removeFromSuperview];
    }
}

- (void)_addSubview:(UIView *)subview withPositionOnViewControllers:(NSUInteger)index
{
    if (subview == _primaryViewController.view) {
        [self.view insertSubview:subview aboveSubview:_secondaryViewController.view];
    } else if (subview == _secondaryViewController.view) {
        [self.view insertSubview:subview belowSubview:_primaryViewController.view];
    }
}

#pragma mark - displayMode

- (void)setPreferredDisplayMode:(UISplitViewControllerDisplayMode)preferredDisplayMode
{
    if (_preferredDisplayMode != preferredDisplayMode) {
        _preferredDisplayMode = preferredDisplayMode;
        _displayMode = preferredDisplayMode;
        [self setSplitAppearance:[self _getSplitAppearanceWithDisplayMode:preferredDisplayMode]
                   tryToAnimated:NO];
    }
}

- (UIBarButtonItem *)displayModeButtonItem
{
    if (_displayModeButtonItem == nil) {
        _displayModeButtonItem = [self _createDisplayModeButtonItem];
    }
    return _displayModeButtonItem;
}

- (void)_makeSplitAppearanceChangeGesture
{
    [self.view addGestureRecognizer:[self _createTapGestureRecognizer]];
    [self.view addGestureRecognizer:[self _createSwipeGestureRecognizer]];
}

- (UITapGestureRecognizer *)_createTapGestureRecognizer
{
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc]
                                                    initWithTarget:self action:@selector(_onTappedSelf:)];
    tapGestureRecognizer.numberOfTapsRequired = 1;
    tapGestureRecognizer.numberOfTouchesRequired = 1;
    return tapGestureRecognizer;
}

- (UISwipeGestureRecognizer *)_createSwipeGestureRecognizer
{
    UISwipeGestureRecognizer *swipeGestureRecognizer = [[UISwipeGestureRecognizer alloc]
                                                      initWithTarget:self action:@selector(_onSwipeSelf:)];
    swipeGestureRecognizer.numberOfTouchesRequired = 1;
    return swipeGestureRecognizer;
}

- (UIBarButtonItem *)_createDisplayModeButtonItem
{
    return [[UIBarButtonItem alloc] initWithTitle:@"<<"
                                            style:UIBarButtonItemStyleBordered
                                           target:self
                                           action:@selector(_onTappedDisplayModeButtonItem:)];
}

- (void)_onTappedSelf:(UITapGestureRecognizer *)tapGestureRecognizer
{
    if (!self.collapsed && [self _isOperateAtVaildArea:tapGestureRecognizer]) {
        [self _hidePrimaryViewController];
    }
}

- (void)_onSwipeSelf:(UISwipeGestureRecognizer *)swipeGestureRecognizer
{
    if (self.collapsed && [self _isOperateAtVaildArea:swipeGestureRecognizer]) {
        [self _recoverPrimaryViewController];
    }
}

- (void)_onTappedDisplayModeButtonItem:(id)sender
{
    if (self.collapsed) {
        [self _recoverPrimaryViewController];
    } else {
        [self _hidePrimaryViewController];
    }
}

- (BOOL)_isOperateAtVaildArea:(UIGestureRecognizer *)gestureRecognizer
{
    CGPoint location = [gestureRecognizer locationInView:self.view];
    CGRect vaildArea = [self _getSecondaryVisibleAreaWithSplitAppearance:_splitAppearance];
    return CGRectContainsPoint(vaildArea, location);
}

- (void)_hidePrimaryViewController
{
    self.displayMode = UISplitViewControllerDisplayModePrimaryHidden;
    self.splitAppearance = UISplitViewControllerSplitAppearncePrimaryHidden;
}

- (void)_recoverPrimaryViewController
{
    NSLog(@"displayMode : %li when call %s", _preferredDisplayMode, __FUNCTION__);
    switch (_preferredDisplayMode) {
        case UISplitViewControllerDisplayModeAllVisible:
            self.displayMode = _preferredDisplayMode;
            self.splitAppearance = UISplitViewControllerSplitAppearnceBoth;
            break;
            
        case UISplitViewControllerDisplayModePrimaryOverlay:
        case UISplitViewControllerDisplayModeAutomatic:
            self.displayMode = _preferredDisplayMode;
            self.splitAppearance = UISplitViewControllerSplitAppearncePrimaryOverlay;
            break;
            
        case UISplitViewControllerDisplayModePrimaryHidden:
            self.displayMode = UISplitViewControllerDisplayModePrimaryOverlay;
            self.splitAppearance = UISplitViewControllerSplitAppearncePrimaryOverlay;
            break;
    }
}

#pragma mark - split appearance changes.

- (void)setSplitAppearance:(UISplitViewControllerSplitAppearnce)splitAppearance
{
    [self setSplitAppearance:splitAppearance tryToAnimated:YES];
}

- (void)setSplitAppearance:(UISplitViewControllerSplitAppearnce)splitAppearance tryToAnimated:(BOOL)animated
{
    if (_splitAppearance == splitAppearance) {
        return;
    }
    BOOL willNeedPlayAnimation = [self _willNeedPlayAnimationWhenChangeSplitAppearanceFrom:_splitAppearance
                                                                                        to:splitAppearance];
    _splitAppearance = splitAppearance;
    [self _refreshPrimaryColumnWidth];
    
    if (willNeedPlayAnimation && animated) {
        [UIView animateWithDuration:kChangeSplitAppearanceNeedTime animations:^{
            [self _synchronizeSubViewControllerAppearnce];
        }];
    } else {
        [self _synchronizeSubViewControllerAppearnce];
    }
}

- (BOOL)_willNeedPlayAnimationWhenChangeSplitAppearanceFrom:(UISplitViewControllerSplitAppearnce)oldSplitAppearance
                                                         to:(UISplitViewControllerSplitAppearnce)newSplitAppearance
{
    switch (oldSplitAppearance | newSplitAppearance) {
        case UISplitViewControllerSplitAppearncePrimaryHidden | UISplitViewControllerSplitAppearncePrimaryOverlay:
        case UISplitViewControllerSplitAppearncePrimaryHidden | UISplitViewControllerSplitAppearnceBoth:
            return YES;
        default:
            return NO;
    }
}

- (UISplitViewControllerSplitAppearnce)_getSplitAppearanceWithDisplayMode:(UISplitViewControllerDisplayMode)mode
{
    switch (mode) {
        case UISplitViewControllerDisplayModeAutomatic:
        case UISplitViewControllerDisplayModePrimaryOverlay:
            return UISplitViewControllerSplitAppearncePrimaryOverlay;
            
        case UISplitViewControllerDisplayModeAllVisible:
            return UISplitViewControllerSplitAppearnceBoth;
            
        case UISplitViewControllerDisplayModePrimaryHidden:
            return UISplitViewControllerSplitAppearncePrimaryHidden;
    }
}

- (UISplitViewController *)splitViewController
{
    return self;
}

@end
