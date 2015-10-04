//
//  UIAndroidEventsServer.m
//  UIKit
//
//  Created by Chen Yonghui on 11/11/14.
//  Copyright (c) 2014 Shanghai Tinynetwork Inc. All rights reserved.
//

#import "UIAndroidEventsServer.h"

#import "InputEvent.h"
#import "UIGestureRecognizer.h"
#import "UITouch+Private.h"
#import "UIGeometry.h"

#define kBeInvalidTime 0.8
#define kInvalidTimerFireNeedTime 2.4
#define kTapLimitAreaSize 27

@implementation UIAndroidEventsServer
{
    struct android_app* app_state;
    
    UIEvent *_event;
    NSRecursiveLock *_eventQueueLock;
    
    NSMutableArray *_eventQueue;
    NSMutableSet *_touchesBuffer;
    
    BOOL _paused;
    BOOL _anyTimerIsWaitingForFiring;
}

static int32_t handle_input(struct android_app* app, AInputEvent* event);
static UIAndroidEventsServer *eventServer;


- (instancetype)initWithAndroidApp:(struct android_app *)app
{
    self = [super init];
    if (self) {
        app_state = app;
        _paused = YES;
        
        app_state->onInputEvent = handle_input;
        
        _event = [[UIEvent alloc] initWithEventType:UIEventTypeTouches];
        
        _eventQueueLock = [[NSRecursiveLock alloc] init];
        
        _eventQueue = [NSMutableArray array];
        _touchesBuffer = [NSMutableSet set];
        
    }
    return self;
}

- (void)run
{
    @autoreleasepool {
        int ident;
        int events;
        struct android_poll_source* source = NULL;
        
        BOOL hasInput = NO;
        while (1) {
            if (_paused) {continue;};
            
            ident=ALooper_pollAll(-1, NULL, &events, (void**)&source);
            
            if (source != NULL) {
                source->process(app_state,source);

                if (source->id == LOOPER_ID_INPUT) {
                    hasInput = YES;
                }
            }
            
            if (hasInput) {
                [self performSelectorOnMainThread:@selector(eventAlive) withObject:nil waitUntilDone:YES];
                hasInput = NO;
            }
            
            if (app_state->destroyRequested) {
                NSLog(@"meet destroyRequestedroyed.");
                break;
            }
        }
        
        NSLog(@"quit event server");
        
    }
}


- (void)eventAlive{}

static int32_t handle_input(struct android_app* app, AInputEvent* event)
{
    int32_t aType = AInputEvent_getType(event);
    if (aType == AINPUT_EVENT_TYPE_MOTION) {
        InputEvent *ie = [[InputEvent alloc] initWithInputEvent:event];
        [eventServer->_eventQueueLock lock];
        [eventServer->_eventQueue addObject:ie];
        [eventServer->_eventQueueLock unlock];
    }

    return 1;
}

- (BOOL)hasEvents
{
    [_eventQueueLock lock];
    BOOL hasEvent = [_eventQueue count] > 0;
    [_eventQueueLock unlock];

    return hasEvent;
}

- (void)getEvent:(UIEvent *)event
{
    [_eventQueueLock lock];
    InputEvent *inputEvent = [_eventQueue objectAtIndex:0];
    [_eventQueue removeObjectAtIndex:0];
    [_eventQueueLock unlock];
    
    int32_t action = inputEvent.trueAction;
    
    if (action == AMOTION_EVENT_ACTION_DOWN ||
        action == AMOTION_EVENT_ACTION_UP ||
        action == AMOTION_EVENT_ACTION_MOVE ||
        action == AMOTION_EVENT_ACTION_POINTER_DOWN ||
        action == AMOTION_EVENT_ACTION_POINTER_UP ||
        action == AMOTION_EVENT_ACTION_CANCEL) {
        
        [self _clearInvalidTouches];
        [self _pickOutAndHandleNewTouchFromEvent:event];
        [self _waitThenClearInvalidTouches];
        
        [event handleInputEvent:inputEvent];
    }
}

- (void)resume
{
    _paused = NO;
}

