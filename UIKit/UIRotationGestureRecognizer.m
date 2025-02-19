//
//  TNRotationGestureRecognizer.m
//  DupAnimation
//
//  Created by Chen Yonghui on 8/5/14.
//  Copyright (c) 2014 Shanghai TinyNetwork Inc. All rights reserved.
//

#import "UIRotationGestureRecognizer.h"
#import <UIKit/UIGestureRecognizerSubclass.h>
#import "TNGestureRecognizerMath.h"
#import "UITouch.h"

@interface UIRotationGestureRecognizer ()
@property (nonatomic, strong) NSMutableArray *touches;
@end

@implementation UIRotationGestureRecognizer {
    double            _initialTouchDistance;
    double            _initialTouchAngle;
    double            _currentTouchAngle;
    NSInteger         _currentRotationCount;
    NSTimeInterval    _lastTouchTime;
    CGFloat           _velocity;
    CGFloat           _previousVelocity;
    CGPoint           _anchorPoint;
    id                _transformAnalyzer;
    //    UITouch          *_touches[2];
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
    
    [_touches removeAllObjects];
    _initialTouchDistance = 0;
    _initialTouchAngle = 0;
    
}

double CGPointAngle(CGPoint p1,CGPoint p2)
{
    double deltaX = p2.x - p1.x;
    double deltaY = p2.y - p1.y;
    
    double angleInRadin = atan2(deltaY, deltaX);
    return angleInRadin;
}

// Begins:  when two touches have moved enough to be considered a rotation
// Changes: when a finger moves while two fingers are down
// Ends:    when both fingers have lifted

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    for (UITouch *t in touches) {
        if (![_touches containsObject:t]) {
            [_touches addObject:t];
        }
    }
    
    if (_touches.count > 2) {
        if (self.state == UIGestureRecognizerStatePossible) {
            self.state = UIGestureRecognizerStateFailed;
        } else {
            self.state = UIGestureRecognizerStateEnded;
        }
    } else if (_touches.count == 2) {
        _initialTouchDistance = [self currentTouchDistance];
        _initialTouchAngle = [self currentTouchAngle];
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

- (double)currentTouchAngle
{
    UITouch *touch1 = _touches[0];
    UITouch *touch2 = _touches[1];
    CGPoint p1 = [touch1 locationInView:self.view];
    CGPoint p2 = [touch2 locationInView:self.view];
    return CGPointAngle(p1, p2);
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    //    CGFloat newDistance = [self currentTouchDistance];
    if (_touches.count == 2) {
        double newAngle = [self currentTouchAngle];
        
        if (self.state == UIGestureRecognizerStatePossible) {
            if (fabs(newAngle - _initialTouchDistance) > 3 ) {
                self.state = UIGestureRecognizerStateBegan;
            }
        } else if (self.state == UIGestureRecognizerStateBegan || self.state == UIGestureRecognizerStateChanged) {
            _currentTouchAngle = newAngle;
            _rotation = _currentTouchAngle - _initialTouchAngle;
            
            self.state = UIGestureRecognizerStateChanged;
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
