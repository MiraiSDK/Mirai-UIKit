//
//  UIPageViewController.h
//  UIKit
//
//  Created by Chen Yonghui on 11/7/14.
//  Copyright (c) 2014 Shanghai Tinynetwork Inc. All rights reserved.
//

#import <UIKit/UIViewController.h>

typedef NS_ENUM(NSInteger, UIPageViewControllerNavigationOrientation) {
    UIPageViewControllerNavigationOrientationHorizontal = 0,
    UIPageViewControllerNavigationOrientationVertical = 1
};

typedef NS_ENUM(NSInteger, UIPageViewControllerSpineLocation) {
    UIPageViewControllerSpineLocationNone = 0, // Returned if 'spineLocation' is queried when 'transitionStyle' is not 'UIPageViewControllerTransitionStylePageCurl'.
    UIPageViewControllerSpineLocationMin = 1,  // Requires one view controller.
    UIPageViewControllerSpineLocationMid = 2,  // Requires two view controllers.
    UIPageViewControllerSpineLocationMax = 3   // Requires one view controller.
};   // Only pertains to 'UIPageViewControllerTransitionStylePageCurl'.

typedef NS_ENUM(NSInteger, UIPageViewControllerNavigationDirection) {
    UIPageViewControllerNavigationDirectionForward,
    UIPageViewControllerNavigationDirectionReverse
};

typedef NS_ENUM(NSInteger, UIPageViewControllerTransitionStyle) {
    UIPageViewControllerTransitionStylePageCurl = 0, // Navigate between views via a page curl transition.
    UIPageViewControllerTransitionStyleScroll = 1 // Navigate between views by scrolling.
};

UIKIT_EXTERN NSString * const UIPageViewControllerOptionSpineLocationKey;
UIKIT_EXTERN NSString * const UIPageViewControllerOptionInterPageSpacingKey;

@protocol UIPageViewControllerDelegate, UIPageViewControllerDataSource;

@interface UIPageViewController : UIViewController
- (instancetype)initWithTransitionStyle:(UIPageViewControllerTransitionStyle)style navigationOrientation:(UIPageViewControllerNavigationOrientation)navigationOrientation options:(NSDictionary *)options;

@property (nonatomic, assign) id <UIPageViewControllerDelegate> delegate;
@property (nonatomic, assign) id <UIPageViewControllerDataSource> dataSource; // If nil, user gesture-driven navigation will be disabled.
@property (nonatomic, readonly) UIPageViewControllerTransitionStyle transitionStyle;
@property (nonatomic, readonly) UIPageViewControllerNavigationOrientation navigationOrientation;
@property (nonatomic, readonly) UIPageViewControllerSpineLocation spineLocation;

@property (nonatomic, getter=isDoubleSided) BOOL doubleSided; // Default is 'NO'.

@property(nonatomic, readonly) NSArray *gestureRecognizers;

@property (nonatomic, readonly) NSArray *viewControllers;

- (void)setViewControllers:(NSArray *)viewControllers direction:(UIPageViewControllerNavigationDirection)direction animated:(BOOL)animated completion:(void (^)(BOOL finished))completion;

@end

@protocol UIPageViewControllerDelegate <NSObject>

@optional

- (void)pageViewController:(UIPageViewController *)pageViewController willTransitionToViewControllers:(NSArray *)pendingViewControllers;

- (void)pageViewController:(UIPageViewController *)pageViewController didFinishAnimating:(BOOL)finished previousViewControllers:(NSArray *)previousViewControllers transitionCompleted:(BOOL)completed;

- (UIPageViewControllerSpineLocation)pageViewController:(UIPageViewController *)pageViewController spineLocationForInterfaceOrientation:(UIInterfaceOrientation)orientation;

- (NSUInteger)pageViewControllerSupportedInterfaceOrientations:(UIPageViewController *)pageViewController;
- (UIInterfaceOrientation)pageViewControllerPreferredInterfaceOrientationForPresentation:(UIPageViewController *)pageViewController;

@end

@protocol UIPageViewControllerDataSource <NSObject>

@required
- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController;
- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController;

@optional
- (NSInteger)presentationCountForPageViewController:(UIPageViewController *)pageViewController;
- (NSInteger)presentationIndexForPageViewController:(UIPageViewController *)pageViewController;

@end
