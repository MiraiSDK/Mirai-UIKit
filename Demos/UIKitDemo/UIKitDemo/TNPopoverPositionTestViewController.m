//
//  TNPopoverPositionTestViewController.m
//  UIKitDemo
//
//  Created by TaoZeyu on 15/6/4.
//  Copyright (c) 2015年 Shanghai TinyNetwork Inc. All rights reserved.
//

#import "TNPopoverPositionTestViewController.h"

@interface TNPopoverPositionTestViewController ()
{
    UIPopoverController *_popoverController;
    CGRect _targetRectBuffer;
    UIView *_targetViewBuffer;
}
@end

@implementation TNPopoverPositionTestViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    _popoverController = [[UIPopoverController alloc] initWithContentViewController:[self _newViewController]];
}

- (void)onTappedCustomControlItemButton
{
    [_popoverController presentPopoverFromRect:_targetRectBuffer
                                        inView:_targetViewBuffer
                      permittedArrowDirections:UIPopoverArrowDirectionLeft
                                      animated:NO];
}

- (void)onSetTargetRectangle:(CGRect)targetRect inView:(UIView *)view
{
    _targetRectBuffer = targetRect;
    _targetViewBuffer = view;
}

- (UIViewController *)_newViewController
{
    UIViewController *viewController = [[UIViewController alloc] init];
    [viewController.view setBackgroundColor:[UIColor blueColor]];
    [viewController.view setFrame:CGRectMake(0, 0, 350, 550)];
    return viewController;
}

@end
