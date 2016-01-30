//
//  UIScreenOrientationListener.m
//  UIKit
//
//  Created by TaoZeyu on 15/8/5.
//  Copyright (c) 2015年 Shanghai Tinynetwork Inc. All rights reserved.
//

#import "UIScreenOrientationListener.h"
#import "UIApplication+UIPrivate.h"
#import "UIWIndow.h"
#import "UIScreenPrivate.h"
#include <jni.h>
#import <TNJavaHelper/TNJavaHelper.h>

@interface UIScreenOrientationListener ()
@property (nonatomic) BOOL allowed;
@end

static UIInterfaceOrientationMask nextOrientationMaskOf(UIInterfaceOrientationMask mask);
static UIInterfaceOrientationMask toOrientationMask(jint orientationInfo);
static jint toOrientationInfo(UIInterfaceOrientationMask orientationMask);

@implementation UIScreenOrientationListener

static UIInterfaceOrientationMask _currentOrientationMask = UIInterfaceOrientationMaskPortrait;
static UIInterfaceOrientationMask _wantedCurrentOrientationMask = UIInterfaceOrientationMaskPortrait;
static NSUInteger _supportedInterfaceOrientations = UIInterfaceOrientationMaskAll;

+ (BOOL)isLandscaped
{
    return _currentOrientationMask == UIInterfaceOrientationMaskLandscapeLeft ||
           _currentOrientationMask == UIInterfaceOrientationMaskLandscapeRight;
}

- (void)applicationAllowOrientationChangeTo:(NSNumber *)orientationNumber
{
    UIInterfaceOrientationMask orientation = [orientationNumber unsignedIntegerValue];
    
    // when _app of UIApplication is nil, it will lead to a deadlock.
    // I don't know why. Maybe the application is not ready.
    
    if ([UIApplication _isSharedInstanceReady]) {
        UIApplication *application = [UIApplication sharedApplication];
        UIInterfaceOrientationMask mask = [application supportedInterfaceOrientations];
        
        _allowed = (orientation & mask);
    }
}

- (void)applicationChangeOrientationTo:(NSNumber *)orientationNumber
{
    UIInterfaceOrientationMask orientation = [orientationNumber unsignedIntegerValue];
    _currentOrientationMask = orientation;
    
    BOOL isLandsacpe = [UIScreenOrientationListener isLandscaped];
    
    [[UIScreen mainScreen] _setLandscaped:isLandsacpe];
}

+ (void)updateSupportedInterfaceOrientations:(NSUInteger)supportedInterfaceOrientations
{
    if (_supportedInterfaceOrientations != supportedInterfaceOrientations) {
        _supportedInterfaceOrientations = supportedInterfaceOrientations;
        _wantedCurrentOrientationMask = _currentOrientationMask;
        [self _syncCurrentOrientation];
    }
}

+ (void)updateAndroidCurrentOrientations:(UIInterfaceOrientationMask)orientation
{
    if (_wantedCurrentOrientationMask != orientation) {
        _wantedCurrentOrientationMask = orientation;
        [self _syncCurrentOrientation];
    }
}

+ (void)_syncCurrentOrientation
{
    static const NSUInteger stateCount = 4;
    UIInterfaceOrientationMask toMask = _wantedCurrentOrientationMask;
    for (NSUInteger i=0; i<stateCount; ++i) {
        if (toMask & _supportedInterfaceOrientations) {
            [self _changeOrientationMaskTo:toMask];
            return;
        }
        toMask = nextOrientationMaskOf(toMask);
    }
}

+ (void)_changeOrientationMaskTo:(UIInterfaceOrientationMask)orientationMask
{
    JNIEnv *env = [[TNJavaHelper sharedHelper] env];
    
    jclass handlerClass = [[TNJavaHelper sharedHelper] findCustomClass:@"org.tiny4.CocoaActivity.ScreenOrientationHandler"];
    jmethodID setOrientationMethodID = (*env)->GetStaticMethodID(
                                                                 env, handlerClass, "setScreenOrientationInfo", "(I)V");
    
    jint orientationInfo = toOrientationInfo(orientationMask);
    (*env)->CallStaticVoidMethod(env, handlerClass, setOrientationMethodID, orientationInfo);
}

