//
//  UIAndroidEventsServer.h
//  UIKit
//
//  Created by Chen Yonghui on 11/11/14.
//  Copyright (c) 2014 Shanghai Tinynetwork Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UIEvent+Android.h"
#import "android_native_app_glue.h"


@interface UIAndroidEventsServer : NSObject
+ (void)start:(struct android_app *)app;
+ (BOOL)hasEvents;
+ (void)getEvent:(UIEvent *)event;
@end

void UIAndroidEventsServerStart(struct android_app *app);
bool UIAndroidEventsServerHasEvents();
void UIAndroidEventsGetEvent(UIEvent *event);
