//
//  UIEvent+Android.h
//  UIKit
//
//  Created by Chen Yonghui on 2/15/14.
//  Copyright (c) 2014 Shanghai Tinynetwork Inc. All rights reserved.
//


#import "UIEvent.h"
#include <android/input.h>

#pragma mark - Private Declarations

@interface UIEvent (Private)
- (id)initWithEventType:(UIEventType)type;
- (void)_setTouch:(UITouch *)touch;
- (void)_setTimestamp:(NSTimeInterval)timestamp;
@end

@interface UIEvent (Android)
- (instancetype)initWithAInputEvent:(AInputEvent *)aEvent;

@end
