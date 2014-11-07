//
//  UIViewControllerTransitioning.h
//  UIKit
//
//  Created by Chen Yonghui on 11/7/14.
//  Copyright (c) 2014 Shanghai Tinynetwork Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIViewController.h>
#import <UIKit/UIViewControllerTransitionCoordinator.h>

@class UIView;

UIKIT_EXTERN NSString *const UITransitionContextFromViewControllerKey;
UIKIT_EXTERN NSString *const UITransitionContextToViewControllerKey;

UIKIT_EXTERN NSString *const UITransitionContextFromViewKey;
UIKIT_EXTERN NSString *const UITransitionContextToViewKey;

@protocol UIViewControllerContextTransitioning <NSObject>

- (UIView *)containerView;

- (BOOL)isAnimated;

- (BOOL)isInteractive; // This indicates whether the transition is currently interactive.

- (BOOL)transitionWasCancelled;

- (UIModalPresentationStyle)presentationStyle;

- (void)updateInteractiveTransition:(CGFloat)percentComplete;
- (void)finishInteractiveTransition;
- (void)cancelInteractiveTransition;

- (void)completeTransition:(BOOL)didComplete;

- (UIViewController *)viewControllerForKey:(NSString *)key;

- (UIView *)viewForKey:(NSString *)key;// NS_AVAILABLE_IOS(8_0);

- (CGAffineTransform)targetTransform;// NS_AVAILABLE_IOS(8_0);

- (CGRect)initialFrameForViewController:(UIViewController *)vc;
- (CGRect)finalFrameForViewController:(UIViewController *)vc;
@end

@protocol UIViewControllerAnimatedTransitioning <NSObject>

- (NSTimeInterval)transitionDuration:(id <UIViewControllerContextTransitioning>)transitionContext;
- (void)animateTransition:(id <UIViewControllerContextTransitioning>)transitionContext;

@optional

- (void)animationEnded:(BOOL) transitionCompleted;

@end


@protocol UIViewControllerInteractiveTransitioning <NSObject>
- (void)startInteractiveTransition:(id <UIViewControllerContextTransitioning>)transitionContext;

@optional
- (CGFloat)completionSpeed;
- (UIViewAnimationCurve)completionCurve;

@end

@class UIPresentationController;

@protocol UIViewControllerTransitioningDelegate <NSObject>

@optional
- (id <UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source;

- (id <UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed;

- (id <UIViewControllerInteractiveTransitioning>)interactionControllerForPresentation:(id <UIViewControllerAnimatedTransitioning>)animator;

- (id <UIViewControllerInteractiveTransitioning>)interactionControllerForDismissal:(id <UIViewControllerAnimatedTransitioning>)animator;

- (UIPresentationController *)presentationControllerForPresentedViewController:(UIViewController *)presented presentingViewController:(UIViewController *)presenting sourceViewController:(UIViewController *)source;

@end

@interface UIPercentDrivenInteractiveTransition : NSObject <UIViewControllerInteractiveTransitioning>
@property (readonly) CGFloat duration;
@property (readonly) CGFloat percentComplete;
@property (nonatomic,assign) CGFloat completionSpeed;
@property (nonatomic,assign) UIViewAnimationCurve completionCurve;

- (void)updateInteractiveTransition:(CGFloat)percentComplete;
- (void)cancelInteractiveTransition;
- (void)finishInteractiveTransition;

@end

