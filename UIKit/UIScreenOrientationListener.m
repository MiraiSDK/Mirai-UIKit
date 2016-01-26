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

static UIInterfaceOrientationMask _willBeOrientationMask = UIInterfaceOrientationMaskPortrait;
static UIInterfaceOrientationMask _currentOrientationMask = UIInterfaceOrientationMaskPortrait;
static UIInterfaceOrientationMask _supportedInterfaceOrientations = UIInterfaceOrientationMaskAll;

+ (BOOL)isLandscaped
{
    return _currentOrientationMask == UIInterfaceOrientationMaskLandscapeLeft ||
           _currentOrientationMask == UIInterfaceOrientationMaskLandscapeRight;
}

+ (void)setSupportedInterfaceOrientations:(NSUInteger)supportedInterfaceOrientations
{
    _supportedInterfaceOrientations = supportedInterfaceOrientations;
    UIInterfaceOrientationMask orientation = [self _orientationWithWantedOrientation:_currentOrientationMask withSupportedInterfaceOrientations:supportedInterfaceOrientations];
    [self _changeOrientationTo:orientation];
}

+ (void)mainScreenHasInitMode
{
    [self setCurrentOrientationMask:_willBeOrientationMask];
}

+ (void)setCurrentOrientationMask:(NSUInteger)wantedOrientation
{
    _willBeOrientationMask = wantedOrientation;
    
    if ([UIScreen mainScreen].hasInitMode &&
        (wantedOrientation & _supportedInterfaceOrientations)) {
        [self _changeOrientationTo:wantedOrientation];
    }
    
}

+ (UIInterfaceOrientationMask)_orientationWithWantedOrientation:(UIInterfaceOrientationMask)wantedOrientation withSupportedInterfaceOrientations:(NSUInteger)supportedInterfaceOrientations
{
    if (wantedOrientation & supportedInterfaceOrientations) {
        return wantedOrientation;
    }
    UIInterfaceOrientationMask orientation = nextOrientationMaskOf(wantedOrientation);
    
    while (orientation != wantedOrientation && !(orientation & supportedInterfaceOrientations)) {
        orientation = nextOrientationMaskOf(wantedOrientation);
    }
    return orientation;
}

+ (void)_changeOrientationTo:(UIInterfaceOrientationMask)orientation
{
    if (_currentOrientationMask != orientation) {
        _currentOrientationMask = orientation;
        [[UIScreen mainScreen] _setOrientation:orientation];
    }
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

void Java_org_tiny4_CocoaActivity_ScreenOrientationHandler_nativeChangeOrientationTo(
                                                        JNIEnv *env, jobject obj, jint orrientationInfo)
{
    [UIScreenOrientationListener setCurrentOrientationMask:toOrientationMask(orrientationInfo)];
}