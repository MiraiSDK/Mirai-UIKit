//
//  UIScreen.m
//  UIKit
//
//  Created by Chen Yonghui on 12/7/13.
//  Copyright (c) 2013 Shanghai Tinynetwork Inc. All rights reserved.
//

#import "UIScreen.h"
#import "UIScreenPrivate.h"
#import "UIApplication.h"
#import "UIWindow.h"
#import "UIGeometry.h"
#import "UIColor.h"

#import "android_native_app_glue.h"
#import <android/native_activity.h>
#import <EGL/egl.h>
#import <QuartzCore/QuartzCore.h>

static NSMutableArray *_allScreens;
@implementation UIScreen {
    id _display;
    CGRect _bounds;
    CGRect _applicationFrame;
    CGFloat _scale;
    CGRect _pixelBounds;
    CALayer *__pixelLayer;
    CALayer *__windowLayer;
    BOOL _landscaped;
}

static UIScreen *_mainScreen = nil;

+ (void)initialize
{
    if (self == [UIScreen class]) {
        _allScreens = [NSMutableArray array];
        _mainScreen = [[UIScreen alloc] init];

    }
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        __pixelLayer = [CALayer layer];
//        __pixelLayer.backgroundColor =[UIColor redColor].CGColor;
        
        __windowLayer = [CALayer layer];
//        __windowLayer.backgroundColor = [UIColor greenColor].CGColor;
        [__pixelLayer addSublayer:__windowLayer];
    }
    return self;
}

- (void)_setScale:(CGFloat)scale
{
    _scale = scale;

    _bounds = CGRectMake(0, 0,
                         _pixelBounds.size.width/scale,
                         _pixelBounds.size.height/scale);
    _applicationFrame = _bounds;
}


+ (NSArray *)screens
{
    return _allScreens;
}

+ (UIScreen *)mainScreen
{
    return _mainScreen;
}

- (CGRect)bounds
{
    return _bounds;
}

- (CGRect)applicationFrame
{
    return _applicationFrame;
}

- (CGFloat)scale
{
    return _scale;
}

- (CADisplayLink *)displayLinkWithTarget:(id)target selector:(SEL)sel
{
    NS_UNIMPLEMENTED_LOG;
    return nil;
}


- (UIView *)_hitTest:(CGPoint)clickPoint event:(UIEvent *)theEvent
{
    for (UIWindow *window in [[UIApplication sharedApplication].windows reverseObjectEnumerator]) {
        if (window.screen == self) {
            CGPoint windowPoint = [window convertPoint:clickPoint fromWindow:nil];
            UIView *clickedView = [window hitTest:windowPoint withEvent:theEvent];
            if (clickedView) {
                return clickedView;
            }
        }
    }
    
    return nil;
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"<%@: %p; bounds = %@; mode = %@>", [self className], self, NSStringFromCGRect(self.bounds), self.currentMode];
}

#pragma mark - Pixel glue
- (CALayer *)_pixelLayer
{
    return __pixelLayer;
}

- (void)_setPixelBounds:(CGRect)bounds
{
    if (!CGRectEqualToRect(_pixelBounds, bounds)) {
        _pixelBounds = bounds;
        __pixelLayer.frame = bounds;
    }
}

- (void)_setLandscaped:(BOOL)landscaped
{
    if (_landscaped != landscaped) {
        CGFloat longSide = MAX(_pixelBounds.size.width,_pixelBounds.size.height);
        CGFloat shortSide = MIN(_pixelBounds.size.width,_pixelBounds.size.height);
        CGRect pixelBounds = landscaped? CGRectMake(0, 0, longSide, shortSide): CGRectMake(0, 0, shortSide, longSide);
        [self _setPixelBounds:pixelBounds];
        
        __windowLayer.position = CGPointMake(pixelBounds.size.width/2, pixelBounds.size.height/2);
        if (landscaped) {
            CATransform3D scale = CATransform3DMakeScale(_scale, _scale, 1);
            CATransform3D t = CATransform3DRotate(scale, M_PI_2, 0, 0, 1);
            __windowLayer.transform = t;
        } else {
            __windowLayer.transform = CATransform3DMakeScale(_scale, _scale, 1);
        }
        _landscaped = landscaped;
    }
}


#pragma mark - scale support

- (void)_setScreenBounds:(CGRect)bounds scale:(CGFloat)scale fitMode:(UIScreenFitMode)mode
{
    if (mode == UIScreenFitModeScaleAspectFit) {
        CGFloat widthScale = _pixelBounds.size.width / bounds.size.width;
        CGFloat heightScale = _pixelBounds.size.height / bounds.size.height;
        scale = MIN(widthScale, heightScale);

    }
    
    NSLog(@"pixel bounds:%@",NSStringFromCGRect(_pixelBounds));
    NSLog(@"set screen bounds:%@ scale:%.2f",NSStringFromCGRect(bounds),scale);
    _scale = scale;
    _bounds = bounds;
    __windowLayer.bounds = bounds;
    __windowLayer.position = CGPointMake(_pixelBounds.size.width/2, _pixelBounds.size.height/2);
    __windowLayer.transform = CATransform3DMakeScale(scale, scale, 1);
}

- (CALayer *)_windowLayer
{
    return __windowLayer;
}

@end

@implementation UIScreen (SizeMode)

- (void)setScreenMode:(UIScreenSizeMode)sizeMode scale:(CGFloat)scale
{
    CGRect rect = _pixelBounds;
    switch (sizeMode) {
        case UIScreenSizeModeDefault:
            rect = _pixelBounds;
            break;
        case UIScreenSizeModePhone:
            rect = CGRectMake(0, 0, 320, 480);
            break;
        case UIScreenSizeModePhone46:
            rect = CGRectMake(0, 0, 320, 568);
            break;

        case UIScreenSizeModePad:
            rect = CGRectMake(0, 0, 768, 1024);
            break;
            
        default:
            break;
    }
    
    UIScreenFitMode fitMode = UIScreenFitModeCenter;
    if (scale == 0) {
        fitMode = UIScreenFitModeScaleAspectFit;
    }
    
    [self _setScreenBounds:rect scale:scale fitMode:fitMode];
}

@end

NSString *const UIScreenDidConnectNotification = @"UIScreenDidConnectNotification";
NSString *const UIScreenDidDisconnectNotification = @"UIScreenDidDisconnectNotification";
NSString *const UIScreenModeDidChangeNotification = @"UIScreenModeDidChangeNotification";
