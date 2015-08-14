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

static UITouch *PanTouch(NSSet *touches)
{
    for (UITouch *touch in touches) {
        return touch;
        
        if ([touch _gesture] == _UITouchGesturePan) {
            return touch;
        }
    }
    return nil;
}

@implementation UIPanGestureRecognizer
{
    CGPoint _firstScreenLocation;
    CGPoint _lastScreenLocation;
    
    NSMutableArray *_touches;
}
@synthesize maximumNumberOfTouches=_maximumNumberOfTouches, minimumNumberOfTouches=_minimumNumberOfTouches;

- (id)initWithTarget:(id)target action:(SEL)action
{
    if ((self=[super initWithTarget:target action:action])) {
        _minimumNumberOfTouches = 1;
        _maximumNumberOfTouches = NSUIntegerMax;
        _velocity = CGPointZero;
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

- (void)setTranslation:(CGPoint)translation inView:(UIView *)view
{
    _velocity = CGPointZero;
    CGPoint lastPoint = [view convertPoint:_lastScreenLocation fromView:view.window];
    CGPoint translatedPoint = CGPointMake(lastPoint.x + translation.x, lastPoint.y + translation.y);
    _firstScreenLocation = [view convertPoint:translatedPoint toView:view.window];
}

- (BOOL)_translate:(CGPoint)delta withEvent:(UIEvent *)event
{
    const NSTimeInterval timeDiff = event.timestamp - _lastMovementTime;
    
    if (!CGPointEqualToPoint(delta, CGPointZero) && timeDiff > 0) {
        _velocity.x = [self _mergeVelocity0:_velocity.x andVelocity1:(delta.x / timeDiff)];
        _velocity.y = [self _mergeVelocity0:_velocity.y andVelocity1:(delta.y / timeDiff)];
        _lastMovementTime = event.timestamp;
        return YES;
    } else {
        return NO;
    }
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
    _firstScreenLocation = CGPointZero;
    _lastScreenLocation = CGPointZero;
    [_touches removeAllObjects];
}

- (CGPoint)velocityInView:(UIView *)view
{
    return CGPointMake(-_velocity.x, -_velocity.y);
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (_touches.count == 0) {
        UITouch *touch = [touches anyObject];
        _firstScreenLocation = [touch locationInView:self.view.window];
    }
    [_touches addObjectsFromArray:touches.allObjects];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = PanTouch(touches);

    _lastScreenLocation = [touch locationInView:self.view.window];
    
    CGPoint translate = [self translationInView:self.view];
    // note that we being the gesture here in the _gesturesMoved:withEvent: method instead of the _gesturesBegan:withEvent:
    // method because the pan gesture cannot be recognized until the user moves their fingers a bit and OSX won't tag the
    // gesture as a pan until that movement has actually happened so we have to do the checking here.
    if (self.state == UIGestureRecognizerStatePossible && touch && (ABS(translate.x) > 5 || ABS(translate.y) > 5)) {
//        [self setTranslation:[touch _delta] inView:touch.view];
        _lastMovementTime = event.timestamp;
        self.state = UIGestureRecognizerStateBegan;
    } else if (self.state == UIGestureRecognizerStateBegan || self.state == UIGestureRecognizerStateChanged) {
        if (touch) {
            if ([self _translate:[touch _delta] withEvent:event]) {
//                NSLog(@"pan changed");
                self.state = UIGestureRecognizerStateChanged;
            } else {
                NSLog(@"translate failed");
            }
        } else {
            self.state = UIGestureRecognizerStateCancelled;
        }
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (self.state == UIGestureRecognizerStateBegan || self.state == UIGestureRecognizerStateChanged) {
        UITouch *touch = PanTouch([event touchesForGestureRecognizer:self]);
        _lastScreenLocation = [touch locationInView:self.view.window];

        if (touch) {
            [self _translate:[touch _delta] withEvent:event];
            self.state = UIGestureRecognizerStateEnded;
        } else {
            self.state = UIGestureRecognizerStateCancelled;
        }
    }
}

@end
