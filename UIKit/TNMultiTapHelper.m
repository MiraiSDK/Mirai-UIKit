//
//  TNMultiTapHelper.m
//  UIKit
//
//  Created by TaoZeyu on 15/9/3.
//  Copyright (c) 2015年 Shanghai Tinynetwork Inc. All rights reserved.
//

#import "TNMultiTapHelper.h"
#import "UIGestureRecognizerSubclass.h"

@implementation TNMultiTapHelper
{
    NSTimeInterval _timeInterval;
    NSUInteger _numTaps;
    
    NSTimer *_invalidTimer;
    UIGestureRecognizer *_gestureRecognizer;
}

- (instancetype)initWithTimeInterval:(NSTimeInterval)timeInterval
                   gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer
{
    if (self = [super init]) {
        _timeInterval = timeInterval;
        _gestureRecognizer = gestureRecognizer;
    }
    return self;
}

- (void)dealloc
{
    [self _stopInvalidTimer];
}

- (void)reset
{
    _numTaps = 0;
    [self _stopInvalidTimer];
}

- (void)beginOneTap
{
    [self _restartInvalidTimer];
}

- (void)cancelTap
{
    [_gestureRecognizer setState:UIGestureRecognizerStateFailed];
    [self _stopInvalidTimer];
}

- (void)completeOneTap
{
    _numTaps++;
    
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
