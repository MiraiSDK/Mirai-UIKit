//
//  UIViewController.h
//  UIKit
//
//  Created by Chen Yonghui on 2/11/14.
//  Copyright (c) 2014 Shanghai Tinynetwork Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKitDefines.h>
#import <UIKit/UIApplication.h>
//#import <UIKit/UIStateRestoration.h>
#import <UIKit/UIGeometry.h>

@class UIView;
@class UINavigationItem, UIBarButtonItem, UITabBarItem;
@class UISearchDisplayController;
@class UIPopoverController;
@class UIStoryboard, UIStoryboardSegue;
@class UIScrollView;

typedef NS_ENUM(NSInteger, UIModalTransitionStyle) {
    UIModalTransitionStyleCoverVertical = 0,
    UIModalTransitionStyleFlipHorizontal,
    UIModalTransitionStyleCrossDissolve,
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_3_2
    UIModalTransitionStylePartialCurl,
#endif
};

typedef NS_ENUM(NSInteger, UIModalPresentationStyle) {
    UIModalPresentationFullScreen = 0,
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_3_2
    UIModalPresentationPageSheet,
    UIModalPresentationFormSheet,
    UIModalPresentationCurrentContext,
#endif
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_7_0
    UIModalPresentationCustom,
    UIModalPresentationNone = -1,
#endif
};


@interface UIViewController : UIResponder <NSCoding> //, UIAppearanceContainer>
{
    @package
    UINavigationItem *_navigationItem;
    __weak UIViewController *_parentViewController; // Nonretained

}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil;
@property(nonatomic,retain) UIView *view;
- (void)loadView;

- (void)viewDidLoad;
- (BOOL)isViewLoaded;

- (void)viewWillUnload;// NS_DEPRECATED_IOS(5_0,6_0);
- (void)viewDidUnload;// NS_DEPRECATED_IOS(3_0,6_0);

@property(nonatomic, readonly, copy) NSString *nibName;
@property(nonatomic, readonly, retain) NSBundle *nibBundle;
@property(nonatomic, readonly, retain) UIStoryboard *storyboard;

- (void)performSegueWithIdentifier:(NSString *)identifier sender:(id)sender;
- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender;
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender;
- (BOOL)canPerformUnwindSegueAction:(SEL)action fromViewController:(UIViewController *)fromViewController withSender:(id)sender;
- (UIViewController *)viewControllerForUnwindSegueAction:(SEL)action fromViewController:(UIViewController *)fromViewController withSender:(id)sender;
- (UIStoryboardSegue *)segueForUnwindingToViewController:(UIViewController *)toViewController fromViewController:(UIViewController *)fromViewController identifier:(NSString *)identifier;

- (void)viewWillAppear:(BOOL)animated;
- (void)viewDidAppear:(BOOL)animated;
- (void)viewWillDisappear:(BOOL)animated;
- (void)viewDidDisappear:(BOOL)animated;

- (void)viewWillLayoutSubviews;
- (void)viewDidLayoutSubviews;

@property(nonatomic,copy) NSString *title;
- (void)didReceiveMemoryWarning;

@property(nonatomic,readonly) UIViewController *parentViewController;

@property(nonatomic,readonly) UIViewController *modalViewController; //NS_DEPRECATED_IOS(2_0, 6_0);

@property(nonatomic,readonly) UIViewController *presentedViewController;
@property(nonatomic,readonly) UIViewController *presentingViewController;

@property(nonatomic,assign) BOOL definesPresentationContext;
@property(nonatomic,assign) BOOL providesPresentationContextTransitionStyle;

- (BOOL)isBeingPresented;
- (BOOL)isBeingDismissed;

- (BOOL)isMovingToParentViewController;
- (BOOL)isMovingFromParentViewController;

- (void)presentViewController:(UIViewController *)viewControllerToPresent animated: (BOOL)flag completion:(void (^)(void))completion;
- (void)dismissViewControllerAnimated: (BOOL)flag completion: (void (^)(void))completion;

- (void)presentModalViewController:(UIViewController *)modalViewController animated:(BOOL)animated;// NS_DEPRECATED_IOS(2_0, 6_0);

- (void)dismissModalViewControllerAnimated:(BOOL)animated;// NS_DEPRECATED_IOS(2_0, 6_0);

@property(nonatomic,assign) UIModalTransitionStyle modalTransitionStyle;
@property(nonatomic,assign) UIModalPresentationStyle modalPresentationStyle;

@property(nonatomic,assign) BOOL modalPresentationCapturesStatusBarAppearance;// NS_AVAILABLE_IOS(7_0);

- (BOOL)disablesAutomaticKeyboardDismissal;

