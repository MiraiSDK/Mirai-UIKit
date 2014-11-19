//
//  UIAndroidEventsServer.m
//  UIKit
//
//  Created by Chen Yonghui on 11/11/14.
//  Copyright (c) 2014 Shanghai Tinynetwork Inc. All rights reserved.
//

#import "UIAndroidEventsServer.h"

@implementation UIAndroidEventsServer
{
    struct android_app* app_state;
    UIEvent *_event;
    AInputEvent *_aEvent;
    NSRecursiveLock *_eventLock;
    
}

static void handle_app_command(struct android_app* app, int32_t cmd);
static int32_t handle_input(struct android_app* app, AInputEvent* event);
static UIAndroidEventsServer *eventServer;


- (instancetype)initWithAndroidApp:(struct android_app *)app
{
    self = [super init];
    if (self) {
        app_state = app;
        
        app_state->onInputEvent = handle_input;
        
        _event = [[UIEvent alloc] initWithEventType:UIEventTypeTouches];
        
        _eventLock = [[NSRecursiveLock alloc] init];
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
        while ((ident=ALooper_pollAll(-1, NULL, &events, (void**)&source))) {
            if (source != NULL) {
                source->process(app_state,source);
                hasInput = YES;
            }
            
            if (hasInput) {
                [self performSelectorOnMainThread:@selector(eventAlive) withObject:nil waitUntilDone:YES];
                hasInput = NO;
            }
        }
        
        NSLog(@"quit event server");
        
    }
}


- (void)eventAlive{}

static int32_t handle_input(struct android_app* app, AInputEvent* event)
{
    NSLog(@"handle_input");
    int32_t aType = AInputEvent_getType(event);
    if (aType == AINPUT_EVENT_TYPE_MOTION) {
        //[eventServer->_event _updateWithAEvent:event];
    }
    
    [eventServer->_eventLock lock];
    eventServer->_aEvent = event;
    [eventServer->_eventLock unlock];

    return 1;
}

static void handle_app_command(struct android_app* app, int32_t cmd)
{
    
}

#pragma mark - public access

void UIAndroidEventsServerStart(struct android_app *app)
{
    eventServer = [[UIAndroidEventsServer alloc] initWithAndroidApp:app];
    [eventServer run];
}

bool UIAndroidEventsServerHasEvents() {
        [eventServer->_eventLock lock];
    BOOL hasEvent = (eventServer->_aEvent != NULL);
        [eventServer->_eventLock unlock];
    return hasEvent;
}

void UIAndroidEventsGetEvent(UIEvent *event) {
    
    [eventServer->_eventLock lock];
    [event _updateWithAEvent:eventServer->_aEvent];
    eventServer->_aEvent = NULL;
    [eventServer->_eventLock unlock];
}
@end
