//
//  UITabBarController.h
//  UIKit
//
//  Created by Chen Yonghui on 10/20/14.
//  Copyright (c) 2014 Shanghai Tinynetwork Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIViewController.h>
//#import <UIKit/UIViewControllerTransitioning.h>
#import <UIKit/UIKitDefines.h>
#import <UIKit/UITabBar.h>

@class UIView, UIImage, UINavigationController, UITabBarItem;
@protocol UITabBarControllerDelegate;

@interface UITabBarController : UIViewController <UITabBarDelegate, NSCoding>
@property(nonatomic,copy) NSArray *viewControllers;
- (void)setViewControllers:(NSArray *)viewControllers animated:(BOOL)animated;

@property(nonatomic,assign) UIViewController *selectedViewController;
@property(nonatomic) NSUInteger selectedIndex;

@property(nonatomic,readonly) UINavigationController *moreNavigationController;
@property(nonatomic,copy) NSArray *customizableViewControllers;
@property(nonatomic,readonly) UITabBar *tabBar;

@property(nonatomic,assign) id<UITabBarControllerDelegate> delegate;

@end

@protocol UITabBarControllerDelegate <NSObject>
@optional
- (BOOL)tabBarController:(UITabBarController *)tabBarController shouldSelectViewController:(UIViewController *)viewController;
- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController;

- (void)tabBarController:(UITabBarController *)tabBarController willBeginCustomizingViewControllers:(NSArray *)viewControllers;
- (void)tabBarController:(UITabBarController *)tabBarController willEndCustomizingViewControllers:(NSArray *)viewControllers changed:(BOOL)changed;
- (void)tabBarController:(UITabBarController *)tabBarController didEndCustomizingViewControllers:(NSArray *)viewControllers changed:(BOOL)changed;

- (NSUInteger)tabBarControllerSupportedInterfaceOrientations:(UITabBarController *)tabBarController;
- (UIInterfaceOrientation)tabBarControllerPreferredInterfaceOrientationForPresentation:(UITabBarController *)tabBarController;

//- (id <UIViewControllerInteractiveTransitioning>)tabBarController:(UITabBarController *)tabBarController
//                      interactionControllerForAnimationController: (id <UIViewControllerAnimatedTransitioning>)animationController;

//- (id <UIViewControllerAnimatedTransitioning>)tabBarController:(UITabBarController *)tabBarController
//            animationControllerForTransitionFromViewController:(UIViewController *)fromVC
//                                              toViewController:(UIViewController *)toVC;

@end

@interface UIViewController (UITabBarControllerItem)

@property(nonatomic,retain) UITabBarItem *tabBarItem; // Automatically created lazily with the view controller's title if it's not set explicitly.

@property(nonatomic,readonly,retain) UITabBarController *tabBarController; // If the view controller has a tab bar controller as its ancestor, return it. Returns nil otherwise.

@end

