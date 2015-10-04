//
//  TNMultiTapHelper.h
//  UIKit
//
//  Created by TaoZeyu on 15/9/3.
//  Copyright (c) 2015年 Shanghai Tinynetwork Inc. All rights reserved.
//

#import "UIGestureRecognizer.h"

@protocol TNMultiTapHelperDelegate <NSObject>

- (void)onOverTime;
- (void)onCompleteTap;

@end

@interface TNMultiTapHelper : NSObject

@property (nonatomic, assign) NSTimeInterval timeInterval;
@property (nonatomic, assign) NSUInteger numberOfTouchesRequired;
@property (nonatomic, readonly) NSUInteger pressedTouchesCount;
@property (nonatomic, readonly) BOOL hasOverTime;

- (instancetype)initWithTimeInterval:(NSTimeInterval)timeInterval
                   gestureRecognizer:(UIGestureRecognizer<TNMultiTapHelperDelegate> *)gestureRecognizer;

- (void)trackTouches:(NSSet *)touches;
- (void)beginOneTap;
- (void)releaseFingersWithTouches:(NSSet *)touches;
- (void)cancelTap;
- (void)reset;

- (CGPoint)beginLocationWithTouch:(UITouch *)touch;
- (BOOL)anyTouchesOutOfArea:(CGFloat)areaSize;

@end
