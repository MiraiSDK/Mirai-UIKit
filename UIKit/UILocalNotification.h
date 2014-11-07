//
//  UILocalNotification.h
//  UIKit
//
//  Created by Chen Yonghui on 11/7/14.
//  Copyright (c) 2014 Shanghai Tinynetwork Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKitDefines.h>

@class CLRegion;

@interface UILocalNotification : NSObject <NSCopying, NSCoding>
@property(nonatomic,copy) NSDate *fireDate;
@property(nonatomic,copy) NSTimeZone *timeZone;

@property(nonatomic) NSCalendarUnit repeatInterval;
@property(nonatomic,copy) NSCalendar *repeatCalendar;

// location-based scheduling

@property(nonatomic,copy) CLRegion *region;// NS_AVAILABLE_IOS(8_0);
@property(nonatomic,assign) BOOL regionTriggersOnce;// NS_AVAILABLE_IOS(8_0);

// alerts
@property(nonatomic,copy) NSString *alertBody;
@property(nonatomic) BOOL hasAction;
@property(nonatomic,copy) NSString *alertAction;
@property(nonatomic,copy) NSString *alertLaunchImage;

// sound
@property(nonatomic,copy) NSString *soundName;

// badge
@property(nonatomic) NSInteger applicationIconBadgeNumber;

// user info
@property(nonatomic,copy) NSDictionary *userInfo;

@property (nonatomic, copy) NSString *category;// NS_AVAILABLE_IOS(8_0);

@end

UIKIT_EXTERN NSString *const UILocalNotificationDefaultSoundName;

