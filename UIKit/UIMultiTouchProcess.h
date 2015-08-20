//
//  UIMultiTouchProcess.h
//  UIKit
//
//  Created by TaoZeyu on 15/8/20.
//  Copyright (c) 2015年 Shanghai Tinynetwork Inc. All rights reserved.
//

#import "UIWindow.h"
#import "UIEvent.h"

@interface UIMultiTouchProcess : NSObject

@property (nonatomic, readonly) UIWindow *window;

- (instancetype)initWithWindow:(UIWindow *)window;

- (void)onBegan;
- (void)onEnded;

- (void)sendEvent:(UIEvent *)event;

@end
