//
//  UIAndroidEventsServer.m
//  UIKit
//
//  Created by Chen Yonghui on 11/11/14.
//  Copyright (c) 2014 Shanghai Tinynetwork Inc. All rights reserved.
//

#import "UIAndroidEventsServer.h"
#import "android_native_app_glue.h"

@implementation UIAndroidEventsServer
{
    struct android_app* app_state;
}

static void handle_app_command(struct android_app* app, int32_t cmd);
static int32_t handle_input(struct android_app* app, AInputEvent* event);

- (instancetype)initWithAndroidApp:(struct android_app *)app
{
    self = [super init];
    if (self) {
        app_state = app;
        
        app_state->userData = &self;
        app_state->onAppCmd = handle_app_command;
        app_state->onInputEvent = handle_input;

    }
    return self;
}
- (UIEvent *)event
{
    
    return nil;
}

static int32_t handle_input(struct android_app* app, AInputEvent* event)
{
    return 0;
}

static void handle_app_command(struct android_app* app, int32_t cmd)
{
    
}

@end