#pragma mark - touch tap count buffer

- (void)_clearInvalidTouches
{
    CFAbsoluteTime currentTime = CFAbsoluteTimeGetCurrent();
    NSMutableSet *invalidTouches = [[NSMutableSet alloc] init];
    for (UITouch *touch in _touchesBuffer) {
        if ([self _touchWasInvalid:touch currentTime:currentTime]) {
            [invalidTouches addObject:touch];
        }
    }
    [_touchesBuffer minusSet:invalidTouches];
}

- (void)_pickOutAndHandleNewTouchFromEvent:(UIEvent *)event
{
    CFAbsoluteTime currentTime = CFAbsoluteTimeGetCurrent();
    NSMutableSet *notBeEatenTouches = [NSMutableSet set];
    
    for (UITouch *touch in [event allTouches]) {
        if (![_touchesBuffer containsObject:touch]) {
            [touch _setReceivedTime:currentTime];
            UITouch *oldTouch = [self _oldTouchThatWillEatThisNewTouch:touch];
            if (oldTouch) {
                [oldTouch _mergeNewTouchAsNextTap:touch];
                [event _replaceTouch:touch asTouch:oldTouch];
            } else {
                [notBeEatenTouches addObject:touch];
            }
        }
    }
    [_touchesBuffer unionSet:notBeEatenTouches];
}

- (UITouch *)_oldTouchThatWillEatThisNewTouch:(UITouch *)newTouch
{
    CFAbsoluteTime currentTime = CFAbsoluteTimeGetCurrent();
    for (UITouch *oldTouch in _touchesBuffer) {
        if (newTouch != oldTouch &&
            newTouch.phase == UITouchPhaseBegan &&
            ![self _touchWasInvalid:newTouch currentTime:currentTime] &&
            [self _touch:newTouch isCloseEnoughToOtherTouch:oldTouch]) {
            return oldTouch;
        }
    }
    return nil;
}

- (BOOL)_touchWasInvalid:(UITouch *)touch currentTime:(CFAbsoluteTime)currentTime
{
    return kBeInvalidTime < currentTime - [touch _receviedTime];
}

- (void)_waitThenClearInvalidTouches
{
    if (!_anyTimerIsWaitingForFiring) {
        [NSTimer scheduledTimerWithTimeInterval:kInvalidTimerFireNeedTime target:self selector:@selector(_fireToClearInvalidTouches:) userInfo:nil repeats:NO];
        _anyTimerIsWaitingForFiring = YES;
    }
}

- (void)_fireToClearInvalidTouches:(NSTimer *)timer
{
    [self _clearInvalidTouches];
    _anyTimerIsWaitingForFiring = NO;
    
    if (_touchesBuffer.count > 0) {
        [self _waitThenClearInvalidTouches];
    }
}

- (BOOL)_touch:(UITouch *)touch0 isCloseEnoughToOtherTouch:(UITouch *)touch1
{
    CGPoint point0 = touch0.screenLocation;
    CGPoint point1 = touch1.screenLocation;
    
    return ABS(point0.x - point1.x) <= kTapLimitAreaSize &&
           ABS(point0.y - point1.y) <= kTapLimitAreaSize;
}

#pragma mark - public class access
+ (BOOL)hasEvents
{
    return [eventServer hasEvents];
}

+ (void)getEvent:(UIEvent *)event
{
    [eventServer getEvent:event];
}

+ (void)start:(struct android_app *)app
{
    eventServer = [[UIAndroidEventsServer alloc] initWithAndroidApp:app];
    [eventServer run];
}
@end

#pragma mark - public c access

void UIAndroidEventsServerStart(struct android_app *app)
{
    eventServer = [[UIAndroidEventsServer alloc] initWithAndroidApp:app];
    [eventServer run];
}

void UIAndroidEventsServerResume()
{
    [eventServer resume];
}

bool UIAndroidEventsServerHasEvents() {
    return [eventServer hasEvents];
}

void UIAndroidEventsGetEvent(UIEvent *event) {
    [eventServer getEvent:event];
}
