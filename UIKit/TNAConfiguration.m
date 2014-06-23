//
//  TNAConfiguration.m
//  UIKit
//
//  Created by Chen Yonghui on 6/22/14.
//  Copyright (c) 2014 Shanghai Tinynetwork Inc. All rights reserved.
//

#import "TNAConfiguration.h"

@implementation TNAConfiguration

- (instancetype)init
{
    self = [super init];
    if (self) {
        _config = AConfiguration_new();
    }
    return self;
}

- (instancetype)initWithAConfiguration:(AConfiguration *)config
{
    self = [self init];
    if (self) {
        AConfiguration_copy(_config, config);
    }
    return self;
}

- (instancetype)initFromAssetManager:(AAssetManager *)manager
{
    self = [self init];
    if (self) {
        AConfiguration_fromAssetManager(_config, manager);
    }
    return self;
}

- (void)dealloc
{
    AConfiguration_delete(_config);
}

#pragma mark -
- (int32_t)mcc
{
    return AConfiguration_getMcc(_config);
}

- (void)setMcc:(int32_t)mcc
{
    AConfiguration_setMcc(_config, mcc);
}

- (int32_t)mnc
{
    return AConfiguration_getMnc(_config);
}

- (void)setMnc:(int32_t)mnc
{
    AConfiguration_setMnc(_config, mnc);
}

- (NSString *)language
{
    char *lang = NULL;
    AConfiguration_getLanguage(_config, lang);
    return [NSString stringWithUTF8String:lang];
}

- (void)setLanguage:(NSString *)language
{
    AConfiguration_setLanguage(_config, [language UTF8String]);
}

- (TNAConfigurationOrientation)orientation
{
    return AConfiguration_getOrientation(_config);
}

- (void)setOrientation:(TNAConfigurationOrientation)orientation
{
    AConfiguration_setOrientation(_config, orientation);
}

- (TNAConfigurationTouchScreen)touchscreen
{
    return AConfiguration_getTouchscreen(_config);
}

- (void)setTouchscreen:(TNAConfigurationTouchScreen)touchscreen
{
    AConfiguration_setTouchscreen(_config, touchscreen);
}

- (TNAConfigurationDensity)density
{
    return AConfiguration_getDensity(_config);
}

- (void)setDensity:(TNAConfigurationDensity)density
{
    AConfiguration_setDensity(_config, density);
}

- (TNAConfigurationKeyboard)keyboard
{
    return AConfiguration_getKeyboard(_config);
}

- (void)setKeyboard:(TNAConfigurationKeyboard)keyboard
{
    AConfiguration_setKeyboard(_config, keyboard);
}

- (TNAConfigurationNavigation)navigation
{
    return AConfiguration_getNavigation(_config);
}

- (void)setNavigation:(TNAConfigurationNavigation)navigation
{
    AConfiguration_setNavigation(_config, navigation);
}

- (TNAConfigurationKeysHidden)keysHidden
{
    return AConfiguration_getKeysHidden(_config);
}

- (void)setKeysHidden:(TNAConfigurationKeysHidden)keysHidden
{
    AConfiguration_setKeysHidden(_config, keysHidden);
}

- (TNAConfigurationNaviHidden)navHidden
{
    return AConfiguration_getNavHidden(_config);
}

- (void)setNavHidden:(TNAConfigurationNaviHidden)navHidden
{
    AConfiguration_setNavHidden(_config, navHidden);
}

- (int32_t)sdkVersion
{
    return AConfiguration_getSdkVersion(_config);
}

- (void)setSdkVersion:(int32_t)sdkVersion
{
    AConfiguration_setSdkVersion(_config, sdkVersion);
}

- (TNAConfigurationScreenSize)screenSize
{
    return AConfiguration_getScreenSize(_config);
}

- (void)setScreenSize:(TNAConfigurationScreenSize)screenSize
{
    return AConfiguration_setScreenSize(_config, screenSize);
}

- (TNAConfigurationScreenLong)screenLong
{
    return AConfiguration_getScreenLong(_config);
}

- (void)setScreenLong:(TNAConfigurationScreenLong)screenLong
{
    AConfiguration_setScreenLong(_config, screenLong);
}

- (TNAConfigurationUIModeType)UIModeType
{
    return AConfiguration_getUiModeType(_config);
}

- (void)setUIModeType:(TNAConfigurationUIModeType)UIModeType
{
    AConfiguration_setUiModeType(_config, UIModeType);
}

- (TNAConfigurationUIModeNight)UIModeNight
{
    return AConfiguration_getUiModeNight(_config);
}

- (void)setUIModeNight:(TNAConfigurationUIModeNight)UIModeNight
{
    AConfiguration_setUiModeNight(_config, UIModeNight);
}

- (TNAConfigurationDiff)diffWithConfiguration:(TNAConfiguration *)config
{
    return AConfiguration_diff(self.config, config.config);
}

- (BOOL)matchWithConfiguration:(TNAConfiguration *)config
{
    return AConfiguration_match(_config, config.config);
}

- (BOOL)isBetterThanConfiguration:(TNAConfiguration *)test requested:(TNAConfiguration *)requested
{
    return AConfiguration_isBetterThan(_config, test.config, requested.config);
}
@end
