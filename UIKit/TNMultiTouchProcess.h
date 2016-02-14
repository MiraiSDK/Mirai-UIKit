//
//  UIMultiTouchProcess.h
//  UIKit
//
//  Created by TaoZeyu on 15/8/20.
//  Copyright (c) 2015年 Shanghai Tinynetwork Inc. All rights reserved.
//

#import "UIWindow.h"
#import "UIEvent.h"
#import "TNGestureRecognizeProcess.h"

@class TNGestureRecognizeProcess;

@interface TNMultiTouchProcess : NSObject

@property (nonatomic, readonly) UIWindow *window;
@property (nonatomic, readonly) BOOL handingTouchEvent;
@property (nonatomic, readonly) BOOL handingMultiTouchEvent;

- (instancetype)initWithWindow:(UIWindow *)window;
- (void)sendEvent:(UIEvent *)event;
- (void)gestureRecognizeProcessMakeConclusion:(TNGestureRecognizeProcess *)gestureRecognizeProcess;
- (void)unbindViewAndItsGestureRecognizeProcess:(UIView *)view;

@end
