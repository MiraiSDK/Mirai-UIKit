//
//  UIBarCommon.h
//  UIKit
//
//  Created by Chen Yonghui on 2/12/14.
//  Copyright (c) 2014 Shanghai Tinynetwork Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKitDefines.h>

typedef NS_ENUM(NSInteger, UIBarMetrics) {
    UIBarMetricsDefault,
    UIBarMetricsLandscapePhone,
    UIBarMetricsDefaultPrompt = 101,
    UIBarMetricsLandscapePhonePrompt,
};

typedef NS_ENUM(NSInteger, UIBarPosition) {
    UIBarPositionAny = 0,
    UIBarPositionBottom = 1,
    UIBarPositionTop = 2,
    UIBarPositionTopAttached = 3,
};// NS_ENUM_AVAILABLE_IOS(7_0);

#define UIToolbarPosition UIBarPosition
#define UIToolbarPositionAny UIBarPositionAny
#define UIToolbarPositionBottom UIBarPositionBottom
#define UIToolbarPositionTop UIBarPositionTop

@protocol UIBarPositioning <NSObject>
@property(nonatomic,readonly) UIBarPosition barPosition;
@end

@protocol UIBarPositioningDelegate <NSObject>
@optional
- (UIBarPosition)positionForBar:(id <UIBarPositioning>)bar;
@end

