//
//  TNAConfiguration.h
//  UIKit
//
//  Created by Chen Yonghui on 6/22/14.
//  Copyright (c) 2014 Shanghai Tinynetwork Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <android/configuration.h>

typedef NS_ENUM(NSInteger, TNAConfigurationOrientation) {
    TNAConfigurationOrientationAny = ACONFIGURATION_ORIENTATION_ANY,
    TNAConfigurationOrientationPort = ACONFIGURATION_ORIENTATION_PORT,
    TNAConfigurationOrientationLand = ACONFIGURATION_ORIENTATION_LAND,
    TNAConfigurationOrientationSquare = ACONFIGURATION_ORIENTATION_SQUARE
};

typedef NS_ENUM(NSInteger, TNAConfigurationTouchScreen) {
    TNAConfigurationTouchScreenAny = ACONFIGURATION_TOUCHSCREEN_ANY,
    TNAConfigurationTouchScreenNoTouch = ACONFIGURATION_TOUCHSCREEN_NOTOUCH,
    TNAConfigurationTouchScreenStylus = ACONFIGURATION_TOUCHSCREEN_STYLUS,
    TNAConfigurationTouchScreenFinger = ACONFIGURATION_TOUCHSCREEN_FINGER
};

typedef NS_ENUM(NSInteger, TNAConfigurationDensity) {
    TNAConfigurationDensityDefault = ACONFIGURATION_DENSITY_DEFAULT,
    TNAConfigurationDensityLow = ACONFIGURATION_DENSITY_LOW,
    TNAConfigurationDensityMedium = ACONFIGURATION_DENSITY_MEDIUM,
    TNAConfigurationDensityHigh = ACONFIGURATION_DENSITY_HIGH,
    TNAConfigurationDensityNone = ACONFIGURATION_DENSITY_NONE,
};

typedef NS_ENUM(NSInteger, TNAConfigurationKeyboard) {
    TNAConfigurationKeyboardAny = ACONFIGURATION_KEYBOARD_ANY,
    TNAConfigurationKeyboardNoKeys = ACONFIGURATION_KEYBOARD_NOKEYS,
    TNAConfigurationKeyboardQWERTY = ACONFIGURATION_KEYBOARD_QWERTY,
    TNAConfigurationKeyboard12Keys = ACONFIGURATION_KEYBOARD_12KEY,
};
typedef NS_ENUM(NSInteger, TNAConfigurationNavigation) {
    TNAConfigurationNavigationAny = ACONFIGURATION_NAVIGATION_ANY,
    TNAConfigurationNavigationNoNav = ACONFIGURATION_NAVIGATION_NONAV,
    TNAConfigurationNavigationDPad = ACONFIGURATION_NAVIGATION_DPAD,
    TNAConfigurationNavigationTrackBall = ACONFIGURATION_NAVIGATION_TRACKBALL,
    TNAConfigurationNavigationWheel = ACONFIGURATION_NAVIGATION_WHEEL,
};

typedef NS_ENUM(NSInteger, TNAConfigurationKeysHidden) {
    TNAConfigurationKeysHiddenAny = ACONFIGURATION_KEYSHIDDEN_ANY,
    TNAConfigurationKeysHiddenNo = ACONFIGURATION_KEYSHIDDEN_NO,
    TNAConfigurationKeysHiddenYES = ACONFIGURATION_KEYSHIDDEN_YES,
    TNAConfigurationKeysHiddenSoft = ACONFIGURATION_KEYSHIDDEN_SOFT,
};

typedef NS_ENUM(NSInteger, TNAConfigurationNaviHidden) {
    TNAConfigurationNaviHiddenAny = ACONFIGURATION_NAVHIDDEN_ANY,
    TNAConfigurationNaviHiddenNo = ACONFIGURATION_NAVHIDDEN_NO,
    TNAConfigurationNaviHiddenYes = ACONFIGURATION_NAVHIDDEN_YES,
};

typedef NS_ENUM(NSInteger, TNAConfigurationScreenSize) {
    TNAConfigurationScreenSizeAny = ACONFIGURATION_SCREENSIZE_ANY,
    TNAConfigurationScreenSizeSmall = ACONFIGURATION_SCREENSIZE_SMALL,
    TNAConfigurationScreenSizeNormal = ACONFIGURATION_SCREENSIZE_NORMAL,
    TNAConfigurationScreenSizeLarge = ACONFIGURATION_SCREENSIZE_LARGE,
    TNAConfigurationScreenSizeXLarge = ACONFIGURATION_SCREENSIZE_XLARGE,
};