@end

static UIInterfaceOrientationMask nextOrientationMaskOf(UIInterfaceOrientationMask mask) {
    
    switch (mask) {
        case UIInterfaceOrientationMaskPortrait:
            return UIInterfaceOrientationMaskLandscapeRight;
            
        case UIInterfaceOrientationMaskLandscapeRight:
            return UIInterfaceOrientationMaskPortraitUpsideDown;
            
        case UIInterfaceOrientationMaskPortraitUpsideDown:
            return UIInterfaceOrientationMaskLandscapeLeft;
            
        case UIInterfaceOrientationMaskLandscapeLeft:
            return UIInterfaceOrientationMaskPortrait;
            
        default:
            return NSUIntegerMax;
    }
}

static UIInterfaceOrientationMask toOrientationMask(jint orientationInfo) {
    
    switch (orientationInfo) {
        case SCREEN_ORIENTATION_PORTRAIT:
            return UIInterfaceOrientationMaskPortrait;
        
        case SCREEN_ORIENTATION_REVERSE_PORTRAIT:
            return UIInterfaceOrientationMaskPortraitUpsideDown;
        
        case SCREEN_ORIENTATION_LANDSCAPE:
            return UIInterfaceOrientationMaskLandscapeRight;
        
        case SCREEN_ORIENTATION_REVERSE_LANDSCAPE:
            return UIInterfaceOrientationMaskLandscapeLeft;
        
        default:
            return NSUIntegerMax;
    }
}

static jint toOrientationInfo(UIInterfaceOrientationMask orientationMask) {
    
    switch (orientationMask) {
        case UIInterfaceOrientationMaskPortrait:
            return SCREEN_ORIENTATION_PORTRAIT;
            
        case UIInterfaceOrientationMaskPortraitUpsideDown:
            return SCREEN_ORIENTATION_REVERSE_PORTRAIT;
            
        case UIInterfaceOrientationMaskLandscapeRight:
            return SCREEN_ORIENTATION_LANDSCAPE;
            
        case UIInterfaceOrientationMaskLandscapeLeft:
            return SCREEN_ORIENTATION_REVERSE_LANDSCAPE;
            
        default:
            return -1;
    }
}

void Java_org_tiny4_CocoaActivity_ScreenOrientationHandler_nativeInitOrientation(
                                                        JNIEnv *env, jobject obj, jint orrientationInfo)
{
    _currentOrientationMask = toOrientationMask(orrientationInfo);
}

void Java_org_tiny4_CocoaActivity_ScreenOrientationHandler_nativeNotifyCurrentGravityOrientation(
                                                        JNIEnv *env, jobject obj, jint orrientationInfo)
{
    UIInterfaceOrientationMask orientation = toOrientationMask(orrientationInfo);
    if (orientation & _supportedInterfaceOrientations) {
        [UIScreenOrientationListener updateAndroidCurrentOrientations:orientation];
    }
}

void Java_org_tiny4_CocoaActivity_ScreenOrientationHandler_nativeResumeScreenWithNewGravityOrientation(
                                                        JNIEnv *env, jobject obj, jint orrientationInfo)
{
    UIInterfaceOrientationMask orientation = toOrientationMask(orrientationInfo);
    [UIScreenOrientationListener updateAndroidCurrentOrientations:orientation];
}

void Java_org_tiny4_CocoaActivity_ScreenOrientationHandler_nativeChangeOrientationTo(
                                                        JNIEnv *env, jobject obj, jint orrientationInfo)
{
    UIInterfaceOrientationMask orientation = toOrientationMask(orrientationInfo);
    
    UIScreenOrientationListener *listener = [[UIScreenOrientationListener alloc] init];
    [listener performSelectorOnMainThread:@selector(applicationChangeOrientationTo:)
                               withObject:@(orientation) waitUntilDone:NO];
}