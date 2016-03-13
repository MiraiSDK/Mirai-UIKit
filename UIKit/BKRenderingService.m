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
#include <unistd.h>


//#import <OpenGLES/EAGL+Private.h>
@interface EAGLContext()
- (id)initWithAPI:(EAGLRenderingAPI)api eglContext:(void *)ctx eglSurface:(void *)surface sharegroup:(EAGLSharegroup *)sharegroup;
@end

#include <EGL/egl.h>
#include <GLES2/gl2.h>
#import <android/native_activity.h>
#import "android_native_app_glue.h"
#import "UIKit+Android.h"

#import <QuartzCore/QuartzCore.h>
#import <QuartzCore/CADisplayLink.h>
#import <QuartzCore/CARenderer.h>
#import <UIKit/UIKit.h>

@interface CADisplayLink(Private)
+ (void)_endFrame;
@end

// HACK: private workaround method
@interface CAGLTexture : NSObject
+ (void)invalidate;
@end

@interface BKRenderingService () <RunLoopEvents>
@property (nonatomic, strong) NSOperationQueue *renderQueue;
@property (nonatomic, assign) struct android_app *app;

@property (nonatomic, assign) CGRect pixelBounds;
@property (nonatomic, assign) CGFloat scale;
@property (nonatomic, assign) CGRect bounds;

@property (nonatomic, assign) EGLDisplay display;
@property (nonatomic, assign) EGLContext context;
@property (nonatomic, assign) EGLSurface surface;

@property (strong) CALayer *layer;
@property (strong) CALayer *nextLayer;

@property (nonatomic, strong) CARenderer *renderer;

@property (nonatomic, assign, getter = isCanceled) BOOL canceled;
@property (nonatomic, strong) EAGLContext *eaglContext;
@property (nonatomic, strong) NSRecursiveLock *frameLock;
@property (nonatomic, strong) NSPort *port;

@property (nonatomic, assign) int msgread;
@property (nonatomic, assign) int msgwrite;
@property (nonatomic, assign) CFTimeInterval nextFrameTime;
@end
@implementation BKRenderingService
static BKRenderingService *currentService = nil;

- (instancetype)initWithAndroidApp:(struct android_app *)androidApp
{
    self = [super init];
    if (self) {
        _app = androidApp;
        _renderQueue = [[NSOperationQueue alloc] init];
        _port = [NSMessagePort port];
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
        _frameLock = [[NSRecursiveLock alloc] init];
        [self installPipe];
        [weakSelf rendering];
        [weakSelf tearDown];
        [self removePipe];
        _frameLock = nil;
    }];
}

#pragma mark - call from queue
- (void)setup
{
    // setup egl, opengl
    [self setupEGL:_app];
    
    EAGLContext * context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2 eglContext:_context eglSurface:_surface sharegroup:nil];
    _eaglContext = context;
    
