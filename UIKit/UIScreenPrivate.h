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

@class CALayer;
@class UIEvent;
@class UIWindow;
@class TNScreenHelper;

@interface UIScreen ()

@property (nonatomic, readonly) TNScreenHelper *screenHelper;

- (void)_setScale:(CGFloat)scale;
- (void)_setPixelBounds:(CGRect)bounds;

- (UIView *)_hitTest:(CGPoint)clickPoint event:(UIEvent *)theEvent;
- (CALayer *)_pixelLayer;
- (CALayer *)_windowLayer;
- (void)_setLandscaped:(BOOL)landscaped;
- (BOOL)_isLandscaped;

typedef NS_ENUM(NSInteger, UIScreenFitMode) {
    UIScreenFitModeCenter,
    UIScreenFitModeScaleAspectFit,
};

- (void)_setScreenBounds:(CGRect)bounds scale:(CGFloat)scale fitMode:(UIScreenFitMode)mode;

@end

