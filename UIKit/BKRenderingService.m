//
//  BKRenderingService.m
//  UIKit
//
//  Created by Chen Yonghui on 6/17/14.
//  Copyright (c) 2014 Shanghai Tinynetwork Inc. All rights reserved.
//

#import "BKRenderingService.h"
#import "UIScreenPrivate.h"

#import <OpenGLES/EAGL.h>
#include <EGL/egl.h>
#include <GLES2/gl2.h>
#import <android/native_activity.h>
#import "android_native_app_glue.h"
#import "UIKit+Android.h"

#import <QuartzCore/QuartzCore.h>
#import <UIKit/UIKit.h>

@interface BKRenderingService ()
@property (nonatomic, strong) NSOperationQueue *renderQueue;
@property (nonatomic, assign) struct android_app *app;

@property (nonatomic, assign) CGRect pixelBounds;
@property (nonatomic, assign) CGFloat scale;
@property (nonatomic, assign) CGRect bounds;

@property (nonatomic, assign) EGLDisplay display;
@property (nonatomic, assign) EGLContext context;
@property (nonatomic, assign) EGLSurface surface;

@property (strong) CALayer *layer;
@property (nonatomic, strong) CARenderer *renderer;

@property (nonatomic, assign, getter = isCanceled) BOOL canceled;
@end
@implementation BKRenderingService
static BKRenderingService *currentService = nil;

- (instancetype)initWithAndroidApp:(struct android_app *)androidApp
{
    self = [super init];
    if (self) {
        _app = androidApp;
        _renderQueue = [[NSOperationQueue alloc] init];
        [self start];
    }
    return self;
}

- (void)start
{
    __weak typeof(self) weakSelf = self;
    [self.renderQueue addOperationWithBlock:^{
        [weakSelf setup];
    }];
    [self.renderQueue waitUntilAllOperationsAreFinished];
    
}

- (void)run
{
    __weak typeof(self) weakSelf = self;
    [self.renderQueue addOperationWithBlock:^{
        [weakSelf rendering];
        [weakSelf tearDown];
    }];
}
#pragma mark - call from queue
- (void)setup
{
    // setup egl, opengl
    [self setupEGL:_app];
    
    EAGLContext * context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
    [EAGLContext setCurrentContext:context];
    
//    _layer = [CALayer layer];
//    _layer.frame = _bounds;
    
    _renderer = [CARenderer rendererWithEAGLContext:context options:nil];
    _renderer.bounds = _bounds;
    
}

- (BOOL)setupEGL:(struct android_app *)androidApp
{
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
    
    _display = display;
    _context = context;
    _surface = surface;
    
    _pixelBounds = CGRectMake(0, 0, pixelWidth, pixelHeight);
    _scale = 1;
    _bounds = CGRectMake(0, 0, pixelWidth, pixelHeight);
    CGRect applicationFrame = _bounds;
    
    return YES;
}

- (void)tearDown
{
    [self tearDownEGL];
    
    _layer = nil;
    _renderer = nil;
    
}

- (void)tearDownEGL
{
    if (_display != EGL_NO_DISPLAY) {
        eglMakeCurrent(_display, EGL_NO_SURFACE, EGL_NO_SURFACE, EGL_NO_CONTEXT);
        
        if (_context != EGL_NO_CONTEXT) {
            eglDestroyContext(_display, _context);
        }
        
        if (_surface != EGL_NO_SURFACE) {
            eglDestroySurface(_display, _surface);
        }
        
        eglTerminate(_display);
    }
    
    _display = EGL_NO_DISPLAY;
    _context = EGL_NO_CONTEXT;
    _surface = EGL_NO_SURFACE;
}

- (void)rendering
{
    // rendering
    while (!self.isCanceled) {
        if (!self.layer) {continue;}
        
        _renderer.layer = self.layer;
        [_renderer addUpdateRect:_renderer.layer.bounds];
        [_renderer beginFrameAtTime:CACurrentMediaTime() timeStamp:NULL];
        [_renderer render];
        [_renderer endFrame];
        eglSwapBuffers(_display, _surface);
    }

}


+ (void)setupWithAndroidApp:(struct android_app *)androidApp
{
    if (currentService) {
        currentService.canceled = YES;
        currentService = nil;
    }
    
    currentService = [[self alloc] initWithAndroidApp:androidApp];
}

+ (void)endCurrentService
{
    currentService.canceled = YES;
    currentService = nil;
}

- (void)uploadRenderLayer:(CALayer *)layer
{
    if (!layer) {
        NSLog(@"[Warning] upload render layer is nil");
    }
    self.layer = layer;
}
@end

void BKRenderingServiceBegin(struct android_app *androidApp)
{
    [BKRenderingService setupWithAndroidApp:androidApp];
}

void BKRenderingServiceRun()
{
    [currentService run];
}

void BKRenderingServiceEnd()
{
    [BKRenderingService endCurrentService];
}

CGRect BKRenderingServiceGetPixelBounds()
{
    return currentService.pixelBounds;
}

void BKRenderingServiceUploadRenderLayer(CALayer *layer)
{
    [currentService uploadRenderLayer:layer];
}
