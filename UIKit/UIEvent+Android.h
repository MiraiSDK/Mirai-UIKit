//
//  UIEvent+Android.h
//  UIKit
//
//  Created by Chen Yonghui on 2/15/14.
//  Copyright (c) 2014 Shanghai Tinynetwork Inc. All rights reserved.
//


#import "UIEvent.h"
#include <android/input.h>
@class UITouch;
@class InputEvent;

#pragma mark - Private Declarations

@interface UIEvent (Private)
- (id)initWithEventType:(UIEventType)type;
- (void)_removeTouches:(NSSet *)touches;
- (void)_setTimestamp:(NSTimeInterval)timestamp;
- (void)_cleanTouches;
@end

@interface UIEvent (Android)
- (instancetype)initWithAInputEvent:(AInputEvent *)aEvent;
- (void)_updateTouchesWithEvent:(AInputEvent *)aEvent;
- (UITouch *)_touchForIdentifier:(NSInteger)identifier;
- (void)_updateWithAEvent:(AInputEvent *)aEvent;

- (AInputEvent *)_AInputEvent;
- (void)handleInputEvent:(InputEvent *)inputEvent;
- (void)configureWithInputEvent:(InputEvent *)inputEvent;
@end