//    _layer = [CALayer layer];
//    _layer.frame = _bounds;
    
    _renderer = [CARenderer rendererWithEAGLContext:context options:nil];
    [CARenderer setCurrentRenderer:_renderer];
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
        EGL_STENCIL_SIZE, 8,
        EGL_NONE
    };
    
    EGLint pixelWidth, pixelHeight, dummy, format;
    EGLint numConfigs;
    EGLConfig config;
    EGLSurface surface;
    EGLContext context;
    
    EGLDisplay display = eglGetDisplay(EGL_DEFAULT_DISPLAY);
    eglInitialize(display, 0, 0);
    eglSwapInterval(display, 1);
    
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
    
    const EGLint ctxAttribs[] = {
        EGL_CONTEXT_CLIENT_VERSION, 2,
        EGL_NONE
    };

    context = eglCreateContext(display, config, EGL_NO_CONTEXT, ctxAttribs);
    
    
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
    NSLog(@"%s",__PRETTY_FUNCTION__);
    [self tearDownEGL];
    
    _layer = nil;
    _renderer = nil;
    [EAGLContext setCurrentContext:nil];
    
    [CAGLTexture invalidate];
    NSLog(@"invalidate all textures.");

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
    NSRunLoop *runloop = [NSRunLoop currentRunLoop];
    NSDate *distantFuture = [NSDate distantFuture];
    _nextFrameTime = INFINITY;
    
    while (!self.isCanceled) {
        @autoreleasepool {
            NSDate *limitDate = distantFuture;
            if (!isinf(_nextFrameTime)) {
                limitDate = [NSDate dateWithTimeIntervalSince1970:_nextFrameTime];
            }
            
            [runloop runMode:NSDefaultRunLoopMode beforeDate:limitDate];
            
            EGLint pixelWidth, pixelHeight;
            eglQuerySurface(_display, _surface, EGL_WIDTH, &pixelWidth);
            eglQuerySurface(_display, _surface, EGL_HEIGHT, &pixelHeight);
            @autoreleasepool {
                _renderer.layer = self.layer;
                _renderer.bounds = CGRectMake(0, 0, pixelWidth, pixelHeight);
                [_renderer addUpdateRect:_renderer.layer.bounds];
                [_renderer beginFrameAtTime:CACurrentMediaTime() timeStamp:NULL];
                [_renderer render];
                [_renderer endFrame];
                
                _nextFrameTime = [_renderer nextFrameTime];
                
                eglSwapBuffers(_display, _surface);
            }
            
            // call animation stopped callbacks after end a frame
            @autoreleasepool {
                static dispatch_once_t onceToken;
                dispatch_once(&onceToken, ^{
                    if (![CALayer instancesRespondToSelector:@selector(callAnimationsFinishedCallback)]) {
                        NSLog(@"[ERROR] QuartzCore version too old. please upgrade QuartzCore");
                        abort();
                    }
                });
                
                CALayer *modelLayer = [_renderer.layer modelLayer];
                if ([modelLayer _hasFinishedAnimation]) {
                    NSLog(@"animation finished..");
                    [modelLayer performSelectorOnMainThread:@selector(callAnimationsFinishedCallbackInMainThread)
                                                 withObject:nil waitUntilDone:YES];
                    
                }
            }
            
            
            // notify main thread on frame end?
            [CADisplayLink _endFrame];
            NSLog(@"nextFrameTime: %.8f",_nextFrameTime);
        }
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

#pragma mark - layer updated

NS_ENUM(uint8_t, RenderingEvent) {
    RenderingEventLayerUpdate,
    RenderingEventLayerRefresh,
};

// Calling from Main thread
- (void)uploadRenderLayer:(CALayer *)layer
{
    if (!layer) {
        NSLog(@"[Warning] upload render layer is nil");
    }
    [self.frameLock lock];
    //should wait until frame end
    self.nextLayer = layer;
    [self.frameLock unlock];
    
    uint8_t msg = RenderingEventLayerUpdate;
    write(_msgwrite, &msg, sizeof(msg));
}

// Calling from Rendering thread
-(void)receivedEvent:(void *)data type:(RunLoopEventType)type extra:(void *)extra forMode:(NSString *)mode
{
    int8_t cmd;
    read(_msgread, &cmd, sizeof(cmd));
    
    @try {
        [self.frameLock lock];
        if (self.nextLayer) {
            self.layer = self.nextLayer;
            self.nextLayer = nil;
        }
    }
    @finally {
        [self.frameLock unlock];
    }
    
    if (cmd == RenderingEventLayerRefresh) {
        [CAGLTexture invalidate];
        NSLog(@"invalidate all textures.");
    }
}

- (void)installPipe
{
    if (_msgread) {
        return;
    }
    
    int msgpipe[2];
    if (pipe(msgpipe)) {
        NSLog(@"could not create pipe: %s", strerror(errno));
        [NSException raise:@"Pipe Error" format:@"could not create pipe: %s", strerror(errno)];
        return;
    }
    _msgread = msgpipe[0];
    _msgwrite = msgpipe[1];
    
    NSRunLoop *rl = [NSRunLoop currentRunLoop];
    [rl addEvent:(void *)(uintptr_t)_msgread
            type:ET_RDESC
         watcher:self
         forMode:NSDefaultRunLoopMode];
}

- (void)removePipe
{
    close(_msgread);
    close(_msgwrite);
    _msgread = 0;
    _msgwrite = 0;
}

- (void)notifyRefreshScreen:(BOOL)value
{
    if (value) {
        uint8_t msg = RenderingEventLayerRefresh;
        write(_msgwrite, &msg, sizeof(msg));
    }
}
@end

void BKRenderingServiceBegin(struct android_app *androidApp)
{
    NSLog(@"%s",__PRETTY_FUNCTION__);
    [BKRenderingService setupWithAndroidApp:androidApp];
}

void BKRenderingSetShouldRefreshScreen(BOOL value)
{
    [currentService notifyRefreshScreen:value];
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

BOOL BKRenderingServiceNeedNewRenderLayer()
{
    return currentService.nextLayer == nil;
}

void BKRenderingServiceUploadRenderLayer(CALayer *layer)
{
    [currentService uploadRenderLayer:layer];
}

NSRecursiveLock *BKLayerDisplayLock() {
    return [CARenderer layerDisplayLock];
}
