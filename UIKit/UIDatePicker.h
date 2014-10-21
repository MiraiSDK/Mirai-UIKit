//
//  UIDatePicker.h
//  UIKit
//
//  Created by Chen Yonghui on 10/20/14.
//  Copyright (c) 2014 Shanghai Tinynetwork Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIControl.h>
#import <UIKit/UIKitDefines.h>

typedef NS_ENUM(NSInteger, UIDatePickerMode) {
    UIDatePickerModeTime,
    UIDatePickerModeDate,
    UIDatePickerModeDateAndTime,
    UIDatePickerModeCountDownTimer,
};

@interface UIDatePicker : UIControl <NSCoding>
@property (nonatomic) UIDatePickerMode datePickerMode;

@property (nonatomic, retain) NSLocale   *locale;
@property (nonatomic, copy)   NSCalendar *calendar;
@property (nonatomic, retain) NSTimeZone *timeZone;

@property (nonatomic, retain) NSDate *date;
@property (nonatomic, retain) NSDate *minimumDate;
@property (nonatomic, retain) NSDate *maximumDate;

@property (nonatomic) NSTimeInterval countDownDuration;
@property (nonatomic) NSInteger      minuteInterval;

- (void)setDate:(NSDate *)date animated:(BOOL)animated;

@end
