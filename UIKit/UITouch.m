//
//  UITouch.m
//  UIKit
//
//  Created by Chen Yonghui on 1/19/14.
//  Copyright (c) 2014 Shanghai Tinynetwork Inc. All rights reserved.
//

#import "UITouch.h"
#import "UITouch+Private.h"
#import "UIView.h"
#import "UIWindow.h"


static NSArray *GestureRecognizersForView(UIView *view)
{
    NSMutableArray *recognizers = [[NSMutableArray alloc] initWithCapacity:0];
    
    while (view) {
        [recognizers addObjectsFromArray:view.gestureRecognizers];
        view = [view superview];
    }
    
    return recognizers;
}


@implementation UITouch {
    _UITouchGesture _gesture;
    CGPoint _delta;
    CGFloat _rotation;
    CGFloat _magnification;
    CGPoint _location;
    CGPoint _previousLocation;

}

- (id)init
{
    self = [super init];
    if (self) {
        _phase = UITouchPhaseCancelled;
//        _gesture = _UITouchGestureUnknown;

    }
    return self;
}

- (void)_setPhase:(UITouchPhase)phase screenLocation:(CGPoint)screenLocation tapCount:(NSUInteger)tapCount timestamp:(NSTimeInterval)timestamp;
{
    _phase = phase;
    _gesture = _UITouchGestureUnknown;
    _previousLocation = _location = screenLocation;
    _tapCount = tapCount;
    _timestamp = timestamp;
    _rotation = 0;
    _magnification = 0;
}

- (void)_updatePhase:(UITouchPhase)phase screenLocation:(CGPoint)screenLocation timestamp:(NSTimeInterval)timestamp;
{
    if (!CGPointEqualToPoint(screenLocation, _location)) {
        _previousLocation = _location;
        _location = screenLocation;
        
        //FIXME: is it right?
        _delta = CGPointMake(screenLocation.x- _previousLocation.x, screenLocation.y - _previousLocation.y);
    }
    
    _phase = phase;
    _timestamp = timestamp;
}

- (void)_updateGesture:(_UITouchGesture)gesture screenLocation:(CGPoint)screenLocation delta:(CGPoint)delta rotation:(CGFloat)rotation magnification:(CGFloat)magnification timestamp:(NSTimeInterval)timestamp;
{
    if (!CGPointEqualToPoint(screenLocation, _location)) {
        _previousLocation = _location;
        _location = screenLocation;
    }
    
//    _phase = _UITouchPhaseGestureChanged;
    
    _gesture = gesture;
    _delta = delta;
    _rotation = rotation;
    _magnification = magnification;
    _timestamp = timestamp;
}

- (void)_setDiscreteGesture:(_UITouchGesture)gesture screenLocation:(CGPoint)screenLocation tapCount:(NSUInteger)tapCount delta:(CGPoint)delta timestamp:(NSTimeInterval)timestamp;
{
//    _phase = _UITouchPhaseDiscreteGesture;
    _gesture = gesture;
    _previousLocation = _location = screenLocation;
    _tapCount = tapCount;
    _delta = delta;
    _timestamp = timestamp;
    _rotation = 0;
    _magnification = 0;
}

- (_UITouchGesture)_gesture
{
    return _gesture;
}

- (void)_setTouchedView:(UIView *)view
{
    if (_view != view) {
        _view = view;
    }
    
    if (_window != view.window) {
        _window = view.window;
    }
    
    _gestureRecognizers = [GestureRecognizersForView(_view) copy];
}

- (void)_removeFromView
{
    NSMutableArray *remainingRecognizers = [_gestureRecognizers mutableCopy];
    
    // if the view is being removed from this touch, we need to remove/cancel any gesture recognizers that belong to the view
    // being removed. this kinda feels like the wrong place for this, but the touch itself has a list of potential gesture
    // recognizers attached to it so an active touch only considers the recongizers that were present at the point the touch
    // first touched the screen. it could easily have recognizers attached to it from superviews of the view being removed so
    // we can't just cancel them all. the view itself could cancel its own recognizers, but then it needs a way to remove them
    // from an active touch so in a sense we're right back where we started. so I figured we might as well just take care of it
    // here and see what happens.
//    for (UIGestureRecognizer *recognizer in _gestureRecognizers) {
//        if (recognizer.view == _view) {
//            if (recognizer.state == UIGestureRecognizerStateBegan || recognizer.state == UIGestureRecognizerStateChanged) {
//                recognizer.state = UIGestureRecognizerStateCancelled;
//            }
//            [remainingRecognizers removeObject:recognizer];
//        }
//    }
    
    _gestureRecognizers = [remainingRecognizers copy];
    
    _view = nil;
}

