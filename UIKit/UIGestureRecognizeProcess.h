//
//  UIGestureRecognizeProcess.h
//  UIKit
//
//  Created by TaoZeyu on 15/8/24.
//  Copyright (c) 2015年 Shanghai Tinynetwork Inc. All rights reserved.
//

#import "UIView.h"
#import "UITouch.h"

@interface UIGestureRecognizeProcess : NSObject

@property (nonatomic, readonly) UIView *view;
@property (nonatomic, readonly) BOOL hasMakeConclusion;
@property (nonatomic, readonly) NSArray *gestureRecognizer;
@property (nonatomic, readonly) NSSet *trackingTouches;
@property (nonatomic, readonly) NSArray *trackingTouchesArray;

- (instancetype)initWithView:(UIView *)view;

- (void)trackTouch:(UITouch *)touch;
- (void)recognizeEvent:(UIEvent *)event touches:(NSSet *)touches;
- (void)sendToAttachedViewIfNeedWithEvent:(UIEvent *)event touches:(NSSet *)touches;

- (void)multiTouchBegin;
- (void)multiTouchEnd;

+ (BOOL)canViewCatchTouches:(UIView *)view;

@end
