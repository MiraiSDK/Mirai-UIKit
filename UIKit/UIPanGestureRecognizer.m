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

#import "UIPanGestureRecognizer.h"
#import "UIGestureRecognizerSubclass.h"
#import "UITouch+Private.h"
#import "UIEvent.h"
#import "UIGeometry.h"
#import "UIWindow.h"

#define kCurrentVelocityWeight 0.35
#define kTapLimitAreaSize 5

@interface _UIPanGestureRecognizerScreenLocation : NSObject

@property (nonatomic, readonly) NSUInteger index;
@property (nonatomic, assign) CGPoint firstScreenLocation;
@property (nonatomic, assign) CGPoint lastScreenLocation;

@end

@implementation _UIPanGestureRecognizerScreenLocation

@synthesize index=_index;

- (instancetype)initWithIndex:(NSUInteger)index
{
    if (self = [super init]) {
        _index = index;
    }
    return self;
}

- (CGPoint)translationInView:(UIView *)view
{
    CGPoint firstPoint = [view.window convertPoint:_firstScreenLocation toView:view];
    CGPoint lastPoint = [view.window convertPoint:_lastScreenLocation toView:view];
    CGPoint translation = CGPointMake(lastPoint.x - firstPoint.x , lastPoint.y - firstPoint.y);
    return translation;
}

@end

@implementation UIPanGestureRecognizer
{
    NSMutableArray *_touches;
    NSMutableDictionary *_touchToScreenLocationDictionary;
}
@synthesize maximumNumberOfTouches=_maximumNumberOfTouches, minimumNumberOfTouches=_minimumNumberOfTouches;

- (instancetype)init
{
    if ((self=[super init])) {
        _touches = [[NSMutableArray alloc] init];
        _touchToScreenLocationDictionary = [[NSMutableDictionary alloc] init];
        _minimumNumberOfTouches = 1;
        _maximumNumberOfTouches = NSUIntegerMax;
        _velocity = CGPointZero;
    }
    return self;
}

- (CGPoint)translationInView:(UIView *)view
{
    CGPoint averageTranslation = CGPointZero;
    
    for (_UIPanGestureRecognizerScreenLocation *screenLocation in [self _screenLocations]) {
        CGPoint translation = [screenLocation translationInView:view];
        averageTranslation.x += translation.x;
        averageTranslation.y += translation.y;
    }
    CGFloat count = _touchToScreenLocationDictionary.count;
    averageTranslation =  CGPointMake(averageTranslation.x/count, averageTranslation.y/count);
    
    return averageTranslation;
}

- (void)setTranslation:(CGPoint)translation inView:(UIView *)view
{
    //TODO
    _velocity = CGPointZero;
}

- (void)_translateTouches:(NSSet *)touches withEvent:(UIEvent *)event
{
    const NSTimeInterval timeDiff = event.timestamp - _lastMovementTime;
    
    if (timeDiff > 0) {
        CGPoint averageDelta = CGPointZero;
        
        for (UITouch *touch in touches) {
            CGPoint delta = [touch _delta];
            averageDelta.x += delta.x;
            averageDelta.y += delta.y;
        }
        averageDelta.x /= touches.count;
        averageDelta.y /= touches.count;
        
        _velocity.x += [self _mergeVelocity0:_velocity.x andVelocity1:(averageDelta.x / timeDiff)];
        _velocity.y += [self _mergeVelocity0:_velocity.y andVelocity1:(averageDelta.y / timeDiff)];
    }
    _lastMovementTime = event.timestamp;
}

- (CGFloat)_mergeVelocity0:(CGFloat)v0 andVelocity1:(CGFloat)v1
{
    if (v0 == 0) {
        return v1;
    } else if (v0*v1 < 0) {
        v0 = 0;
    }
    return (1-kCurrentVelocityWeight)*v0 + kCurrentVelocityWeight*v1;
}

- (void)reset
{
    [super reset];
    _velocity = CGPointZero;
    _lastMovementTime = 0.0;
    
    [_touches removeAllObjects];
    [_touchToScreenLocationDictionary removeAllObjects];
}

- (CGPoint)velocityInView:(UIView *)view
{
    return CGPointMake(-_velocity.x, -_velocity.y);
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [_touches addObjectsFromArray:[touches allObjects]];
    
    for (UITouch *touch in touches) {
        NSUInteger index = [_touches indexOfObject:touch];
        _UIPanGestureRecognizerScreenLocation *screenLocation = [[_UIPanGestureRecognizerScreenLocation alloc] initWithIndex:index];
        CGPoint firstScreenLocation = [touch locationInView:self.view.window];
        screenLocation.firstScreenLocation = firstScreenLocation;
        screenLocation.lastScreenLocation = firstScreenLocation;
        [_touchToScreenLocationDictionary setObject:screenLocation forKey:@(index)];
    }
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self _updateAllLastScreenLocationsWithTouches:touches];
    
    if (self.state == UIGestureRecognizerStatePossible) {
        if ([self _anyTouchMoveOutOfAreaWithTouches:touches]) {
            _lastMovementTime = event.timestamp;
            self.state = UIGestureRecognizerStateBegan;
        }
    } else {
        [self _translateTouches:touches withEvent:event];
        self.state = UIGestureRecognizerStateChanged;
    }
}

- (void)_updateAllLastScreenLocationsWithTouches:(NSSet *)touches
{
    for (UITouch *touch in touches) {
        NSUInteger index = [_touches indexOfObject:touch];
        _UIPanGestureRecognizerScreenLocation *screenLocation = [_touchToScreenLocationDictionary objectForKey:@(index)];
        screenLocation.lastScreenLocation = [touch locationInView:self.view.window];
    }
}

- (BOOL)_anyTouchMoveOutOfAreaWithTouches:(NSSet *)touches
{
    for (UITouch *touch in touches) {
        NSUInteger index = [_touches indexOfObject:touch];
        _UIPanGestureRecognizerScreenLocation *sl =
            [_touchToScreenLocationDictionary objectForKey:@(index)];
        
        if ((ABS(sl.firstScreenLocation.x - sl.lastScreenLocation.x) > kTapLimitAreaSize ||
             ABS(sl.firstScreenLocation.y - sl.lastScreenLocation.y) > kTapLimitAreaSize)) {
            
            return YES;
        }
    }
    return NO;
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (self.state == UIGestureRecognizerStateBegan || self.state == UIGestureRecognizerStateChanged) {
        
        for (UITouch *touch in touches) {
            NSUInteger index = [_touches indexOfObject:touch];
            _UIPanGestureRecognizerScreenLocation *screenLocation = [_touchToScreenLocationDictionary objectForKey:@(index)];
            [self _endTouch:touch screenLocation:screenLocation event:event];
        }
        [self _translateTouches:touches withEvent:event];
        self.state = UIGestureRecognizerStateEnded;
        
    } else {
        self.state = UIGestureRecognizerStateFailed;
    }
}

- (void)_endTouch:(UITouch *)touch screenLocation:(_UIPanGestureRecognizerScreenLocation *)screenLocation
            event:(UIEvent *)event
{
    screenLocation.lastScreenLocation = [touch locationInView:self.view.window];
}

- (NSArray *)_screenLocations
{
    return [_touchToScreenLocationDictionary allValues];
}

@end