- (void)_setTouchPhaseCancelled
{
    _phase = UITouchPhaseCancelled;
}

- (CGPoint)_delta
{
    return _delta;
}

- (CGFloat)_rotation
{
    return _rotation;
}

- (CGFloat)_magnification
{
    return _magnification;
}

- (CGPoint)_convertLocationPoint:(CGPoint)thePoint toView:(UIView *)inView
{
    UIWindow *window = self.window;
    
    // The stored location should always be in the coordinate space of the UIScreen that contains the touch's window.
    // So first convert from the screen to the window:
    CGPoint point = [window convertPoint:thePoint fromWindow:nil];
    
    // Then convert to the desired location (if any).
    if (inView) {
        point = [inView convertPoint:point fromView:window];
    }
    
    return point;
}


- (CGPoint)locationInView:(UIView *)view
{
    return [self _convertLocationPoint:_location toView:view];
}

- (CGPoint)previousLocationInView:(UIView *)view
{
    return [self _convertLocationPoint:_previousLocation toView:view];
}

- (NSString *)description
{
    NSString *phase = @"";
    switch (self.phase) {
        case UITouchPhaseBegan:
            phase = @"Began";
            break;
        case UITouchPhaseMoved:
            phase = @"Moved";
            break;
        case UITouchPhaseStationary:
            phase = @"Stationary";
            break;
        case UITouchPhaseEnded:
            phase = @"Ended";
            break;
        case UITouchPhaseCancelled:
            phase = @"Cancelled";
            break;
//        case _UITouchPhaseGestureBegan:
//            phase = @"GestureBegan";
//            break;
//        case _UITouchPhaseGestureChanged:
//            phase = @"GestureChanged";
//            break;
//        case _UITouchPhaseGestureEnded:
//            phase = @"GestureEnded";
//            break;
//        case _UITouchPhaseDiscreteGesture:
//            phase = @"DiscreteGesture";
//            break;
    }
    return [NSString stringWithFormat:@"<%@: %p; timestamp = %e; tapCount = %lu; phase = %@; view = %@; window = %@>", [self className], self, self.timestamp, (unsigned long)self.tapCount, phase, self.view, self.window];
}

@end

@implementation UITouch (Android)
- (instancetype)initWithAMotionEvent:(AInputEvent *)aEvent
{
    self = [self init];
    if (self) {
        int32_t action = AMotionEvent_getAction(aEvent);
        int32_t trueAction = action & AMOTION_EVENT_ACTION_MASK;
        int32_t pointerIndex = (action & AMOTION_EVENT_ACTION_POINTER_INDEX_MASK) >> AMOTION_EVENT_ACTION_POINTER_INDEX_SHIFT;
        
        float x = AMotionEvent_getX(aEvent, pointerIndex);
        float y = AMotionEvent_getY(aEvent, pointerIndex);
        _location = CGPointMake(x, y);
        
        switch (trueAction) {
            case AMOTION_EVENT_ACTION_DOWN:
                _phase = UITouchPhaseBegan;
                break;
            case AMOTION_EVENT_ACTION_UP:
                _phase = UITouchPhaseEnded;
                break;
            case AMOTION_EVENT_ACTION_MOVE:
                _phase = UITouchPhaseMoved;
                break;
            case AMOTION_EVENT_ACTION_CANCEL:
                _phase = UITouchPhaseCancelled;
                break;
            case AMOTION_EVENT_ACTION_OUTSIDE:
                _phase = UITouchPhaseCancelled;
                break;
            case AMOTION_EVENT_ACTION_POINTER_DOWN:
                //FIXME: what?
                _phase = UITouchPhaseStationary;
                break;
            case AMOTION_EVENT_ACTION_POINTER_UP:
                _phase = UITouchPhaseStationary;
                break;
            default:
                _phase = UITouchPhaseCancelled;
                break;
        }
    }
    return self;
}

@end

