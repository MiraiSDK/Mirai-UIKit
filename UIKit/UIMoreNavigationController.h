//
//  UIMoreNavigationController.h
//  UIKit
//
//  Created by TaoZeyu on 15/4/13.
//  Copyright (c) 2015年 Shanghai Tinynetwork Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIMoreNavigationController : UINavigationController

- (instancetype)initWithTitle:(NSString *)title;
- (void)setMoreListViewControllers:(NSArray *)moreListViewControllers;
- (void)setCustomizableViewControllers:(NSArray *)customizableViewControllers;

@end
