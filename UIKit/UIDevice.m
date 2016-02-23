//
//  UIDevice.m
//  UIKit
//
//  Created by Chen Yonghui on 1/20/14.
//  Copyright (c) 2014 Shanghai Tinynetwork Inc. All rights reserved.
//

#import "UIDevice.h"

@implementation UIDevice

static UIDevice *theDevice;

+ (void)initialize
{
    if (self == [UIDevice class]) {
        theDevice = [[UIDevice alloc] init];
    }
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _systemVersion = @"9.0";
    }
    return self;
}

+ (UIDevice *)currentDevice
{
    return theDevice;
}

- (BOOL)isMultitaskingSupported
{
    return YES;
}

- (void)beginGeneratingDeviceOrientationNotifications
{
    NS_UNIMPLEMENTED_LOG;
}

- (void)endGeneratingDeviceOrientationNotifications
{
    NS_UNIMPLEMENTED_LOG;
}

- (void)playInputClick
{
    NS_UNIMPLEMENTED_LOG;
}
@end

NSString *const UIDeviceOrientationDidChangeNotification = @"UIDeviceOrientationDidChangeNotification";
NSString *const UIDeviceBatteryStateDidChangeNotification = @"UIDeviceBatteryStateDidChangeNotification";
NSString *const UIDeviceBatteryLevelDidChangeNotification = @"UIDeviceBatteryLevelDidChangeNotification";
NSString *const UIDeviceProximityStateDidChangeNotification = @"UIDeviceProximityStateDidChangeNotification";

