//
//  UIStepper.m
//  UIKit
//
//  Created by Chen Yonghui on 10/20/14.
//  Copyright (c) 2014 Shanghai Tinynetwork Inc. All rights reserved.
//

#import "UIStepper.h"
#import "UIImage.h"
#import "math.h"

#import <UIKit/UIKit.h>

#define DefaultBorderWidth 1
#define DefaultSegmentWidth 90
#define DefaultSegmentHeight 45
#define DefaultTintColor [UIColor blueColor]

#define DefaultAutorepeatTimeMinimunInterval 0.05

@interface UIStepper()
@property (nonatomic, strong) UIButton *subviewLeftSegment;
@property (nonatomic, strong) UIButton *subviewRightSegment;
@property (nonatomic, strong) NSTimer *autorepeatTriggerTimer;
@property BOOL isCurrentPressLeftSegment;
@property NSInteger currentRepeatLevel;
@property NSInteger currentRepeatTriggerCount;
@property NSInteger currentWaitTickCount;
@end

@implementation UIStepper

static NSArray *RepeatTimeIntervalArray;
static NSArray *RepeatTriggerCountArray;

+ (void)load
{
    RepeatTimeIntervalArray = @[
        @8, @5, @3, @2
    ];
    RepeatTriggerCountArray = @[
        @3, @5, @10, @0
    ];
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:[self _createStepperDefaultRectAt:frame.origin]];
    if (self) {
        [self _setDefaultValues];
        [self _makeSegments];
        [self setTintColor:DefaultTintColor];
        [self _refreshSegmentsEnable];
    }
    return self;
}

- (CGRect)_createStepperDefaultRectAt:(CGPoint)point
{
    return CGRectMake(point.x, point.y, 2*DefaultSegmentWidth, DefaultSegmentHeight);
}

#pragma mark - about value.

- (void)setValue:(double)value
{
    double oldValue = _value;
    [self _setValueWithoutTriggerValueChanged:value considerWraps:NO];
    if (oldValue != _value) {
        [self _triggerValueChangedEvent];
    }
}

- (void)setMaximumValue:(double)maximumValue
{
    _maximumValue = maximumValue;
    _minimumValue = fmin(maximumValue, _minimumValue);
    [self _resetValueToClampValueIfNeed];
}

- (void)setMinimumValue:(double)minimumValue
{
    _minimumValue = minimumValue;
    _maximumValue = fmax(minimumValue, _maximumValue);
    [self _resetValueToClampValueIfNeed];
}

- (void)setStepValue:(double)stepValue
{
    if (stepValue <= 0) {
        [NSException raise:@"NSInvalidArgumentException"
                    format:@"stepValue must be greater than 0"];
    }
    _stepValue = stepValue;
}

- (void)setWraps:(BOOL)wraps
{
    _wraps = wraps;
    [self _refreshSegmentsEnable];
}

- (void)_triggerValueChangedEvent
{
    [self sendActionsForControlEvents:UIControlEventValueChanged];
}

- (void)_setDefaultValues
{
    _value = 0;
    _minimumValue = 0;
    _maximumValue = 100;
    _stepValue = 1;
    
    _continuous = YES;
    _autorepeat = YES;
    _wraps = NO;
}

- (void)_setValueWithoutTriggerValueChanged:(double)value considerWraps:(BOOL)considerWraps
{
    if (considerWraps && self.wraps) {
        if (value > self.maximumValue) {
            value = self.minimumValue;
        } else if(value < self.minimumValue) {
            value = self.maximumValue;
        }
    } else {
        if (value > self.maximumValue) {
            value = self.maximumValue;
        } else if(value < self.minimumValue) {
            value = self.minimumValue;
        }
    }
    _value = value;
    [self _refreshSegmentsEnable];
}

- (void)_resetValueToClampValueIfNeed
{
    self.value = _value;
}

#pragma mark - subview segment maker.

- (void)_makeSegments
{
    self.subviewLeftSegment = [self _createSegmentWithSign:@"-"];
    self.subviewRightSegment = [self _createSegmentWithSign:@"+"];
    
    self.subviewLeftSegment.frame = CGRectMake(0, 0, DefaultSegmentWidth, DefaultSegmentHeight);
    self.subviewRightSegment.frame = CGRectMake(DefaultSegmentWidth, 0, DefaultSegmentWidth, DefaultSegmentHeight);
    
    [self addSubview:self.subviewLeftSegment];
    [self addSubview:self.subviewRightSegment];
}

- (UIButton *)_createSegmentWithSign:(NSString *)sign
{
    UIButton *segment = [UIButton buttonWithType:UIButtonTypeSystem];
    [segment setTitle:sign forState:UIControlStateNormal];
    [segment.layer setBorderWidth:DefaultBorderWidth];
    
    [segment addTarget:self action:@selector(_onSegmentDown:) forControlEvents:UIControlEventTouchDown];
    [segment addTarget:self action:@selector(_onSegmentUp:)
      forControlEvents:(UIControlEventTouchUpInside | UIControlEventTouchUpOutside)];
    return segment;
}