@property(nonatomic,assign) BOOL wantsFullScreenLayout;// NS_DEPRECATED_IOS(3_0, 7_0);
@property(nonatomic,assign) UIRectEdge edgesForExtendedLayout;// NS_AVAILABLE_IOS(7_0);
@property(nonatomic,assign) BOOL extendedLayoutIncludesOpaqueBars;// NS_AVAILABLE_IOS(7_0);
@property(nonatomic,assign) BOOL automaticallyAdjustsScrollViewInsets;// NS_AVAILABLE_IOS(7_0);

@property (nonatomic) CGSize preferredContentSize;// NS_AVAILABLE_IOS(7_0);

- (UIStatusBarStyle)preferredStatusBarStyle;// NS_AVAILABLE_IOS(7_0);
- (BOOL)prefersStatusBarHidden;// NS_AVAILABLE_IOS(7_0);
- (UIStatusBarAnimation)preferredStatusBarUpdateAnimation;// NS_AVAILABLE_IOS(7_0);

- (void)setNeedsStatusBarAppearanceUpdate;// NS_AVAILABLE_IOS(7_0);

@end

@interface UIViewController (UIViewControllerEditing)
@property(nonatomic,getter=isEditing) BOOL editing;
- (void)setEditing:(BOOL)editing animated:(BOOL)animated;
@end

@interface UIViewController (UISearchDisplayControllerSupport)

@property(nonatomic, readonly, retain) UISearchDisplayController *searchDisplayController;

@end

UIKIT_EXTERN NSString *const UIViewControllerHierarchyInconsistencyException;

@interface UIViewController (UIContainerViewControllerProtectedMethods)
@property(nonatomic,readonly) NSArray *childViewControllers;
- (void)addChildViewController:(UIViewController *)childController;
- (void) removeFromParentViewController;
- (void)transitionFromViewController:(UIViewController *)fromViewController toViewController:(UIViewController *)toViewController duration:(NSTimeInterval)duration options:(UIViewAnimationOptions)options animations:(void (^)(void))animations completion:(void (^)(BOOL finished))completion;
- (void)beginAppearanceTransition:(BOOL)isAppearing animated:(BOOL)animated;
- (void)endAppearanceTransition;

- (UIViewController *)childViewControllerForStatusBarStyle;// NS_AVAILABLE_IOS(7_0);
- (UIViewController *)childViewControllerForStatusBarHidden;// NS_AVAILABLE_IOS(7_0);

@end

@interface UIViewController (UIViewControllerRotation)

+ (void)attemptRotationToDeviceOrientation;

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation;// NS_DEPRECATED_IOS(2_0, 6_0);

- (BOOL)shouldAutorotate;
- (NSUInteger)supportedInterfaceOrientations;
- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation;

- (UIView *)rotatingHeaderView;
- (UIView *)rotatingFooterView;

@property(nonatomic,readonly) UIInterfaceOrientation interfaceOrientation;

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration;
- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation;

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration;

- (void)willAnimateFirstHalfOfRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration;
- (void)didAnimateFirstHalfOfRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation;
- (void)willAnimateSecondHalfOfRotationFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation duration:(NSTimeInterval)duration;

@end

@interface UIViewController (UIContainerViewControllerCallbacks)
- (BOOL)automaticallyForwardAppearanceAndRotationMethodsToChildViewControllers; // NS_DEPRECATED_IOS(5_0,6_0);
- (BOOL)shouldAutomaticallyForwardRotationMethods;
- (BOOL)shouldAutomaticallyForwardAppearanceMethods;

- (void)willMoveToParentViewController:(UIViewController *)parent;
- (void)didMoveToParentViewController:(UIViewController *)parent;

@end

//@interface UIViewController (UIStateRestoration) <UIStateRestoring>
//@property (nonatomic, copy) NSString *restorationIdentifier;
//@property (nonatomic, readwrite, assign) Class<UIViewControllerRestoration> restorationClass;
//- (void) encodeRestorableStateWithCoder:(NSCoder *)coder;
//- (void) decodeRestorableStateWithCoder:(NSCoder *)coder;
//- (void) applicationFinishedRestoringState;// NS_AVAILABLE_IOS(7_0);
//@end

@interface UIViewController (UIConstraintBasedLayoutCoreMethods)
- (void)updateViewConstraints;
@end

@protocol UIViewControllerTransitioningDelegate;

@interface UIViewController(CustomTransitioning)

@property (nonatomic,assign) id <UIViewControllerTransitioningDelegate> transitioningDelegate;// NS_AVAILABLE_IOS(7_0);

@end

//@interface UIViewController (UILayoutSupport)
//@property(nonatomic,readonly,retain) id<UILayoutSupport> topLayoutGuide;// NS_AVAILABLE_IOS(7_0);
//@property(nonatomic,readonly,retain) id<UILayoutSupport> bottomLayoutGuide;// NS_AVAILABLE_IOS(7_0);
//@end




