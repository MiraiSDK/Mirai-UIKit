//
//  InputEvent.m
//  UIKit
//
//  Created by Chen Yonghui on 12/4/14.
//  Copyright (c) 2014 Shanghai Tinynetwork Inc. All rights reserved.
//

#import "InputEvent.h"

@implementation MotionPointer
- (instancetype)initWithMotionEvent:(AInputEvent *)event idx:(size_t)pointerIndex
{
    self = [super init];
    if (self) {

        _pointerIndex = pointerIndex;
        
        _pointerId = AMotionEvent_getPointerId(event, pointerIndex);
        _toolType = AMotionEvent_getToolType(event, pointerIndex);
        _rawX = AMotionEvent_getRawX(event, pointerIndex);
        _rawY = AMotionEvent_getRawY(event, pointerIndex);
        _x = AMotionEvent_getX(event, pointerIndex);
        _y = AMotionEvent_getY(event, pointerIndex);
        _pressure = AMotionEvent_getPressure(event, pointerIndex);
        _size = AMotionEvent_getSize(event, pointerIndex);
        _touchMajor = AMotionEvent_getTouchMajor(event, pointerIndex);
        _touchMinor = AMotionEvent_getTouchMinor(event, pointerIndex);
        _toolMajor = AMotionEvent_getToolMajor(event, pointerIndex);
        _toolMinor = AMotionEvent_getToolMinor(event, pointerIndex);
        _orientation = AMotionEvent_getOrientation(event, pointerIndex);
        
        // FIXME: axis not supported yet.
        // has 47 types of axis
        // float axisValue = AMotionEvent_getAxisValue(event, AMOTION_EVENT_AXIS_X, pointerIndex);
    }
    return self;
}
@end

@implementation InputEvent
{
    AInputEvent *_aEvent;
}

- (instancetype)initWithInputEvent:(AInputEvent *)event;
{
    self = [super init];
    if (self) {
        [self fillWithAInputEvent:event];
    }
    return self;
}
- (void)fillWithAInputEvent:(AInputEvent *)event
{
    _aEvent = event;
    
    // input event
    _type = AInputEvent_getType(event);
    _deviceId = AInputEvent_getDeviceId(event);
    _source = AInputEvent_getSource(event);
    
    if (_type == AINPUT_EVENT_TYPE_KEY) {
        NSLog(@"[Warning] key event type not supported yet.");
    }
    
    //motion event
    if (_type == AINPUT_EVENT_TYPE_MOTION) {
        _action = AMotionEvent_getAction(event);
        _flags = AMotionEvent_getFlags(event);
        _metaState = AMotionEvent_getMetaState(event);
        _buttonState = AMotionEvent_getButtonState(event);
        _edgeFlags = AMotionEvent_getEdgeFlags(event);
        _downTime = AMotionEvent_getDownTime(event);
        _eventTime = AMotionEvent_getEventTime(event);
        _xOffset = AMotionEvent_getXOffset(event);
        _yOffset = AMotionEvent_getYOffset(event);
        _xPrecision = AMotionEvent_getXPrecision(event);
        _yPrecision = AMotionEvent_getYPrecision(event);
        _pointerCount = AMotionEvent_getPointerCount(event);
        
        NSMutableArray *pointers = [NSMutableArray array];
        for (size_t idx = 0; idx < _pointerCount; idx++) {
            MotionPointer *onePointer = [[MotionPointer alloc] initWithMotionEvent:event idx:idx];
            [pointers addObject:onePointer];
        }
        _pointers = pointers;
        
        // FIXME: history not supported yet.
        //_historySize = AMotionEvent_getHistorySize(event);
        //_histories = @[];
    }
    
}

- (NSTimeInterval)timestamp
{
    return _eventTime/1000000000.0;
}

- (int32_t)trueAction
{
    return _action & AMOTION_EVENT_ACTION_MASK;
}

- (int32_t)pointerIndex
{
    return (_action & AMOTION_EVENT_ACTION_POINTER_INDEX_MASK) >> AMOTION_EVENT_ACTION_POINTER_INDEX_SHIFT;
}

- (MotionPointer *)activityPointer
{
    return self.pointers[self.pointerIndex];
}

- (AInputEvent *)aEvent
{
    return _aEvent;
}
@end
