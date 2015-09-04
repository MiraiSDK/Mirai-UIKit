//
//  TNMultiTapHelper.h
//  UIKit
//
//  Created by TaoZeyu on 15/9/3.
//  Copyright (c) 2015年 Shanghai Tinynetwork Inc. All rights reserved.
//

#import "UIGestureRecognizer.h"

@interface TNMultiTapHelper : NSObject

@property (nonatomic, assign) NSUInteger numberOfTapsRequired;
@property (nonatomic, assign) NSUInteger numberOfTouchesRequired;
@property (nonatomic, readonly) NSUInteger pressedTouchesCount;

- (instancetype)initWithTimeInterval:(NSTimeInterval)timeInterval
                   gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer;

- (void)beginOneTapWithTouches:(NSSet *)touches;
- (void)releaseFingersWithTouches:(NSSet *)touches completeOnTap:(BOOL *)completeOneTap;
- (void)cancelTap;
- (void)reset;

- (CGPoint)beginLocationWithTouch:(UITouch *)touch;

@end
