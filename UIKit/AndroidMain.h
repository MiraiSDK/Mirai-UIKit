//
//  AndroidMain.h
//  UIKit
//
//  Created by Chen Yonghui on 1/30/15.
//  Copyright (c) 2015 Shanghai Tinynetwork Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

#include "android_native_app_glue.h"


bool AMIsLandscaped();

typedef void (*AMEventsCallback) (struct android_app *app, int32_t cmd);
void AMRegisterEventsCallback(AMEventsCallback callback);
