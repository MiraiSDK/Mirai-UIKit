//
//  UISplitViewController.h
//  UIKit
//
//  Created by Chen Yonghui on 11/4/14.
//  Copyright (c) 2014 Shanghai Tinynetwork Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol UISplitViewControllerDelegate;

typedef NS_ENUM(NSInteger, UISplitViewControllerDisplayMode) {
    UISplitViewControllerDisplayModeAutomatic,
    UISplitViewControllerDisplayModePrimaryHidden,
    UISplitViewControllerDisplayModeAllVisible,
    UISplitViewControllerDisplayModePrimaryOverlay,
};// NS_ENUM_AVAILABLE_IOS(8_0);

UIKIT_EXTERN CGFloat const UISplitViewControllerAutomaticDimension;// NS_AVAILABLE_IOS(8_0);

@interface UISplitViewController : UIViewController
@property (nonatomic, copy) NSArray *viewControllers;
@property (nonatomic, assign) id <UISplitViewControllerDelegate> delegate;

@property (nonatomic) BOOL presentsWithGesture;

@property(nonatomic, readonly, getter=isCollapsed) BOOL collapsed;// NS_AVAILABLE_IOS(8_0);

@property (nonatomic) UISplitViewControllerDisplayMode preferredDisplayMode;// NS_AVAILABLE_IOS(8_0);

@property (nonatomic, readonly) UISplitViewControllerDisplayMode displayMode;// NS_AVAILABLE_IOS(8_0);

- (UIBarButtonItem *)displayModeButtonItem;// NS_AVAILABLE_IOS(8_0);

@property(nonatomic, assign) CGFloat preferredPrimaryColumnWidthFraction;// NS_AVAILABLE_IOS(8_0);

@property(nonatomic, assign) CGFloat minimumPrimaryColumnWidth;// NS_AVAILABLE_IOS(8_0);
@property(nonatomic, assign) CGFloat maximumPrimaryColumnWidth;// NS_AVAILABLE_IOS(8_0);

@property(nonatomic,readonly) CGFloat primaryColumnWidth;// NS_AVAILABLE_IOS(8_0);

- (void)showViewController:(UIViewController *)vc sender:(id)sender;// NS_AVAILABLE_IOS(8_0);

- (void)showDetailViewController:(UIViewController *)vc sender:(id)sender;// NS_AVAILABLE_IOS(8_0);

@end

@protocol UISplitViewControllerDelegate

@optional

// This method allows a client to update any bar button items etc.
- (void)splitViewController:(UISplitViewController *)svc willChangeToDisplayMode:(UISplitViewControllerDisplayMode)displayMode;// NS_AVAILABLE_IOS(8_0);

// Called by the gesture AND barButtonItem to determine what they will set the display mode to (and what the displayModeButtonItem's appearance will be.) Return UISplitViewControllerDisplayModeAutomatic to get the default behavior.
- (UISplitViewControllerDisplayMode)targetDisplayModeForActionInSplitViewController:(UISplitViewController *)svc;// NS_AVAILABLE_IOS(8_0);

// Override this method to customize the behavior of `showViewController:` on a split view controller. Return YES to indicate that you've handled
// the action yourself; return NO to cause the default behavior to be executed.
- (BOOL)splitViewController:(UISplitViewController *)splitViewController showViewController:(UIViewController *)vc sender:(id)sender;// NS_AVAILABLE_IOS(8_0);

// Override this method to customize the behavior of `showDetailViewController:` on a split view controller. Return YES to indicate that you've
// handled the action yourself; return NO to cause the default behavior to be executed.
- (BOOL)splitViewController:(UISplitViewController *)splitViewController showDetailViewController:(UIViewController *)vc sender:(id)sender;// NS_AVAILABLE_IOS(8_0);

- (UIViewController *)primaryViewControllerForCollapsingSplitViewController:(UISplitViewController *)splitViewController;// NS_AVAILABLE_IOS(8_0);

- (UIViewController *)primaryViewControllerForExpandingSplitViewController:(UISplitViewController *)splitViewController;// NS_AVAILABLE_IOS(8_0);

- (BOOL)splitViewController:(UISplitViewController *)splitViewController collapseSecondaryViewController:(UIViewController *)secondaryViewController ontoPrimaryViewController:(UIViewController *)primaryViewController;// NS_AVAILABLE_IOS(8_0);

- (UIViewController *)splitViewController:(UISplitViewController *)splitViewController separateSecondaryViewControllerFromPrimaryViewController:(UIViewController *)primaryViewController;// NS_AVAILABLE_IOS(8_0);

- (NSUInteger)splitViewControllerSupportedInterfaceOrientations:(UISplitViewController *)splitViewController;// NS_AVAILABLE_IOS(7_0);
- (UIInterfaceOrientation)splitViewControllerPreferredInterfaceOrientationForPresentation:(UISplitViewController *)splitViewController;// NS_AVAILABLE_IOS(7_0);

- (void)splitViewController:(UISplitViewController *)svc willHideViewController:(UIViewController *)aViewController withBarButtonItem:(UIBarButtonItem *)barButtonItem forPopoverController:(UIPopoverController *)pc;// NS_DEPRECATED_IOS(2_0, 8_0, "Use splitViewController:willChangeToDisplayMode: and displayModeButtonItem instead");

- (void)splitViewController:(UISplitViewController *)svc willShowViewController:(UIViewController *)aViewController invalidatingBarButtonItem:(UIBarButtonItem *)barButtonItem;// NS_DEPRECATED_IOS(2_0, 8_0, "Use splitViewController:willChangeToDisplayMode: and displayModeButtonItem instead");

- (void)splitViewController:(UISplitViewController *)svc popoverController:(UIPopoverController *)pc willPresentViewController:(UIViewController *)aViewController;// NS_DEPRECATED_IOS(2_0, 8_0, "Use splitViewController:willChangeToDisplayMode: instead");

- (BOOL)splitViewController:(UISplitViewController *)svc shouldHideViewController:(UIViewController *)vc inOrientation:(UIInterfaceOrientation)orientation;  //NS_DEPRECATED_IOS(5_0, 8_0, "Use preferredDisplayMode instead");


@end

@interface UIViewController (UISplitViewController)

@property (nonatomic, readonly, retain) UISplitViewController *splitViewController;


//- (void)collapseSecondaryViewController:(UIViewController *)secondaryViewController forSplitViewController:(UISplitViewController *)splitViewController NS_AVAILABLE_IOS(8_0);

//- (UIViewController *)separateSecondaryViewControllerForSplitViewController:(UISplitViewController *)splitViewController NS_AVAILABLE_IOS(8_0);

@end
