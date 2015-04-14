//
//  TNViewWillAppearListenerTestViewController.m
//  UIKitDemo
//
//  Created by TaoZeyu on 15/4/13.
//  Copyright (c) 2015年 Shanghai TinyNetwork Inc. All rights reserved.
//

#import "TNViewWillAppearListenerTestViewController.h"
#define ViewControllersCount 20

@interface TNCustomizedViewController : UIViewController
@end

@implementation TNCustomizedViewController

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    NSLog(@"[%@] invoked %s", self.title, __PRETTY_FUNCTION__);
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    NSLog(@"[%@] invoked %s", self.title, __PRETTY_FUNCTION__);
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    NSLog(@"[%@] invoked %s", self.title, __PRETTY_FUNCTION__);
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    NSLog(@"[%@] invoked %s", self.title, __PRETTY_FUNCTION__);
}

@end

@implementation TNViewWillAppearListenerTestViewController

+ (NSString *)testName
{
    return @"log method viewWillAppear:";
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self _setViewControllers];
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

- (TNCustomizedViewController *)_createViewControllerWithDescription:(NSString *)description
{
    TNCustomizedViewController *controller = [[TNCustomizedViewController alloc] init];
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(50, 110, 300, 50)];
    label.text = description;
    label.textColor = [UIColor blueColor];
    
    controller.title = description;
    [controller.view addSubview:label];
    controller.view.backgroundColor = [UIColor whiteColor];
    return controller;
}

@end
