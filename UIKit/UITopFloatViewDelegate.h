//
//  UITopFloatViewDelegate.h
//  UIKit
//
//  Created by TaoZeyu on 15/6/12.
//  Copyright (c) 2015年 Shanghai Tinynetwork Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol UITopFloatViewDelegate <NSObject>

- (void)floatViewWillAppear:(BOOL)animated;
- (void)floatViewDidAppear:(BOOL)animated;
- (void)floatViewWillDisappear:(BOOL)animated;
- (void)floatViewDidDisappear:(BOOL)animated;

@end