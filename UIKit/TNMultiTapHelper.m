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
#import "UIGestureRecognizer+UIPrivate.h"
#import "UITouch.h"

#import "UIGeometry.h"

static CGFloat DistanceBetweenTwoPoints(CGPoint A, CGPoint B)
{
    CGFloat a = B.x - A.x;
    CGFloat b = B.y - A.y;
    return sqrtf((a*a) + (b*b));
}

@implementation TNMultiTapHelper
{
    NSTimeInterval _timeInterval;
    NSUInteger _numTaps;
    NSUInteger _numTouches;
    
    NSTimer *_invalidTimer;
    UIGestureRecognizer<TNMultiTapHelperDelegate> *_gestureRecognizer;
    
    NSMutableArray *_touches;
    NSMutableDictionary *_beganLocations;
}

- (instancetype)initWithTimeInterval:(NSTimeInterval)timeInterval
                   gestureRecognizer:(UIGestureRecognizer<TNMultiTapHelperDelegate> *)gestureRecognizer
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
    [self _failOrEnd];
    [self _stopInvalidTimer];
}

- (BOOL)anyTouches:(NSSet *)touches outOfArea:(CGFloat)areaSize
{
    for (UITouch *touch in touches) {
        if ([self _isTouch:touch outOfArea:areaSize]) {
            return YES;
        }
    }
    return NO;
}

- (BOOL)_isTouch:(UITouch *)touch outOfArea:(CGFloat)areaSize
{
    CGPoint currentLocation = [_gestureRecognizer locationInView:nil];
    CGPoint beginPoint = [self beginLocationWithTouch:touch];
    
    if (ABS(currentLocation.x - beginPoint.x) > areaSize ||
        ABS(currentLocation.y - beginPoint.y) > areaSize) {
        // if move so far, failed
        return YES;
    }
    return NO;
}


- (void)releaseFingersWithTouches:(NSSet *)touches completeOnTap:(void (^)(void))completeBlock
{
    [_touches removeObjectsInArray:touches.allObjects];
    _numTouches += touches.count;
    
    if (_touches.count == 0) {
        // all touches ended
        if (_numTouches >= self.numberOfTouchesRequired) {
            completeBlock();
            [self _completeOneTap];
        } else {
            [self _failOrEnd];
        }
    }
}

- (void)_completeOneTap
{
    _numTaps++;
    _numTouches = 0;
    
    if (_numTaps >= self.numberOfTapsRequired) {
        [self _completeAllTaps];
    } else {
        [self _restartInvalidTimer];
    }
}

- (void)_completeAllTaps
{
    [_gestureRecognizer setState:UIGestureRecognizerStateRecognized];
    [self _stopInvalidTimer];
}

- (void)_onTimeOut:(NSTimer *)timer
{
    if ([_gestureRecognizer willTimeOutLeadToFail]) {
        [self _failOrEnd];
        _invalidTimer = nil;
    }
}

- (void)_failOrEnd
{
    if (_gestureRecognizer.state == UIGestureRecognizerStateBegan ||
        _gestureRecognizer.state == UIGestureRecognizerStateChanged) {
        
        [_gestureRecognizer setState:UIGestureRecognizerStateEnded];
    } else {
        [_gestureRecognizer setState:UIGestureRecognizerStateFailed];
    }
}

- (void)_restartInvalidTimer
{
    [self _stopInvalidTimer];
    _invalidTimer = [NSTimer scheduledTimerWithTimeInterval:_timeInterval
                                                     target:self selector:@selector(_onTimeOut:)
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
