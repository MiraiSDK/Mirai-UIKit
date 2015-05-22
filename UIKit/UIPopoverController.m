//
//  UIPopoverController.m
//  UIKit
//
//  Created by Chen Yonghui on 5/2/14.
//  Copyright (c) 2014 Shanghai Tinynetwork Inc. All rights reserved.
//

#import "UIPopoverController.h"
#import "UIButton.h"

@interface UIPopoverController ()
@property (nonatomic, strong) UIButton *dismissButton;
@end
@implementation UIPopoverController

- (id)initWithContentViewController:(UIViewController *)viewController
{
    self = [super init];
    if (self) {
        _contentViewController = viewController;
    }
    return self;
}

- (void)setContentViewController:(UIViewController *)viewController animated:(BOOL)animated;
{
    _contentViewController = viewController;
}

- (void)setPopoverContentSize:(CGSize)size animated:(BOOL)animated
{
    _popoverContentSize = size;
}

- (void)presentPopoverFromRect:(CGRect)rect inView:(UIView *)view permittedArrowDirections:(UIPopoverArrowDirection)arrowDirections animated:(BOOL)animated
{
    UIButton *dismissButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [dismissButton addTarget:self action:@selector(tapBackground:) forControlEvents:UIControlEventTouchUpInside];
    dismissButton.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.3];
    dismissButton.frame = view.bounds;
    _dismissButton = dismissButton;
    [view addSubview:dismissButton];
    
    [view addSubview:_contentViewController.view];
    
    CGSize size = [_contentViewController preferredContentSize];
    
    CGFloat x,y;
    x = CGRectGetMaxX(rect);
    y = CGRectGetMinY(rect);
    
    CGRect contentRect = CGRectMake(x, y, size.width, size.height);
    CGFloat maxY = view.bounds.size.height - 400;//keyboard
    CGFloat diff = CGRectGetMaxY(contentRect) - maxY;
    if (diff > 0) {
        contentRect.origin.y -= diff;
    }
    _contentViewController.view.frame = contentRect;
}

- (void)tapBackground:(id)sender
{
    [self dismissPopoverAnimated:YES];
}

- (void)presentPopoverFromBarButtonItem:(UIBarButtonItem *)item permittedArrowDirections:(UIPopoverArrowDirection)arrowDirections animated:(BOOL)animated
{
    
}

- (void)dismissPopoverAnimated:(BOOL)animated
{
    [_contentViewController viewWillDisappear:animated];

    [self.dismissButton removeFromSuperview];
    [_contentViewController.view removeFromSuperview];
    
    [_contentViewController viewDidDisappear:animated];
    
    if ([self.delegate respondsToSelector:@selector(popoverControllerDidDismissPopover:)]) {
        [self.delegate popoverControllerDidDismissPopover:self];
    }
}

@end

@implementation UIViewController (UIPopoverController)

- (void)setModalInPopover:(BOOL)modalInPopover
{
    
}

- (BOOL)isModalInPopover
{
    return NO;
}

- (CGSize)contentSizeForViewInPopover
{
    return CGSizeZero;
}

- (void)setContentSizeForViewInPopover:(CGSize)contentSizeForViewInPopover
{
    
}

@end