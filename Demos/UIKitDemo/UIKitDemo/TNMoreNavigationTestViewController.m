//
//  TNMoreNavigationTestViewController.m
//  UIKitDemo
//
//  Created by TaoZeyu on 15/4/10.
//  Copyright (c) 2015年 Shanghai TinyNetwork Inc. All rights reserved.
//

#import "TNMoreNavigationTestViewController.h"
#import <UIKit/UIKit.h>

#define ViewControllersCount 6

@implementation TNMoreNavigationTestViewController

+ (NSString *)testName
{
    return @"about more navigation.";
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self _setViewControllers];
    [self _setCustomizableViewControllers];
    [self _makeShowValuesLogButtons];
    self.view.backgroundColor = [UIColor whiteColor];
}

- (void)_setViewControllers
{
    NSMutableArray *controllers = [[NSMutableArray alloc] init];
    for (NSUInteger i = 0; i < ViewControllersCount; i++) {
        NSString *titleName = [NSString stringWithFormat:@"vc(%li)", i];
        UIViewController *viewController = [self _createViewControllerWithDescription:titleName];
        [controllers addObject:viewController];
    }
    self.viewControllers = controllers;
}

- (void)_setCustomizableViewControllers
{
    NSArray *indexArray = @[
                            [NSNumber numberWithUnsignedInteger:0],
                            [NSNumber numberWithUnsignedInteger:1],
                            [NSNumber numberWithUnsignedInteger:4],
                            ];
    self.customizableViewControllers = [self _createViewControllersWithIndexArray:indexArray];
}

- (void)_makeShowValuesLogButtons
{
    [self _makeButtonWithTitle:@"selectedIndex"
                    withAction:@selector(_onClickShowSelectedIndex:)
                            at:CGPointMake(10, 200)];
    [self _makeButtonWithTitle:@"selectedViewController"
                    withAction:@selector(_onClickShowSelectedViewController:)
                            at:CGPointMake(10, 270)];
    [self _makeButtonWithTitle:@"selecte next index"
                    withAction:@selector(_onClickSelectNextIndex:)
                            at:CGPointMake(10, 340)];
}

- (void)_onClickShowSelectedIndex:(id)sender
{
    if (self.selectedIndex != NSNotFound) {
        NSLog(@"selectedIndex = %li", self.selectedIndex);
    } else {
        NSLog(@"selectedIndex = NSNotFound");
    }
}

- (void)_onClickShowSelectedViewController:(id)sender
{
    NSLog(@"selectedViewController title = %@", self.selectedViewController.title);
}

- (void)_onClickSelectNextIndex:(id)sender
{
    if (self.selectedIndex < self.viewControllers.count) {
        self.selectedIndex ++;
    }
}

- (UIViewController *)_createViewControllerWithDescription:(NSString *)description
{
    UIViewController *controller = [[UIViewController alloc] init];
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(50, 110, 300, 50)];
    label.text = description;
    label.textColor = [UIColor blueColor];
    
    controller.title = description;
    [controller.view addSubview:label];
    controller.view.backgroundColor = [UIColor whiteColor];
    return controller;
}

- (NSArray *)_createViewControllersWithIndexArray:(NSArray *)indexArray
{
    NSMutableArray *controllers = [[NSMutableArray alloc] init];
    for (NSUInteger i = 0; i < indexArray.count; i ++) {
        NSUInteger index = [(NSNumber *)[indexArray objectAtIndex:i] unsignedIntegerValue];
        [controllers addObject:[self.viewControllers objectAtIndex:index]];
    }
    return controllers;
}

- (UIButton *)_makeButtonWithTitle:(NSString *)title withAction:(SEL)action at:(CGPoint)location
{
    UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
    [button setTitle:title forState:UIControlStateNormal];
    button.frame = CGRectMake(location.x, location.y, 300, 50);
    button.layer.borderColor = [[UIColor blueColor] CGColor];
    button.layer.borderWidth = 2;
    
    [self.view addSubview:button];
    [button addTarget:self action:action forControlEvents:UIControlEventTouchUpInside];
    
    return button;
}

@end
