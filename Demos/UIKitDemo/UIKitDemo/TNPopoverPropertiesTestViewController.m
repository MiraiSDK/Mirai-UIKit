//
//  TNPopoverPropertiesTestViewController.m
//  UIKitDemo
//
//  Created by TaoZeyu on 15/6/11.
//  Copyright (c) 2015年 Shanghai TinyNetwork Inc. All rights reserved.
//

#import "TNPopoverPropertiesTestViewController.h"
#import "TNChangedColorButton.h"
#import "TNBlockButton.h"

@implementation TNPopoverPropertiesTestViewController
{
    UIView *_controlPanel;
    UIPopoverController *_popoverController;
}


+ (NSString *)testName
{
    return @"Properties Test";
}

- (void)viewDidLoad {
    [super viewDidLoad];
    _controlPanel = [self _newControlPanel];
    _popoverController = [self _newPopoverController];
    [self _addComponentsForControlPanel];
    [self _makeShowPopoverFloatViewButton];
}

- (UIView *)_newControlPanel
{
    UIView *panel = [[UIView alloc] initWithFrame:CGRectMake(10, 70, 270, 550)];
    [panel setBackgroundColor:[UIColor grayColor]];
    return panel;
}

- (UIPopoverController *)_newPopoverController
{
    UIViewController *initViewController = [[UIViewController alloc] init];
    initViewController.view = _controlPanel;
    UIPopoverController *popoverController = [[UIPopoverController alloc] initWithContentViewController:initViewController];
    popoverController.popoverContentSize = CGSizeMake(320, 300);
    popoverController.popoverLayoutMargins = UIEdgeInsetsMake(100, 200, 30, 30);
    return popoverController;
}

- (void)_makeShowPopoverFloatViewButton
{
    __weak typeof(self) weakSelf = self;
    CGRect buttonFrame = CGRectMake(30, 130, 280, 30);
    UIButton *button = [[TNBlockButton alloc] initWithBlock:^{
        typeof(self) slf = weakSelf;
        [slf->_popoverController presentPopoverFromRect:buttonFrame
                                                 inView:slf.view
                               permittedArrowDirections:UIPopoverArrowDirectionAny
                                               animated:YES];
    }];
    [button setTitle:@"show" forState:UIControlStateNormal];
    [button setBackgroundColor:[UIColor grayColor]];
    button.frame = buttonFrame;
    [self.view addSubview:button];
}

- (void)_addComponentsForControlPanel
{
    [self _makeContentViewControllerButton];
    [self _makePopoverContentSizeButton];
    [self _makePopoverLayoutMarginsButton];
}

- (void)_makeContentViewControllerButton
{
    __weak typeof(self) weakSelf = self;
    
    UIButton *contentViewControllerButton = [[TNChangedColorButton alloc] initWithFrame:CGRectMake(5, 10, 260, 40) whenColorChanged:^(UIColor *color) {
        typeof(self) slf = weakSelf;
        NSLog(@"slf->_popoverController.popoverVisible %i", slf->_popoverController.popoverVisible);
        if (slf->_popoverController.popoverVisible) {
            UIViewController *changedViewController = [slf _newViewControllerWithColor:color];
            [slf->_popoverController setContentViewController:changedViewController animated:YES];
        }
    }];
    [contentViewControllerButton setTitle:@"contentViewController" forState:UIControlStateNormal];
    [_controlPanel addSubview:contentViewControllerButton];
}

- (void)_makePopoverContentSizeButton
{
    __weak typeof(self) weakSelf = self;
    
    UIButton *popoverContentSizeButton = [TNBlockButton blockButtonWhenTapped:^{
        typeof(self) slf = weakSelf;
        CGSize size = slf->_popoverController.popoverContentSize;
        if (size.width > 500) {
            size = CGSizeMake(320, 300);
        } else {
            size = CGSizeMake(size.width*1.2, size.height*1.2);
        }
        NSLog(@"popoverContentSizeButton -> %@", NSStringFromCGSize(size));
        [slf->_popoverController setPopoverContentSize:size animated:YES];
    }];
    popoverContentSizeButton.frame = CGRectMake(5, 60, 260, 40);
    [popoverContentSizeButton setTitle:@"popoverContentSize" forState:UIControlStateNormal];
    [_controlPanel addSubview:popoverContentSizeButton];
}

- (void)_makePopoverLayoutMarginsButton
{
    __weak typeof(self) weakSelf = self;
    
    UIButton *popoverLayoutMarginsButton = [TNBlockButton blockButtonWhenTapped:^{
        typeof(self) slf = weakSelf;
        static BOOL useLargerOne = NO;
        UIEdgeInsets edgeInsets;
        if (useLargerOne) {
            edgeInsets = UIEdgeInsetsMake(20, 20, 20, 20);
        } else {
            edgeInsets = UIEdgeInsetsMake(5, 5, 5, 5);
        }
        useLargerOne = !useLargerOne;
        NSLog(@"popoverLayoutMargins -> %@", NSStringFromUIEdgeInsets(edgeInsets));
        slf->_popoverController.popoverLayoutMargins = edgeInsets;
    }];
    popoverLayoutMarginsButton.frame = CGRectMake(5, 110, 260, 40);
    [popoverLayoutMarginsButton setTitle:@"popoverLayoutMargins" forState:UIControlStateNormal];
    [_controlPanel addSubview:popoverLayoutMarginsButton];
}

- (UIViewController *)_newViewControllerWithColor:(UIColor *)viewControllerColor
{
    UIViewController *viewController = [[UIViewController alloc] init];
    viewController.view.backgroundColor = viewControllerColor;
    return viewController;
}

@end
