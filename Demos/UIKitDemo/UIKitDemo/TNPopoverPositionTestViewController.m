//
//  TNPopoverPositionTestViewController.m
//  UIKitDemo
//
//  Created by TaoZeyu on 15/6/4.
//  Copyright (c) 2015年 Shanghai TinyNetwork Inc. All rights reserved.
//

#import "TNPopoverPositionTestViewController.h"
#import "TNBlockButton.h"

@interface TNPopoverPositionTestViewController ()
{
    UIPopoverController *_popoverController;
    CGRect _targetRectBuffer;
    UIView *_targetViewBuffer;
}
@end

@implementation TNPopoverPositionTestViewController

+ (NSString *)testName
{
    return @"Position Test";
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    _popoverController = [[UIPopoverController alloc] initWithContentViewController:[self _newViewController]];
    _popoverController.popoverContentSize = CGSizeMake(350, 550);
}

- (void)onTappedCustomControlItemButton
{
    [_popoverController presentPopoverFromRect:_targetRectBuffer
                                        inView:_targetViewBuffer
                      permittedArrowDirections:UIPopoverArrowDirectionAny
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
    
    UIButton *printHellowButton = [[TNBlockButton alloc] initWithBlock:^{
        NSLog(@"hello");
    }];
    UIButton *printWorldButton = [[TNBlockButton alloc] initWithBlock:^{
        NSLog(@"world");
    }];
    [printHellowButton setTitle:@"print hello" forState:UIControlStateNormal];
    [printWorldButton setTitle:@"print world" forState:UIControlStateNormal];
    
    printHellowButton.frame = CGRectMake(5, 5, 320, 50);
    printWorldButton.frame = CGRectMake(5, 60, 320, 50);
    printHellowButton.backgroundColor = [UIColor redColor];
    printWorldButton.backgroundColor = [UIColor redColor];
    
    [viewController.view addSubview:printHellowButton];
    [viewController.view addSubview:printWorldButton];
    
    return viewController;
}

@end
