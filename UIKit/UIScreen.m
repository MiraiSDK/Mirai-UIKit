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
#import "UIWindow+UIPrivate.h"
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
        // about __pixelLayer and __windowLayer:
        // on iOS, a window always is portrait.
        // on android, surface size changed on orientation change
        //  __pixelLayer always pixel-equal screen pixel size
        //  __windowLayer is been used to simulate iOS screen
        __pixelLayer = [CALayer layer];
        __pixelLayer.masksToBounds = YES;
//        __pixelLayer.backgroundColor =[UIColor redColor].CGColor;
        
        __windowLayer = [CALayer layer];
        __windowLayer.delegate = self;
//        __windowLayer.backgroundColor = [UIColor greenColor].CGColor;
        [__pixelLayer addSublayer:__windowLayer];
    }
    return self;
}
- (id<CAAction>) actionForLayer: (CALayer*)layer forKey: (NSString*)eventKey
{
    return [NSNull null];
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
//    NSLog(@"screen point:%@",NSStringFromCGPoint(clickPoint));
//  FIXME: originally use [[UIApplication sharedApplication].windows reverseObjectEnumerator] here, but it seems that the windows order is incorrect
    NSEnumerator *wls = [[__windowLayer sublayers] reverseObjectEnumerator];
    for (CALayer *l in wls) {
        UIWindow *window = l.delegate;
                if (window.screen == self) {
            CGPoint windowPoint = [__pixelLayer convertPoint:clickPoint toLayer:window.layer];
//            NSLog(@"window point:%@",NSStringFromCGPoint(windowPoint));
            UIView *clickedView = [window hitTest:windowPoint withEvent:theEvent];
            if (clickedView) {
//                NSLog(@"clicked view:%@",clickedView);
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

- (BOOL)_isLandscaped
{
    return _landscaped;
}

- (void)_setLandscaped:(BOOL)landscaped
{
    if (_landscaped != landscaped) {
        CGFloat longSide = MAX(_pixelBounds.size.width,_pixelBounds.size.height);
        CGFloat shortSide = MIN(_pixelBounds.size.width,_pixelBounds.size.height);
        CGRect pixelBounds = landscaped? CGRectMake(0, 0, longSide, shortSide): CGRectMake(0, 0, shortSide, longSide);
        [self _setPixelBounds:pixelBounds];
        [__windowLayer setFrame:pixelBounds];
        
        __windowLayer.frame = pixelBounds;
        __windowLayer.position = CGPointMake(pixelBounds.size.width/2, pixelBounds.size.height/2);
        
        NSArray *windows =  [UIApplication sharedApplication].windows;
        for (UIWindow *window in windows) {
            [window _setLandscaped:landscaped];
        }
        _landscaped = landscaped;
    }
}


#pragma mark - scale support

- (void)_setScreenBounds:(CGRect)bounds scale:(CGFloat)scale fitMode:(UIScreenFitMode)mode
{
    if (mode == UIScreenFitModeScaleAspectFit) {
        CGFloat shortSide = MIN(_pixelBounds.size.width, _pixelBounds.size.height);
        CGFloat longSide = MAX(_pixelBounds.size.width, _pixelBounds.size.height);

        CGFloat widthScale = shortSide / bounds.size.width;
        CGFloat heightScale = longSide / bounds.size.height;
        scale = MIN(widthScale, heightScale);

    }
    
    NSLog(@"pixel bounds:%@",NSStringFromCGRect(_pixelBounds));
    NSLog(@"set screen bounds:%@ scale:%.2f",NSStringFromCGRect(bounds),scale);
    _scale = scale;
    CGRect portraitBounds = bounds;
    if (bounds.size.width > bounds.size.height) {
        portraitBounds.size.width = bounds.size.height;
        portraitBounds.size.height = bounds.size.width;
    }
    _bounds = portraitBounds;
    _applicationFrame = portraitBounds;
    __windowLayer.bounds = portraitBounds;
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
