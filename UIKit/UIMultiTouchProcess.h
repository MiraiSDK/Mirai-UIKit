//
//  UIMultiTouchProcess.h
//  UIKit
//
//  Created by TaoZeyu on 15/8/20.
//  Copyright (c) 2015年 Shanghai Tinynetwork Inc. All rights reserved.
//

#import "UIWindow.h"
#import "UIEvent.h"
#import "UIGestureRecognizeProcess.h"

@class UIGestureRecognizeProcess;

@interface UIMultiTouchProcess : NSObject

@property (nonatomic, readonly) UIWindow *window;
@property (nonatomic, readonly) BOOL handingTouchEvent;

- (instancetype)initWithWindow:(UIWindow *)window;
- (void)sendEvent:(UIEvent *)event;
- (void)gestureRecognizeProcessMakeConclusion:(UIGestureRecognizeProcess *)gestureRecognizeProcess;

@end
