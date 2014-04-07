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

#import "android_native_app_glue.h"
#import <android/native_activity.h>
#import <EGL/egl.h>

static NSMutableArray *_allScreens;
@implementation UIScreen {
    id _display;
    CGRect _bounds;
    CGRect _applicationFrame;
    CGFloat _scale;
    CGRect _pixelBounds;
    
}

static UIScreen *_mainScreen = nil;

+ (void)initialize
{
    if (self == [UIScreen class]) {
        _allScreens = [NSMutableArray array];
        _mainScreen = [[UIScreen alloc] init];

    }
}

static EGLDisplay _mainDisplay = EGL_NO_DISPLAY;
static EGLContext _mainContext = EGL_NO_CONTEXT;
static EGLSurface _mainSurface = EGL_NO_SURFACE;

+ (BOOL)androidSetupMainScreenWith:(struct android_app *)androidApp
{
    NSLog(@"%s",__PRETTY_FUNCTION__);
    // initialize OpenGL ES and EGL
    
    /*
     * Here specify the attributes of the desired configuration.
     * Below, we select an EGLConfig with at least 8 bits per color
     * component compatible with on-screen windows
     */
    const EGLint attribs[] = {
        EGL_CONFORMANT, EGL_OPENGL_ES2_BIT,
        EGL_RENDERABLE_TYPE, EGL_OPENGL_ES2_BIT,
        EGL_SURFACE_TYPE, EGL_WINDOW_BIT,
        EGL_BLUE_SIZE, 8,
        EGL_GREEN_SIZE, 8,
        EGL_RED_SIZE, 8,
        EGL_NONE
    };

    EGLint pixelWidth, pixelHeight, dummy, format;
    EGLint numConfigs;
    EGLConfig config;
    EGLSurface surface;
    EGLContext context;

    EGLDisplay display = eglGetDisplay(EGL_DEFAULT_DISPLAY);
    eglInitialize(display, 0, 0);
    
    /* Here, the application chooses the configuration it desires. In this
     * sample, we have a very simplified selection process, where we pick
     * the first EGLConfig that matches our criteria */
    eglChooseConfig(display, attribs, &config, 1, &numConfigs);

    /* EGL_NATIVE_VISUAL_ID is an attribute of the EGLConfig that is
     * guaranteed to be accepted by ANativeWindow_setBuffersGeometry().
     * As soon as we picked a EGLConfig, we can safely reconfigure the
     * ANativeWindow buffers to match, using EGL_NATIVE_VISUAL_ID. */
    eglGetConfigAttrib(display, config, EGL_NATIVE_VISUAL_ID, &format);

//    ANativeWindow_setBuffersGeometry(engine->app->window, 0, 0, format);

    surface = eglCreateWindowSurface(display, config, androidApp->window, NULL);
    context = eglCreateContext(display, config, NULL, NULL);
    
    if (eglMakeCurrent(display, surface, surface, context) == EGL_FALSE) {
        NSLog(@"Unable to eglMakeCurrent");
        return NO;
    }
    
    eglQuerySurface(display, surface, EGL_WIDTH, &pixelWidth);
    eglQuerySurface(display, surface, EGL_HEIGHT, &pixelHeight);
    
    _mainDisplay = display;
    _mainContext = context;
    _mainSurface = surface;
    
    _mainScreen->_pixelBounds = CGRectMake(0, 0, pixelWidth, pixelHeight);
    _mainScreen->_scale = 1;
    _mainScreen->_bounds = CGRectMake(0, 0, pixelWidth, pixelHeight);
    _mainScreen->_applicationFrame = _mainScreen->_bounds;
    
    return YES;
}

+ (void)androidTeardownMainScreen
{
    NSLog(@"%s",__PRETTY_FUNCTION__);
    
    if (_mainDisplay != EGL_NO_DISPLAY) {
        NSLog(@"[UIScreen] will clean context");
        eglMakeCurrent(_mainDisplay, EGL_NO_SURFACE, EGL_NO_SURFACE, EGL_NO_CONTEXT);
        if (_mainContext != EGL_NO_CONTEXT) {
            NSLog(@"[UIScreen] will destory context");
            eglDestroyContext(_mainDisplay, _mainContext);
        }
        
        if (_mainSurface != EGL_NO_SURFACE) {
            NSLog(@"[UIScreen] will destory surface");
            eglDestroySurface(_mainDisplay, _mainSurface);
        }
        
        NSLog(@"[UIScreen] will terminate display");
        eglTerminate(_mainDisplay);
    }
    
    _mainDisplay = EGL_NO_DISPLAY;
    _mainContext = EGL_NO_CONTEXT;
    _mainSurface = EGL_NO_SURFACE;
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
@end

NSString *const UIScreenDidConnectNotification = @"UIScreenDidConnectNotification";
NSString *const UIScreenDidDisconnectNotification = @"UIScreenDidDisconnectNotification";
NSString *const UIScreenModeDidChangeNotification = @"UIScreenModeDidChangeNotification";
