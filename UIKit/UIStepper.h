//
//  UIStepper.h
//  UIKit
//
//  Created by Chen Yonghui on 10/20/14.
//  Copyright (c) 2014 Shanghai Tinynetwork Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKitDefines.h>
#import <UIKit/UIControl.h>

@class UIButton, UIImageView;
@class UIImage;

@interface UIStepper : UIControl

@property(nonatomic,getter=isContinuous) BOOL continuous; // if YES, value change events are sent any time the value changes during interaction. default = YES
@property(nonatomic) BOOL autorepeat;                     // if YES, press & hold repeatedly alters value. default = YES
@property(nonatomic) BOOL wraps;                          // if YES, value wraps from min <-> max. default = NO

@property(nonatomic) double value;                        // default is 0. sends UIControlEventValueChanged. clamped to min/max
@property(nonatomic) double minimumValue;                 // default 0. must be less than maximumValue
@property(nonatomic) double maximumValue;                 // default 100. must be greater than minimumValue
@property(nonatomic) double stepValue;                    // default 1. must be greater than 0

// The tintColor is inherited through the superview hierarchy. See UIView for more information.
@property(nonatomic,retain) UIColor *tintColor;

// a background image which will be 3-way stretched over the whole of the control. Each half of the stepper will paint the image appropriate for its state
- (void)setBackgroundImage:(UIImage*)image forState:(UIControlState)state;
- (UIImage*)backgroundImageForState:(UIControlState)state;

// an image which will be painted in between the two stepper segments. The image is selected depending both segments' state
- (void)setDividerImage:(UIImage*)image forLeftSegmentState:(UIControlState)leftState rightSegmentState:(UIControlState)rightState;
- (UIImage*)dividerImageForLeftSegmentState:(UIControlState)state rightSegmentState:(UIControlState)state;

// the glyph image for the plus/increase button
- (void)setIncrementImage:(UIImage *)image forState:(UIControlState)state;
- (UIImage *)incrementImageForState:(UIControlState)state;
// the glyph image for the minus/decrease button
- (void)setDecrementImage:(UIImage *)image forState:(UIControlState)state;
- (UIImage *)decrementImageForState:(UIControlState)state;

@end
