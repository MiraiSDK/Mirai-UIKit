/*
 * Copyright (c) 2011, The Iconfactory. All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are met:
 *
 * 1. Redistributions of source code must retain the above copyright
 *    notice, this list of conditions and the following disclaimer.
 *
 * 2. Redistributions in binary form must reproduce the above copyright notice,
 *    this list of conditions and the following disclaimer in the documentation
 *    and/or other materials provided with the distribution.
 *
 * 3. Neither the name of The Iconfactory nor the names of its contributors may
 *    be used to endorse or promote products derived from this software without
 *    specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
 * ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
 * WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
 * DISCLAIMED. IN NO EVENT SHALL THE ICONFACTORY BE LIABLE FOR ANY DIRECT,
 * INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING,
 * BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
 * DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
 * LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE
 * OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF
 * ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

#import "UITapGestureRecognizer+UIPrivate.h"
#import "UIGestureRecognizerSubclass.h"
#import "UIGestureRecognizer+UIPrivate.h"
#import "UITouch.h"
#import "UIGeometry.h"
#import "TNMultiTapHelper.h"
#import "TNScreenHelper.h"

#import "UILongPressGestureRecognizer.h"

static const NSTimeInterval BeInvalidTime = 0.8;
static const float TapLimitAreaSize = 2.38;

@implementation UITapGestureRecognizer
{
    NSTimeInterval _timeInterval;
    NSUInteger _currentTapCount;
    NSUInteger _numTouches;
    
    NSTimer *_invalidTimer;
    BOOL _waitForNewTouchBegin;
    
    NSMutableArray *_touches;
    NSMutableDictionary *_beganLocations;
}

@synthesize numberOfTapsRequired=_numberOfTapsRequired, numberOfTouchesRequired=_numberOfTouchesRequired;

- (instancetype)init
{
    if (self = [super init]) {
        _numberOfTapsRequired = 1;
        _numberOfTouchesRequired = 1;
        _timeInterval = BeInvalidTime;
        _touches = [[NSMutableArray alloc] init];
        _beganLocations = [[NSMutableDictionary alloc] init];
        _waitForNewTouchBegin = YES;
    }
    return self;
}

//- (BOOL)canPreventGestureRecognizer:(UIGestureRecognizer *)preventedGestureRecognizer
//{
//    // this logic is here based on a note in the docs for -canPreventGestureRecognizer:
//    // it may not be correct :)
//    if ([preventedGestureRecognizer isKindOfClass:[UITapGestureRecognizer class]]) {
//        return (((UITapGestureRecognizer *)preventedGestureRecognizer).numberOfTapsRequired <= self.numberOfTapsRequired);
//    } else {
//        return [super canPreventGestureRecognizer:preventedGestureRecognizer];
//    }
//}

- (BOOL)canPreventGestureRecognizer:(UIGestureRecognizer *)preventedGestureRecognizer
{
    return [preventedGestureRecognizer isKindOfClass:[UILongPressGestureRecognizer class]] ||
    [preventedGestureRecognizer isKindOfClass:[UITapGestureRecognizer class]];
}

- (BOOL)canBePreventedByGestureRecognizer:(UIGestureRecognizer *)preventingGestureRecognizer
{
    return [preventingGestureRecognizer isKindOfClass:[UILongPressGestureRecognizer class]] ||
    [preventingGestureRecognizer isKindOfClass:[UITapGestureRecognizer class]];
}



- (void)reset
{
    [super reset];
    _currentTapCount = 0;
    
    [self _stopInvalidTimer];
    [_touches removeAllObjects];
    _waitForNewTouchBegin = YES;
}

- (NSUInteger)currentTapCount
{
    return _currentTapCount;
}

- (NSUInteger)currentTouchCount
{
    return _touches.count;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [_touches addObjectsFromArray:touches.allObjects];
    [self _restartInvalidTimer];
    
    for (UITouch *t in touches) {
        NSInteger idx = [_touches indexOfObject:t];
        CGPoint initPoint = [t locationInView:nil];
        NSValue *v = [NSValue valueWithCGPoint:initPoint];
        _beganLocations[@(idx)] = v;
    }
    
    if (!_waitForNewTouchBegin || _touches.count > self.numberOfTouchesRequired) {
        [self _cancelTap];
    }
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    float pointTapLimitAreaSize = [TNScreenHelperOfView(self.view) pointFromInch:TapLimitAreaSize];
    if ([self _anyTouchesOutOfArea:pointTapLimitAreaSize]) {
        [self _cancelTap];
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    _waitForNewTouchBegin = NO;
    
    
    [_touches removeObjectsInArray:touches.allObjects];
    _numTouches += touches.count;
    
    if (_touches.count == 0) {
        // all touches ended
        if (_numTouches >= self.numberOfTouchesRequired) {
            _waitForNewTouchBegin = YES;
            [self _completeOneTap];
        } else {
            [self _failOrEnd];
        }
    }
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self _cancelTap];
}

- (void)_cancelTap
{
    [self _failOrEnd];
    [self _stopInvalidTimer];
}

- (CGPoint)_beginLocationWithTouch:(UITouch *)touch
{
    NSInteger idx = [_touches indexOfObject:touch];
    NSValue *beginPoint = _beganLocations[@(idx)];
    return [beginPoint CGPointValue];
}

- (BOOL)_anyTouchesOutOfArea:(CGFloat)areaSize
{
    for (UITouch *touch in _touches) {
        if ([self _isTouch:touch outOfArea:areaSize]) {
            return YES;
        }
    }
    return NO;
}

- (BOOL)_isTouch:(UITouch *)touch outOfArea:(CGFloat)areaSize
{
    CGPoint currentLocation = [self locationInView:nil];
    CGPoint beginPoint = [self _beginLocationWithTouch:touch];
    
    if (ABS(currentLocation.x - beginPoint.x) > areaSize ||
        ABS(currentLocation.y - beginPoint.y) > areaSize) {
        // if move so far, failed
        return YES;
    }
    return NO;
}

- (void)_completeOneTap
{
    _currentTapCount++;
    _numTouches = 0;
    
    if (_currentTapCount >= self.numberOfTapsRequired) {
        [self _completeAllTaps];
    } else {
        [self _restartInvalidTimer];
    }
}

- (void)_completeAllTaps
{
    [self _setStateForce:UIGestureRecognizerStateRecognized];
    [self _stopInvalidTimer];
}

- (void)_onIntervalTimeOut:(NSTimer *)timer
{
    [self _failOrEnd];
    _invalidTimer = nil;
}

- (void)_failOrEnd
{
    if (self.state == UIGestureRecognizerStateBegan || self.state == UIGestureRecognizerStateChanged) {
        [self _setStateForce:UIGestureRecognizerStateEnded];
        
    } else if (self.state == UIGestureRecognizerStatePossible){
        [self _setStateForce:UIGestureRecognizerStateFailed];
    }
}

- (void)_restartInvalidTimer
{
    [self _stopInvalidTimer];
    _invalidTimer = [NSTimer timerWithTimeInterval:_timeInterval
                                            target:self selector:@selector(_onIntervalTimeOut:)
                                          userInfo:nil repeats:NO];
    [[NSRunLoop currentRunLoop] addTimer:_invalidTimer forMode:NSDefaultRunLoopMode];
}

- (void)_stopInvalidTimer
{
    if (_invalidTimer) {
        [_invalidTimer invalidate];
        _invalidTimer = nil;
    }
}

@end
