//
//  UIPopoverController.m
//  UIKit
//
//  Created by Chen Yonghui on 5/2/14.
//  Copyright (c) 2014 Shanghai Tinynetwork Inc. All rights reserved.
//

#import "UIPopoverController.h"

@implementation UIPopoverController

- (id)initWithContentViewController:(UIViewController *)viewController
{
    self = [super init];
    if (self) {
        
    }
    return self;
}

- (void)setContentViewController:(UIViewController *)viewController animated:(BOOL)animated;
{
    
}

- (void)setPopoverContentSize:(CGSize)size animated:(BOOL)animated
{
    
}

- (void)presentPopoverFromRect:(CGRect)rect inView:(UIView *)view permittedArrowDirections:(UIPopoverArrowDirection)arrowDirections animated:(BOOL)animated
{
    
}

- (void)presentPopoverFromBarButtonItem:(UIBarButtonItem *)item permittedArrowDirections:(UIPopoverArrowDirection)arrowDirections animated:(BOOL)animated
{
    
}

- (void)dismissPopoverAnimated:(BOOL)animated
{
    
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