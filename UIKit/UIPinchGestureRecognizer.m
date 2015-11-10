//
//  UIPinchGestureRecognizer.m
//  UIKit
//
//  Created by Chen Yonghui on 8/5/14.
//  Copyright (c) 2014 Shanghai TinyNetwork Inc. All rights reserved.
//

#import "UIPinchGestureRecognizer.h"
#import <UIKit/UIGestureRecognizerSubclass.h>
#import "TNGestureRecognizerMath.h"
#import "UITouch.h"

@interface  UIPinchGestureRecognizer()
@property (nonatomic, strong) NSMutableArray *touches;

@end

@implementation UIPinchGestureRecognizer {
//    CGFloat           _initialTouchDistance;
//    CGFloat           _initialTouchScale;
//    NSTimeInterval    _lastTouchTime;
//    CGFloat           _velocity;
//    CGFloat           _previousVelocity;
//    CGFloat           _scaleThreshold;
//    CGAffineTransform _transform;
//    CGPoint           _anchorPoint;
//    //UITouch          *_touches[2];
//    CGFloat           _hysteresis;
//    id                _transformAnalyzer;
//    unsigned int      _endsOnSingleTouch:1;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _touches = [NSMutableArray array];
    }
    return self;
}


- (void)reset
{
    [super reset];
    
    _initialTouchDistance = 0;
    _scale = 1;
    [_touches removeAllObjects];
}
// Begins:  when two touches have moved enough to be considered a pinch
// Changes: when a finger moves while two fingers remain down
// Ends:    when both fingers have lifted

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    for (UITouch *t in touches) {
        if (![_touches containsObject:t]) {
            [_touches addObject:t];
        }
    }
    
    if (_touches.count > 2) {
        if (self.state == UIGestureRecognizerStateBegan || self.state == UIGestureRecognizerStateChanged) {
            self.state = UIGestureRecognizerStateEnded;
        } else if (self.state == UIGestureRecognizerStatePossible) {
            self.state = UIGestureRecognizerStateFailed;
        }
    } else if (_touches.count == 2) {
        _initialTouchDistance = [self currentTouchDistance];
    }
}

- (CGFloat)currentTouchDistance
{
    UITouch *touch1 = _touches[0];
    UITouch *touch2 = _touches[1];
    CGPoint p1 = [touch1 locationInView:self.view];
    CGPoint p2 = [touch2 locationInView:self.view];
    return CGPointDistance(p1, p2);
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (_touches.count == 2) {
        CGFloat newDistance = [self currentTouchDistance];
        if (self.state == UIGestureRecognizerStatePossible) {
            if (fabs(newDistance - _initialTouchDistance) > 3 ) {
                self.state = UIGestureRecognizerStateBegan;
            }
        } else if (self.state == UIGestureRecognizerStateBegan || self.state == UIGestureRecognizerStateChanged) {
            self.state = UIGestureRecognizerStateChanged;
            _scale = newDistance / _initialTouchDistance;
        }
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    for (UITouch *t in touches) {
        [_touches removeObject:t];
    }
    
    if (_touches.count != 2) {
        if (self.state == UIGestureRecognizerStateBegan || self.state == UIGestureRecognizerStateChanged) {
            self.state = UIGestureRecognizerStateEnded;
        } else if (self.state == UIGestureRecognizerStatePossible) {
            self.state = UIGestureRecognizerStateFailed;
        }
    }
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (self.state == UIGestureRecognizerStateBegan ||
        self.state == UIGestureRecognizerStateChanged) {
        self.state = UIGestureRecognizerStateCancelled;
    } else if (self.state == UIGestureRecognizerStatePossible) {
        self.state = UIGestureRecognizerStateFailed;
    }
}

@end
