//
//  UITabBarItem+UIPrivate.h
//  UIKit
//
//  Created by TaoZeyu on 15/4/8.
//  Copyright (c) 2015年 Shanghai Tinynetwork Inc. All rights reserved.
//
#import "UITabBarItem.h"

@interface UITabBarItem (UIPrivate)

- (void)setCallbackWhenNeedRefreshDisplayWithTarget:(id)target action:(SEL)action;
- (void)clearCallbackWhenNeedRefreshDisplay;

@end