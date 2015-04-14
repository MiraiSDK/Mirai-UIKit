//
//  UIMoreNavigationController.m
//  UIKit
//
//  Created by TaoZeyu on 15/4/13.
//  Copyright (c) 2015年 Shanghai Tinynetwork Inc. All rights reserved.
//

#import "UIMoreNavigationController.h"
#import "UIMoreListController.h"

@interface UIMoreNavigationController()
@property (nonatomic, strong) UIMoreListController *moreListController;
@end

@implementation UIMoreNavigationController

- (instancetype)initWithTitle:(NSString *)title
{
    UIMoreListController *moreListController = [self _createMoreListController];
    if (self = [super initWithRootViewController:moreListController]) {
        self.moreListController = moreListController;
        self.title = title;
    }
    return self;
}

- (void)setMoreListViewControllers:(NSArray *)moreListViewControllers
{
    self.moreListController.viewControllers = moreListViewControllers;
}

- (void)setCustomizableViewControllers:(NSArray *)customizableViewControllers
{
    
}

- (UIMoreListController *)_createMoreListController
{
    UIMoreListController *controller = [[UIMoreListController alloc] init];
    [controller setSelectIndexCallbackWithTarget:self
                                          action:@selector(_onSelectedIndexOfMoreListController:)];
    return controller;
}

- (void)_onSelectedIndexOfMoreListController:(NSNumber *)selectedIndexNumber
{
    NSUInteger selectedIndexAtMoreList = [selectedIndexNumber unsignedIntegerValue];
    UIViewController *viewController = [self.moreListController.viewControllers objectAtIndex:selectedIndexAtMoreList];
    [self pushViewController:viewController animated:YES];
}

@end
