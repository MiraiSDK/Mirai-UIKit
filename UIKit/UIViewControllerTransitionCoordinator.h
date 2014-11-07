//
//  UIViewControllerTransitionCoordinator.h
//  UIKit
//
//  Created by Chen Yonghui on 11/7/14.
//  Copyright (c) 2014 Shanghai Tinynetwork Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIViewController.h>

@protocol UIViewControllerTransitionCoordinatorContext <NSObject>

- (BOOL)isAnimated;

- (UIModalPresentationStyle)presentationStyle;

- (BOOL)initiallyInteractive;

- (BOOL)isInteractive;

- (BOOL)isCancelled;

- (NSTimeInterval)transitionDuration;

- (CGFloat)percentComplete;
- (CGFloat)completionVelocity;
- (UIViewAnimationCurve)completionCurve;

- (UIViewController *)viewControllerForKey:(NSString *)key;

- (UIView *)viewForKey:(NSString *)key;// NS_AVAILABLE_IOS(8_0);

- (UIView *)containerView;

- (CGAffineTransform)targetTransform;// NS_AVAILABLE_IOS(8_0);

@end

@protocol UIViewControllerTransitionCoordinator <UIViewControllerTransitionCoordinatorContext>

- (BOOL)animateAlongsideTransition:(void (^)(id <UIViewControllerTransitionCoordinatorContext>context))animation
                        completion:(void (^)(id <UIViewControllerTransitionCoordinatorContext>context))completion;

- (BOOL)animateAlongsideTransitionInView:(UIView *)view
                               animation:(void (^)(id <UIViewControllerTransitionCoordinatorContext>context))animation
                              completion:(void (^)(id <UIViewControllerTransitionCoordinatorContext>context))completion;

- (void)notifyWhenInteractionEndsUsingBlock: (void (^)(id <UIViewControllerTransitionCoordinatorContext>context))handler;

@end

@interface UIViewController(UIViewControllerTransitionCoordinator)
- (id <UIViewControllerTransitionCoordinator>)transitionCoordinator;// NS_AVAILABLE_IOS(7_0);
@end
