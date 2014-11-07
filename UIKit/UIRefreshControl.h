//
//  UIRefreshControl.h
//  UIKit
//
//  Created by Chen Yonghui on 11/7/14.
//  Copyright (c) 2014 Shanghai Tinynetwork Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIControl.h>
#import <UIKit/UIKitDefines.h>

@interface UIRefreshControl : UIControl
- (instancetype)init;

@property (nonatomic, readonly, getter=isRefreshing) BOOL refreshing;

@property (nonatomic, retain) UIColor *tintColor;
@property (nonatomic, retain) NSAttributedString *attributedTitle;

- (void)beginRefreshing;
- (void)endRefreshing;

@end
