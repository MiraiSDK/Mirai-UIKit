//
//  TNScreenHelper.m
//  UIKit
//
//  Created by TaoZeyu on 15/10/14.
//  Copyright © 2015年 Shanghai Tinynetwork Inc. All rights reserved.
//

#import "TNScreenHelper.h"
#import "UIScreenPrivate.h"
#import "UIView.h"
#import "UIWindow.h"
#import "jni.h"

static jfloat _screenDensity;

@implementation TNScreenHelper
{
    __unsafe_unretained UIScreen *_screen;
}

- (instancetype)initWithScreen:(UIScreen *)screen
{
    if (self = [super init]) {
        _screen = screen;
    }
    return self;
}

- (float)density
{
    return _screenDensity/_screen.scale;
}

- (float)inchFromPoint:(float)point
{
    return point/self.density;
}

- (float)pointFromInch:(float)inch
{
    return inch*self.density;
}

@end

TNScreenHelper *TNScreenHelperOfView(UIView *view) {
    return view.window.screen.screenHelper;
}

void Java_org_tiny4_CocoaActivity_CocoaActivity_nativeSupportedDensity(JNIEnv *env, jobject obj, jfloat density) {
    _screenDensity = density;
}