//
//  TNMultiTapHelper.m
//  UIKit
//
//  Created by TaoZeyu on 15/9/3.
//  Copyright (c) 2015年 Shanghai Tinynetwork Inc. All rights reserved.
//
#import <Foundation/Foundation.h>
#import <CoreGraphics/CoreGraphics.h> // for CGPoint

#import "TNMultiTapHelper.h"
#import "UIGestureRecognizerSubclass.h"
#import "UITouch.h"

#import "UIGeometry.h"

@implementation TNMultiTapHelper
{
    NSTimeInterval _timeInterval;
    NSUInteger _numTaps;
    NSUInteger _numTouches;
    
    NSTimer *_invalidTimer;
    UIGestureRecognizer *_gestureRecognizer;
    
    NSMutableArray *_touches;
    NSMutableDictionary *_beganLocations;
}

- (instancetype)initWithTimeInterval:(NSTimeInterval)timeInterval
                   gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer
{
    if (self = [super init]) {
        _timeInterval = timeInterval;
        _gestureRecognizer = gestureRecognizer;
        _touches = [[NSMutableArray alloc] init];
        _beganLocations = [[NSMutableDictionary alloc] init];
    }
    return self;
}

- (void)dealloc
{
    [self _stopInvalidTimer];
}

- (NSUInteger)pressedTouchesCount
{
    return _touches.count;
}

- (void)reset
{
    _numTaps = 0;
    [self _stopInvalidTimer];
    [_touches removeAllObjects];
}

- (void)beginOneTapWithTouches:(NSSet *)touches
{
    [_touches addObjectsFromArray:touches.allObjects];
    [self _restartInvalidTimer];
    
    for (UITouch *t in touches) {
        NSInteger idx = [_touches indexOfObject:t];
        CGPoint initPoint = [t locationInView:nil];
        NSValue *v = [NSValue valueWithCGPoint:initPoint];
        _beganLocations[@(idx)] = v;
    }
}

- (CGPoint)beginLocationWithTouch:(UITouch *)touch
{
    NSInteger idx = [_touches indexOfObject:touch];
    NSValue *beginPoint = _beganLocations[@(idx)];
    return [beginPoint CGPointValue];
}

- (void)cancelTap
{
    [_gestureRecognizer setState:UIGestureRecognizerStateFailed];
    [self _stopInvalidTimer];
}

- (void)releaseFingersWithTouches:(NSSet *)touches completeOnTap:(BOOL *)completeOneTap
{
    *completeOneTap = NO;
    
    [_touches removeObjectsInArray:touches.allObjects];
    _numTouches += touches.count;
    
    if (_touches.count == 0) {
        // all touches ended
        if (_numTouches >= self.numberOfTouchesRequired) {
            [self _completeOneTap];
            *completeOneTap = YES;
        }
    }
}

- (void)_completeOneTap
{
    _numTaps++;
    _numTouches = 0;
    
    if (_numTaps >= self.numberOfTapsRequired) {
        [self _completeAllTaps];
        return;
    }
    [self _restartInvalidTimer];
}

- (void)_completeAllTaps
{
    [_gestureRecognizer setState:UIGestureRecognizerStateRecognized];
    [self _stopInvalidTimer];
}

- (void)_onInvalid:(NSTimer *)timer
{
    [_gestureRecognizer setState:UIGestureRecognizerStateFailed];
    _invalidTimer = nil;
}

- (void)_restartInvalidTimer
{
    [self _stopInvalidTimer];
    _invalidTimer = [NSTimer scheduledTimerWithTimeInterval:_timeInterval
                                                     target:self selector:@selector(_onInvalid:)
                                                   userInfo:nil repeats:NO];
    [[NSRunLoop currentRunLoop] addTimer:_invalidTimer forMode:NSRunLoopCommonModes];
}

- (void)_stopInvalidTimer
{
    if (_invalidTimer) {
        [_invalidTimer invalidate];
        _invalidTimer = nil;
    }
}

@end
