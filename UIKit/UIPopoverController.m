//
//  UIPopoverController.m
//  UIKit
//
//  Created by Chen Yonghui on 5/2/14.
//  Copyright (c) 2014 Shanghai Tinynetwork Inc. All rights reserved.
//

#import "UIPopoverController.h"
#import "UITopFloatViewDelegate.h"
#import "UITopFloatView.h"
#import "UIPositionOnRect.h"
#import "UIPopoverFloatView.h"
#import "UIPositionOnRect.h"
#import <UIKit/UIKit.h>

#define kMinimumPopoverWidth 320
#define kMaximumPopoverWidth 600

@interface UIPopoverController () <UITouchMask>
{
    UIPopoverFloatView *_floatView;
}
@end

@implementation UIPopoverController

- (id)initWithContentViewController:(UIViewController *)viewController
{
    self = [super init];
    if (self) {
        _contentViewController = viewController;
        _floatView = [[UIPopoverFloatView alloc] initWithParent:self withContainer:viewController.view];
        _floatView.delegate = self;
        [self _settingDefaultValues];
    }
    return self;
}

- (void)_settingDefaultValues
{
    _popoverContentSize = CGSizeMake(320, 320);
    _floatView.containerSize = _popoverContentSize;
}

- (BOOL)isPopoverVisible
{
    return _floatView.visible;
}

- (UIPopoverArrowDirection)popoverArrowDirection
{
    if (!self.popoverVisible) {
        return UIPopoverArrowDirectionUnknown;
    }
    switch (_floatView.arrowPossitionOnRect.borderDirection) {
        case UIPositionOnRectDirectionUp:
            return UIPopoverArrowDirectionUp;
            
        case UIPositionOnRectDirectionDown:
            return UIPopoverArrowDirectionDown;
            
        case UIPositionOnRectDirectionLeft:
            return UIPopoverArrowDirectionLeft;
            
        case UIPositionOnRectDirectionRight:
            return UIPopoverArrowDirectionRight;
            
        default:
            return UIPositionOnRectDirectionUnknow;
    }
}

- (void)setContentViewController:(UIViewController *)viewController animated:(BOOL)animated;
{
    if (_contentViewController != viewController) {
        _contentViewController = viewController;
        [_floatView setContainer:viewController.view animated:animated];
        [self setPopoverContentSize:viewController.view.frame.size];
    }
}

- (void)setPopoverContentSize:(CGSize)size animated:(BOOL)animated
{
    size.width = MAX(MIN(size.width, kMaximumPopoverWidth), kMinimumPopoverWidth);
    if (!CGSizeEqualToSize(_popoverContentSize, size)) {
        _popoverContentSize = size;
        [_floatView setContainerSize:size];
    }
}

- (void)presentPopoverFromRect:(CGRect)rect inView:(UIView *)view
      permittedArrowDirections:(UIPopoverArrowDirection)arrowDirections animated:(BOOL)animated
{
    [_delegate popoverController:self willRepositionPopoverToRect:&rect inView:&view];
    _floatView.presentArrowDirections = arrowDirections;
    _floatView.floatCloseToTarget = [view convertRect:rect toView:[[UIApplication sharedApplication] keyWindow]];
    [_floatView setVisible:YES animated:animated];
}

- (void)presentPopoverFromBarButtonItem:(UIBarButtonItem *)item permittedArrowDirections:(UIPopoverArrowDirection)arrowDirections animated:(BOOL)animated
{
    
}

- (void)dismissPopoverAnimated:(BOOL)animated
{
    [_floatView setVisible:NO animated:animated];
}

- (void)floatViewWillAppear:(BOOL)animated
{
    [_contentViewController viewWillAppear:animated];
}

- (void)floatViewDidAppear:(BOOL)animated
{
    [_contentViewController viewDidAppear:animated];
}

- (void)floatViewWillDisappear:(BOOL)animated
{
    [_contentViewController viewWillDisappear:animated];
}

- (void)floatViewDidDisappear:(BOOL)animated
{
    [_contentViewController viewDidDisappear:animated];
    [_delegate popoverControllerDidDismissPopover:self];
}

@end