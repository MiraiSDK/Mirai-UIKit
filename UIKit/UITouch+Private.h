//
//  UITouch+Android.h
//  UIKit
//
//  Created by Chen Yonghui on 2/15/14.
//  Copyright (c) 2014 Shanghai Tinynetwork Inc. All rights reserved.
//

#import "UITouch.h"

//#if ANDROID
#import <android/input.h>
//#endif

typedef enum {
    _UITouchGestureUnknown = 0,
    _UITouchGesturePan,                 // maps only to touch-enabled scrolling devices like magic trackpad, etc. for older wheels, use _UITouchGestureScrollWheel
    _UITouchGestureRotation,            // only works for touch-enabled input devices
    _UITouchGesturePinch,               // only works for touch-enabled input devices
    _UITouchGestureSwipe,               // only works for touch-enabled input devices (this is actually discrete, but OSX sends gesture begin/end events around it)
    _UITouchDiscreteGestureRightClick,  // should be pretty obvious
    _UITouchDiscreteGestureScrollWheel, // this is used by old fashioned wheel mice or when the OS sends its automatic momentum scroll events
    _UITouchDiscreteGestureMouseMove    // the mouse moved but wasn't in a gesture or the button was not being held down
} _UITouchGesture;

@interface UITouch (Private)

- (void)_setReceivedTime:(CFAbsoluteTime)receivedTime;
- (CFAbsoluteTime)_receviedTime;
- (void)_mergeNewTouchAsNextTap:(UITouch *)newTouch;
- (void)_setOnlyShowPhaseAsCancelled:(BOOL)onlyShowPhaseAsCancelled;
- (void)_setPhase:(UITouchPhase)phase screenLocation:(CGPoint)screenLocation tapCount:(NSUInteger)tapCount timestamp:(NSTimeInterval)timestamp;
- (void)_updatePhase:(UITouchPhase)phase screenLocation:(CGPoint)screenLocation timestamp:(NSTimeInterval)timestamp;
- (void)_updateGesture:(_UITouchGesture)gesture screenLocation:(CGPoint)screenLocation delta:(CGPoint)delta rotation:(CGFloat)rotation magnification:(CGFloat)magnification timestamp:(NSTimeInterval)timestamp;
- (void)_setDiscreteGesture:(_UITouchGesture)gesture screenLocation:(CGPoint)screenLocation tapCount:(NSUInteger)tapCount delta:(CGPoint)delta timestamp:(NSTimeInterval)timestamp;
- (void)_setTouchedView:(UIView *)view; // sets up the window and gesture recognizers as well
- (void)_removeFromView;                // sets the initial view to nil, but leaves window and gesture recognizers alone - used when a view is removed while touch is active
- (void)_setTouchPhaseCancelled;
- (CGPoint)_delta;
- (CGFloat)_rotation;
- (CGFloat)_magnification;
- (UIView *)_previousView;
- (_UITouchGesture)_gesture;
- (void)_updatePhase:(UITouchPhase)phase;

@property (nonatomic, assign) NSInteger identifier;
@property (nonatomic, readonly) CGPoint screenLocation;

@end

//#if ANDROID
@interface UITouch (Android)
- (instancetype)initWithAMotionEvent:(AInputEvent *)aEvent;
@end
//#endif
