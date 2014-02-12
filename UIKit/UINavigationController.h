//
//  UINavigationController.h
//  UIKit
//
//  Created by Chen Yonghui on 2/12/14.
//  Copyright (c) 2014 Shanghai Tinynetwork Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreGraphics/CoreGraphics.h>
#import <UIKit/UIViewController.h>
#import <UIKit/UIKitDefines.h>
#import <UIKit/UIInterface.h>
#import <UIKit/UIGeometry.h>

typedef NS_ENUM(NSInteger, UINavigationControllerOperation) {
    UINavigationControllerOperationNone,
    UINavigationControllerOperationPush,
    UINavigationControllerOperationPop,
};

UIKIT_EXTERN const CGFloat UINavigationControllerHideShowBarDuration;

@class UIView, UINavigationBar, UINavigationItem, UIToolbar, UILayoutContainerView;
@protocol UINavigationControllerDelegate;

@interface UINavigationController : UIViewController
- (instancetype)initWithNavigationBarClass:(Class)navigationBarClass toolbarClass:(Class)toolbarClass;
- (id)initWithRootViewController:(UIViewController *)rootViewController;

- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated;

- (UIViewController *)popViewControllerAnimated:(BOOL)animated;
- (NSArray *)popToViewController:(UIViewController *)viewController animated:(BOOL)animated;
- (NSArray *)popToRootViewControllerAnimated:(BOOL)animated;

@property(nonatomic,readonly,retain) UIViewController *topViewController;
@property(nonatomic,readonly,retain) UIViewController *visibleViewController;

@property(nonatomic,copy) NSArray *viewControllers;
- (void)setViewControllers:(NSArray *)viewControllers animated:(BOOL)animated;

@property(nonatomic,getter=isNavigationBarHidden) BOOL navigationBarHidden;
- (void)setNavigationBarHidden:(BOOL)hidden animated:(BOOL)animated;
@property(nonatomic,readonly) UINavigationBar *navigationBar;

@property(nonatomic,getter=isToolbarHidden) BOOL toolbarHidden;
- (void)setToolbarHidden:(BOOL)hidden animated:(BOOL)animated;
@property(nonatomic,readonly) UIToolbar *toolbar;

@property(nonatomic, assign) id<UINavigationControllerDelegate> delegate;
@property(nonatomic, readonly) UIGestureRecognizer *interactivePopGestureRecognizer;// NS_AVAILABLE_IOS(7_0);

@end

@protocol UIViewControllerInteractiveTransitioning;
@protocol UIViewControllerAnimatedTransitioning;

@protocol UINavigationControllerDelegate <NSObject>

@optional

- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated;
- (void)navigationController:(UINavigationController *)navigationController didShowViewController:(UIViewController *)viewController animated:(BOOL)animated;

- (NSUInteger)navigationControllerSupportedInterfaceOrientations:(UINavigationController *)navigationController;// NS_AVAILABLE_IOS(7_0);
- (UIInterfaceOrientation)navigationControllerPreferredInterfaceOrientationForPresentation:(UINavigationController *)navigationController;// NS_AVAILABLE_IOS(7_0);

- (id <UIViewControllerInteractiveTransitioning>)navigationController:(UINavigationController *)navigationController
                          interactionControllerForAnimationController:(id <UIViewControllerAnimatedTransitioning>) animationController;// NS_AVAILABLE_IOS(7_0);

- (id <UIViewControllerAnimatedTransitioning>)navigationController:(UINavigationController *)navigationController
                                   animationControllerForOperation:(UINavigationControllerOperation)operation
                                                fromViewController:(UIViewController *)fromVC
                                                  toViewController:(UIViewController *)toVC;//  NS_AVAILABLE_IOS(7_0);

@end

@interface UIViewController (UINavigationControllerItem)

@property(nonatomic,readonly,retain) UINavigationItem *navigationItem; // Created on-demand so that a view controller may customize its navigation appearance.
@property(nonatomic) BOOL hidesBottomBarWhenPushed; // If YES, then when this view controller is pushed into a controller hierarchy with a bottom bar (like a tab bar), the bottom bar will slide out. Default is NO.
@property(nonatomic,readonly,retain) UINavigationController *navigationController; // If this view controller has been pushed onto a navigation controller, return it.

@end

@interface UIViewController (UINavigationControllerContextualToolbarItems)

@property (nonatomic, retain) NSArray *toolbarItems;
- (void)setToolbarItems:(NSArray *)toolbarItems animated:(BOOL)animated;

@end
