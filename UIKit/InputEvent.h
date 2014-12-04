//
//  InputEvent.h
//  UIKit
//
//  Created by Chen Yonghui on 12/4/14.
//  Copyright (c) 2014 Shanghai Tinynetwork Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#include <android/input.h>

@interface MotionPointer : NSObject

@property (nonatomic, assign) size_t pointerIndex;
@property (nonatomic, assign) int32_t pointerId;
@property (nonatomic, assign) int32_t toolType;
@property (nonatomic, assign) int32_t action;
@property (nonatomic,assign) float rawX;
@property (nonatomic,assign) float rawY;
@property (nonatomic,assign) float x;
@property (nonatomic,assign) float y;
@property (nonatomic,assign) float pressure;
@property (nonatomic,assign) float size;
@property (nonatomic,assign) float touchMajor;
@property (nonatomic,assign) float touchMinor;
@property (nonatomic,assign) float toolMajor;
@property (nonatomic,assign) float toolMinor;
@property (nonatomic,assign) float orientation;

//@property (nonatomic,assign) float axisValue;
//- (float)valueForAxis:(int32_t)axis;
@end

@interface InputEvent : NSObject
@property (nonatomic, assign) int32_t type;
@property (nonatomic, assign) int32_t deviceId;
@property (nonatomic, assign) int32_t source;

@property (nonatomic, assign) int32_t action;
@property (nonatomic, assign) int32_t flags;
@property (nonatomic, assign) int32_t metaState;
@property (nonatomic, assign) int32_t buttonState;
@property (nonatomic, assign) int32_t edgeFlags;
@property (nonatomic, assign) int64_t downTime; //nano-second
@property (nonatomic, assign) int64_t eventTime; // nano-second
@property (nonatomic, assign) float xOffset;
@property (nonatomic, assign) float yOffset;
@property (nonatomic, assign) float xPrecision;
@property (nonatomic, assign) float yPrecision;

@property (nonatomic, assign) size_t pointerCount;
@property (nonatomic, strong) NSArray *pointers;

@property (nonatomic,assign) size_t historySize;
@property (nonatomic,strong) NSArray *histories;

- (instancetype)initWithInputEvent:(AInputEvent *)event;

- (NSTimeInterval)timestamp;
- (int32_t)trueAction;
- (int32_t)pointerIndex;
- (MotionPointer *)activityPointer;
- (AInputEvent *)aEvent;
@end