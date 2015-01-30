//
//  UIKitAndroidGlue.h
//  UIKit
//
//  Created by Chen Yonghui on 1/30/15.
//  Copyright (c) 2015 Shanghai Tinynetwork Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

#include <string.h>
#include <jni.h>
#include <android/log.h>
#include "android_native_app_glue.h"

extern struct android_app* app_state;

/**
 * Shared state for our app.
 */
struct engine {
    struct android_app* app;
    
    JNIEnv *env;
    
    int animating;
    bool isScreenReady;
    bool isWarnStart;
};

extern void handle_app_command(struct android_app* app, int32_t cmd);