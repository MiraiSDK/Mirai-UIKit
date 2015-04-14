//
//  UIMoreListController.h
//  UIKit
//
//  Created by TaoZeyu on 15/4/10.
//  Copyright (c) 2015年 Shanghai Tinynetwork Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIMoreListController : UITableViewController

@property (nonatomic, copy) NSArray *viewControllers;
- (void)setSelectIndexCallbackWithTarget:(id)target action:(SEL)action;

@end
