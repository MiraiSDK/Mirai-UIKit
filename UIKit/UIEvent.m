//
//  UIEvent.m
//  UIKit
//
//  Created by Chen Yonghui on 1/19/14.
//  Copyright (c) 2014 Shanghai Tinynetwork Inc. All rights reserved.
//

#import "UIEvent.h"
#import "UITouch.h"

#import "UIEvent+Android.h"
#include <android/input.h>
#import "UITouch+Private.h"
//#include <string.h>
//#include <jni.h>


@implementation UIEvent {
    UITouch *_touch;
}

- (id)initWithEventType:(UIEventType)type
{
    self = [super init];
    if (self) {
        _type = type;
    }
    return self;
}

- (NSSet *)allTouches
{
    return [NSSet setWithObject:_touch];
}

- (NSSet *)touchesForWindow:(UIWindow *)window
{
    NSMutableSet *touches = [NSMutableSet setWithCapacity:1];
    for (UITouch *touch in [self allTouches]) {
        if (touch.window == window) {
            [touches addObject:touch];
        }
    }
    return touches;
}

- (NSSet *)touchesForView:(UIView *)view
{
    NSMutableSet *touches = [NSMutableSet setWithCapacity:1];
    for (UITouch *touch in [self allTouches]) {
        if (touch.view == view) {
            [touches addObject:touch];
        }
    }
    return touches;
}

- (NSSet *)touchesForGestureRecognizer:(UIGestureRecognizer *)gesture
{
    NSMutableSet *touches = [NSMutableSet setWithCapacity:1];
    for (UITouch *touch in [self allTouches]) {
        if ([touch.gestureRecognizers containsObject:gesture]) {
            [touches addObject:touch];
        }
    }
    return touches;
}

- (UIEventSubtype)subtype
{
    return UIEventSubtypeNone;
}

- (void)_setTouch:(UITouch *)t
{
    if (_touch != t) {
        _touch = t;
    }
}

- (void)_setTimestamp:(NSTimeInterval)timestamp
{
    _timestamp = timestamp;
}

@end

@implementation UIEvent (Android)

- (instancetype)initWithAInputEvent:(AInputEvent *)aEvent
{
    int32_t aType = AInputEvent_getType(aEvent);
    switch (aType) {
        case AINPUT_EVENT_TYPE_MOTION:
            return [self initWithAMotionEvent:aEvent];
            break;
        case AINPUT_EVENT_TYPE_KEY:
            return [self initWithAKeyEvent:aEvent];
            break;
            
        default:
            NSLog(@"Unknow event type:%d",aType);
            return nil;
            break;
    }
}

- (instancetype)initWithAMotionEvent:(AInputEvent *)aEvent
{
    self = [self initWithEventType:UIEventTypeTouches];
    if (self) {
        int64_t eventTime = AMotionEvent_getEventTime(aEvent);
        _timestamp = eventTime/1000000000.0f; // convert nanoSeconds to Seconds
        int64_t downTime = AMotionEvent_getDownTime(aEvent);
        float xOffset = AMotionEvent_getXOffset(aEvent);
        float yOffset = AMotionEvent_getYOffset(aEvent);
        float xPrecision = AMotionEvent_getXPrecision(aEvent);
        float yPrecision = AMotionEvent_getYPrecision(aEvent);
        size_t pointerCount = AMotionEvent_getPointerCount(aEvent);
        
        int32_t action = AMotionEvent_getAction(aEvent);
        int32_t trueAction = action & AMOTION_EVENT_ACTION_MASK;
        int32_t pointerIndex = (action & AMOTION_EVENT_ACTION_POINTER_INDEX_MASK) >> AMOTION_EVENT_ACTION_POINTER_INDEX_SHIFT;
        
        float x = AMotionEvent_getX(aEvent, pointerIndex);
        float y = AMotionEvent_getY(aEvent, pointerIndex);
        _touch = [[UITouch alloc] initWithAMotionEvent:aEvent];
        
        NSString *actionName;
        switch (trueAction) {
            case AMOTION_EVENT_ACTION_DOWN:
                actionName = @"down";
                break;
            case AMOTION_EVENT_ACTION_UP:
                actionName = @"up";
                break;
            case AMOTION_EVENT_ACTION_MOVE:
                actionName = @"move";
                break;
            case AMOTION_EVENT_ACTION_CANCEL:
                actionName = @"cancel";

                break;
            case AMOTION_EVENT_ACTION_OUTSIDE:
                actionName = @"outside";
                break;
            case AMOTION_EVENT_ACTION_POINTER_DOWN:
                actionName = @"pointer down";
                break;
            case AMOTION_EVENT_ACTION_POINTER_UP:
                actionName = @"pointer up";
                break;
            default:
                actionName = @"unknow";
                break;
        }
        
        NSLog(@"MotionEvent:\n\
              eventTime:%lld\n\
              downTime:%lld\n\
              xOffset:%f\n\
              yOffset:%f\n\
              xPrecision:%f\n\
              yPrecision:%f\n\
              pointerCount:%zu\n\
              x:%f\n\
              x:%f\n\
              action:%@\n\
              ",eventTime,downTime,xOffset,yOffset,xPrecision,yPrecision,pointerCount,x,y,actionName);

        
    }
    return self;
}

- (instancetype)initWithAKeyEvent:(AInputEvent *)aEvent
{
    self = [self initWithEventType:UIEventTypeKeyPress];
    if (self) {
        NSLog(@"Key event: action=%d keyCode=%d metaState=0x%x",
              AKeyEvent_getAction(aEvent),
              AKeyEvent_getKeyCode(aEvent),
              AKeyEvent_getMetaState(aEvent));
    }
    return self;
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"<%@: %p> timestamp:%.0f touches %@",NSStringFromClass(self.class),self, self.timestamp,self.allTouches.allObjects];
}

@end
