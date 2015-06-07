//
//  UIPopoverController.m
//  UIKit
//
//  Created by Chen Yonghui on 5/2/14.
//  Copyright (c) 2014 Shanghai Tinynetwork Inc. All rights reserved.
//

#import "UIPopoverController.h"
#import "UITopFloatView.h"
#import "UIPositionOnRect.h"
#import "UIPopoverFloatView.h"
#import <UIKit/UIKit.h>

#define kMinimumPopoverWidth 320
#define kMaximumPopoverWidth 600

@implementation UIPopoverController
{
    UIPopoverFloatView *_floatView;
}

- (id)initWithContentViewController:(UIViewController *)viewController
{
    self = [super init];
    if (self) {
        _contentViewController = viewController;
        _floatView = [[UIPopoverFloatView alloc] initWithParent:self withContainer:viewController.view];
        [self _settingDefaultValues];
    }
    return self;
}

- (void)_settingDefaultValues
{
    _popoverContentSize = CGSizeMake(320, 320);
    _floatView.containerSize = _popoverContentSize;
    _popoverArrowDirection = UIPopoverArrowDirectionUnknown;
}

- (void)setContentViewController:(UIViewController *)viewController animated:(BOOL)animated;
{
    if (_contentViewController != viewController) {
        _contentViewController = viewController;
        _floatView.container = viewController.view;
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
    _popoverArrowDirection = arrowDirections;
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

@end