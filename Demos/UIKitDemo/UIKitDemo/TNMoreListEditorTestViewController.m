//
//  TNMoreListEditorTestViewController.m
//  UIKitDemo
//
//  Created by TaoZeyu on 15/4/13.
//  Copyright (c) 2015年 Shanghai TinyNetwork Inc. All rights reserved.
//

#import "TNMoreListEditorTestViewController.h"
#define ViewControllersCount 20

@interface TNMoreListEditorTestViewController ()
@property (nonatomic, strong) UITabBarController *controller;
@end

@implementation TNMoreListEditorTestViewController

+ (NSString *)testName
{
    return @"test more list editor.";
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self _makeTabBarController];
    [self _setAppearance];
    [self _setViewControllers];
    
    self.view.backgroundColor = [UIColor redColor];
}

- (void)_makeTabBarController
{
    self.controller = [[UITabBarController alloc] initWithNibName:nil bundle:nil];
    [self.view addSubview:self.controller.view];
}

- (void)_setAppearance
{
    self.controller.view.frame = CGRectMake(50, 150, 200, 200);
    self.controller.view.backgroundColor = [UIColor whiteColor];
}

- (void)_setViewControllers
{
    NSMutableArray *controllers = [[NSMutableArray alloc] init];
    for (NSUInteger i = 0; i < ViewControllersCount; i++) {
        NSString *titleName = [NSString stringWithFormat:@"vc(%li)", i];
        UIViewController *viewController = [self _createViewControllerWithDescription:titleName];
        [controllers addObject:viewController];
    }
    self.controller.viewControllers = controllers;
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

@end
