//
//  UIScreenPrivate.h
//  UIKit
//
//  Created by Chen Yonghui on 12/7/13.
//  Copyright (c) 2013 Shanghai Tinynetwork Inc. All rights reserved.
//

#import <UIKit/UIScreen.h>
#include <android/native_window.h>
#import "android_native_app_glue.h"
@class UIEvent;

@interface UIScreen ()
+ (BOOL)androidSetupMainScreenWith:(struct android_app *)androidApp;
+ (void)androidTeardownMainScreen;

- (void)_setScale:(CGFloat)scale;
- (UIView *)_hitTest:(CGPoint)clickPoint event:(UIEvent *)theEvent;
@end

