//
//  UIPopoverController.h
//  UIKit
//
//  Created by Chen Yonghui on 5/2/14.
//  Copyright (c) 2014 Shanghai Tinynetwork Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreGraphics/CoreGraphics.h>
#import <UIKit/UIKitDefines.h>
#import <UIKit/UIApplication.h>
#import <UIKit/UIViewController.h>
#import <UIKit/UIAppearance.h>
#import <UIKit/UIGeometry.h>

@class UIBarButtonItem, UIView;
@protocol UIPopoverControllerDelegate;

typedef NS_OPTIONS(NSUInteger, UIPopoverArrowDirection) {
    UIPopoverArrowDirectionUp = 1UL << 0,
    UIPopoverArrowDirectionDown = 1UL << 1,
    UIPopoverArrowDirectionLeft = 1UL << 2,
    UIPopoverArrowDirectionRight = 1UL << 3,
    UIPopoverArrowDirectionAny = UIPopoverArrowDirectionUp | UIPopoverArrowDirectionDown | UIPopoverArrowDirectionLeft | UIPopoverArrowDirectionRight,
    UIPopoverArrowDirectionUnknown = NSUIntegerMax
};

@interface UIPopoverController : NSObject <UIAppearanceContainer>

- (id)initWithContentViewController:(UIViewController *)viewController;

@property (nonatomic, assign) id <UIPopoverControllerDelegate> delegate;
@property (nonatomic, retain) UIViewController *contentViewController;
- (void)setContentViewController:(UIViewController *)viewController animated:(BOOL)animated;
@property (nonatomic) CGSize popoverContentSize;
- (void)setPopoverContentSize:(CGSize)size animated:(BOOL)animated;
@property (nonatomic, readonly, getter=isPopoverVisible) BOOL popoverVisible;
@property (nonatomic, readonly) UIPopoverArrowDirection popoverArrowDirection;
@property (nonatomic, copy) NSArray *passthroughViews;
- (void)presentPopoverFromRect:(CGRect)rect inView:(UIView *)view permittedArrowDirections:(UIPopoverArrowDirection)arrowDirections animated:(BOOL)animated;
- (void)presentPopoverFromBarButtonItem:(UIBarButtonItem *)item permittedArrowDirections:(UIPopoverArrowDirection)arrowDirections animated:(BOOL)animated;
- (void)dismissPopoverAnimated:(BOOL)animated;

@property (nonatomic, copy) UIColor *backgroundColor;// NS_AVAILABLE_IOS(7_0);
@property (nonatomic, readwrite) UIEdgeInsets popoverLayoutMargins;
@property (nonatomic, readwrite, retain) Class popoverBackgroundViewClass;

@end

@protocol UIPopoverControllerDelegate <NSObject>
@optional
- (BOOL)popoverControllerShouldDismissPopover:(UIPopoverController *)popoverController;
- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController;
- (void)popoverController:(UIPopoverController *)popoverController willRepositionPopoverToRect:(inout CGRect *)rect inView:(inout UIView **)view;// NS_AVAILABLE_IOS(7_0);

@end

@interface UIViewController (UIPopoverController)

@property (nonatomic,readwrite,getter=isModalInPopover) BOOL modalInPopover;
@property (nonatomic,readwrite) CGSize contentSizeForViewInPopover;// NS_DEPRECATED_IOS(3_2, 7_0, "Use UIViewController.preferredContentSize instead.");

@end

