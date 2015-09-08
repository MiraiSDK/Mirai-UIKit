//
//  UIAndroidEventsServer.m
//  UIKit
//
//  Created by Chen Yonghui on 11/11/14.
//  Copyright (c) 2014 Shanghai Tinynetwork Inc. All rights reserved.
//

#import "UIAndroidEventsServer.h"

#import "InputEvent.h"

@implementation UIAndroidEventsServer
{
    struct android_app* app_state;
    UIEvent *_event;
    NSRecursiveLock *_eventQueueLock;
    
    NSMutableArray *_eventQueue;
    
    BOOL _paused;
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
        
        [event handleInputEvent:inputEvent];
    }
}

- (void)resume
{
    _paused = NO;
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
