//
//  TNChangeTabTestViewController.m
//  UIKitDemo
//
//  Created by TaoZeyu on 15/3/22.
//  Copyright (c) 2015年 Shanghai TinyNetwork Inc. All rights reserved.
//

#import "TNChangeTabTestViewController.h"
#import "TNComponentCreator.h"ß

@interface TNChangeTabTestViewController ()

@end

@implementation TNChangeTabTestViewController

+ (NSString *)testName
{
    return @"test change tab.";
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self _makeControllers];
    [self _makeTabs];
    
}

- (void)_makeControllers
{
    self.viewControllers = @[
        [self _createViewControllerWithDescription:@"Controller(1)"],
        [self _createViewControllerWithDescription:@"Controller(2)"],
        [self _createOperateController],
    ];
}

- (void)_makeTabs
{
    UITabBarItem *item0 = [self.tabBar.items objectAtIndex:0];
    item0.image = [[UIImage imageNamed:@"tabicon0.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    
}

- (UIViewController *)_createViewControllerWithDescription:(NSString *)description
{
    UIViewController *controller = [[UIViewController alloc] init];
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(50, 50, 300, 50)];
    label.text = description;
    label.textColor = [UIColor blueColor];
    
    controller.title = description;
    [controller.view addSubview:label];
    controller.view.backgroundColor = [UIColor whiteColor];
    return controller;
}

-(UIViewController *)_createOperateController
{
    UIButton *imageZoomUp = [TNComponentCreator createButtonWithTitle:@"image++"
                                                            withFrame:CGRectMake(5, 75, 50, 25)];
    UIButton *imageZoomOut = [TNComponentCreator createButtonWithTitle:@"image --"
                                                             withFrame:CGRectMake(5, 75, 50, 25)];
    
    
    return nil;
}

- (void)_onClickImageZoomUp:(id)sender
{
    [self _doForEachTabBarItems:^(UITabBarItem *item, NSUInteger index) {
        CGSize size = item.image.size;
        size = CGSizeMake(size.width*1.25, size.height*1.25);
    }];
}


- (void)_doForEachTabBarItems:(void (^)(UITabBarItem *item, NSUInteger index))callback
{
    for (NSUInteger index = 0; index < [self.tabBar.items count]; index++) {
        callback([self _getTabBarItemAt:index], index);
    }
}

- (UITabBarItem *)_getTabBarItemAt:(NSUInteger)index
{
    return (UITabBarItem *)[self.tabBar.items objectAtIndex:index];
}

@end