typedef NS_ENUM(NSInteger, TNAConfigurationScreenLong) {
    TNAConfigurationScreenLongAny = ACONFIGURATION_SCREENLONG_ANY,
    TNAConfigurationScreenLongNo = ACONFIGURATION_SCREENLONG_NO,
    TNAConfigurationScreenLongYes = ACONFIGURATION_SCREENLONG_YES,
};

typedef NS_ENUM(NSInteger, TNAConfigurationUIModeType) {
    TNAConfigurationUIModeTypeAny = ACONFIGURATION_UI_MODE_TYPE_ANY,
    TNAConfigurationUIModeTypeNormal = ACONFIGURATION_UI_MODE_TYPE_NORMAL,
    TNAConfigurationUIModeTypeDesk = ACONFIGURATION_UI_MODE_TYPE_DESK,
    TNAConfigurationUIModeTypeCar = ACONFIGURATION_UI_MODE_TYPE_CAR,
};
typedef NS_ENUM(NSInteger, TNAConfigurationUIModeNight) {
    TNAConfigurationUIModeNightAny = ACONFIGURATION_UI_MODE_NIGHT_ANY,
    TNAConfigurationUIModeNightNo = ACONFIGURATION_UI_MODE_NIGHT_NO,
    TNAConfigurationUIModeNightYes = ACONFIGURATION_UI_MODE_NIGHT_YES,
};

typedef NS_ENUM(NSInteger, TNAConfigurationDiff) {
    TNAConfigurationDiffMCC = ACONFIGURATION_MCC,
    TNAConfigurationDiffMNC = ACONFIGURATION_MNC,
    TNAConfigurationDiffLocale = ACONFIGURATION_LOCALE,
    TNAConfigurationDiffTouchScreen = ACONFIGURATION_TOUCHSCREEN,
    TNAConfigurationDiffKeyboard = ACONFIGURATION_KEYBOARD,
    TNAConfigurationDiffKeyboardHidden = ACONFIGURATION_KEYBOARD_HIDDEN,
    TNAConfigurationDiffNavigation = ACONFIGURATION_NAVIGATION,
    TNAConfigurationDiffOrientation = ACONFIGURATION_ORIENTATION,
    TNAConfigurationDiffDensity = ACONFIGURATION_DENSITY,
    TNAConfigurationDiffScreenSize = ACONFIGURATION_SCREEN_SIZE,
    TNAConfigurationDiffVersion = ACONFIGURATION_VERSION,
    TNAConfigurationDiffScreenLayout = ACONFIGURATION_SCREEN_LAYOUT,
    TNAConfigurationDiffUIMode = ACONFIGURATION_UI_MODE,
};

@interface TNAConfiguration : NSObject
- (instancetype)initWithAConfiguration:(AConfiguration *)config;

@property (nonatomic, assign) AConfiguration *config;

@property (nonatomic, assign) int32_t mcc;
@property (nonatomic, assign) int32_t mnc;
@property (nonatomic, strong) NSString *language;
@property (nonatomic, strong) NSString *country;
@property (nonatomic, assign) TNAConfigurationOrientation orientation;
@property (nonatomic, assign) TNAConfigurationTouchScreen touchscreen;
@property (nonatomic, assign) TNAConfigurationDensity density;
@property (nonatomic, assign) TNAConfigurationKeyboard keyboard;
@property (nonatomic, assign) TNAConfigurationNavigation navigation;
@property (nonatomic, assign) TNAConfigurationKeysHidden keysHidden;
@property (nonatomic, assign) TNAConfigurationNaviHidden navHidden;
@property (nonatomic, assign) int32_t sdkVersion;

@property (nonatomic, assign) TNAConfigurationScreenSize screenSize;
@property (nonatomic, assign) TNAConfigurationScreenLong screenLong;
@property (nonatomic, assign) TNAConfigurationUIModeType UIModeType;
@property (nonatomic, assign) TNAConfigurationUIModeNight UIModeNight;

- (TNAConfigurationDiff)diffWithConfiguration:(TNAConfiguration *)config;
- (BOOL)matchWithConfiguration:(TNAConfiguration *)config;
- (BOOL)isBetterThanConfiguration:(TNAConfiguration *)test requested:(TNAConfiguration *)requested;

@end