- (void)_refreshSegmentsEnable
{
    [self.subviewLeftSegment setEnabled:(self.value > self.minimumValue || self.wraps)];
    [self.subviewRightSegment setEnabled:(self.value < self.maximumValue || self.wraps)];
}

- (void)_onSegmentDown:(id)sender
{
    self.isCurrentPressLeftSegment = (sender == self.subviewLeftSegment);
    
    if (self.autorepeat) {
        [self _startAutorepeatTriggerTimter];
    }
}

// TODO: the UIControlEventTouchOutside will not be triggered (it is a bug),
// so, the NSTimer will probable not be closed when you move your figure out of the Segment and release it.
- (void)_onSegmentUp:(id)sender
{
    // **NOTE**:
    // to make sure NSTimer is closed no matter the value of self.autorepeat,
    // the [self _stopAutorepeatTriggerTimer] should always be invoked.
    // because the self.autorepeat can be changed between TouchDown and TouchUp.
    [self _stopAutorepeatTriggerTimer];
    [self _increaseValueWithStepValue];
    [self _triggerValueChangedEvent];
}

- (void)_startAutorepeatTriggerTimter
{
    [self _stopAutorepeatTriggerTimer];
    self.autorepeatTriggerTimer = [NSTimer scheduledTimerWithTimeInterval:DefaultAutorepeatTimeMinimunInterval
                                                                   target:self
                                                                 selector:@selector(_onAutorepeat)
                                                                 userInfo:nil
                                                                  repeats:YES];
    self.currentRepeatLevel = 0;
    self.currentRepeatTriggerCount = 0;
    self.currentWaitTickCount = 0;
}

- (void)_stopAutorepeatTriggerTimer
{
    if (self.autorepeatTriggerTimer != nil) {
        [self.autorepeatTriggerTimer invalidate];
        self.autorepeatTriggerTimer = nil;
    }
}

- (void)_onAutorepeat
{
    if ([self _checkCanTriggerAndIncreaseTickCount]) {
        [self _increaseTriggerCountAndAddLevelIfNeed];
        if (self.autorepeat) { // to make sure not change self.value when user set self.autorepeat as NO after start NSTimer.
            [self _increaseValueWithStepValue];
            if (self.continuous) {
                [self _triggerValueChangedEvent];
            }
        }
    }
}

- (BOOL)_checkCanTriggerAndIncreaseTickCount
{
    self.currentWaitTickCount++;
    if (self.currentWaitTickCount >= [self _getCurrentRepeatTimeInterval]) {
        self.currentWaitTickCount = 0;
        return YES;
    }
    return NO;
}

- (void)_increaseTriggerCountAndAddLevelIfNeed
{
    if (self.currentRepeatTriggerCount >= [self _getCurrentRepeatTriggerCountLimit]) {
        self.currentRepeatLevel = fmin(self.currentRepeatLevel + 1, [RepeatTimeIntervalArray count] - 1);
        self.currentRepeatTriggerCount = 0;
    }
    self.currentRepeatTriggerCount++;
}

- (void)_increaseValueWithStepValue
{
    double increaseValue = self.isCurrentPressLeftSegment? -self.stepValue: self.stepValue;
    [self _setValueWithoutTriggerValueChanged:(self.value + increaseValue) considerWraps:YES];
}

- (NSInteger)_getCurrentRepeatTriggerCountLimit
{
    return [((NSNumber *)[RepeatTriggerCountArray objectAtIndex:self.currentRepeatLevel]) integerValue];
}

- (NSInteger)_getCurrentRepeatTimeInterval
{
    return [((NSNumber *)[RepeatTimeIntervalArray objectAtIndex:self.currentRepeatLevel]) integerValue];
}

#pragma mark - basic appearance.

- (void)setTintColor:(UIColor *)color
{
    _tintColor = color;
    [self _setSegment:self.subviewLeftSegment tintColor:color];
    [self _setSegment:self.subviewRightSegment tintColor:color];
}

- (void)_setSegment:(UIButton *)segment tintColor:(UIColor *)color
{
    [segment setTitleColor:color forState:UIControlStateNormal];
    [segment.layer setBorderColor:[color CGColor]];
}

- (void)setBackgroundImage:(UIImage*)image forState:(UIControlState)state
{
    
}

- (UIImage*)backgroundImageForState:(UIControlState)state
{
    return nil;
}

- (void)setDividerImage:(UIImage*)image forLeftSegmentState:(UIControlState)leftState rightSegmentState:(UIControlState)rightState
{
    
}

- (UIImage*)dividerImageForLeftSegmentState:(UIControlState)state rightSegmentState:(UIControlState)state
{
    return nil;
}

- (void)setIncrementImage:(UIImage *)image forState:(UIControlState)state
{
    
}

- (UIImage *)incrementImageForState:(UIControlState)state
{
    return nil;
}

- (void)setDecrementImage:(UIImage *)image forState:(UIControlState)state
{
    
}

- (UIImage *)decrementImageForState:(UIControlState)state
{
    return nil;
}

@end
