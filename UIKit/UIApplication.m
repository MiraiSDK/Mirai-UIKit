//
//  UIApplication.m
//  UIKit
//
//  Created by Chen Yonghui on 12/6/13.
//  Copyright (c) 2013 Shanghai Tinynetwork Inc. All rights reserved.
//

#import "UIApplication.h"
#import <dispatch/dispatch.h>
#import <CoreGraphics/CoreGraphics.h>
#import <UIKit/UIWindow.h>
#import <QuartzCore/QuartzCore.h>
#import "UIScreenPrivate.h"
#import "UIGraphics.h"
#import "UIEvent.h"
#import "UITouch.h"
#import "UIEvent+Android.h"
#import "UITouch+Private.h"

#include <string.h>
#include <jni.h>
#include <android/log.h>
#import <Foundation/NSObjCRuntime.h>
#include "android_native_app_glue.h"

#include <EGL/egl.h>
#include <GLES2/gl2.h>

#define ANDROID 1
#import <OpenGLES/EAGL.h>

#import "BKRenderingService.h"
#import "TNAConfiguration.h"

// HACK: private workaround method
@interface NSThread (Private)
+ (void)setCurrentThreadAsMainThread;
@end

@interface TNAndroidLauncher : NSObject
+ (void)launchWithArgc:(int)argc argv:(char *[])argv;
@end
@implementation TNAndroidLauncher
@end

@interface UIApplication ()

@end

@implementation UIApplication {
    BOOL _isRunning;
    
    UIEvent *_currentEvent;
    NSMutableSet *_visibleWindows;

    BOOL _landscaped;
}

static UIApplication *_app;
+ (UIApplication *)sharedApplication
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _app = [[self alloc] init];
        
        // install a timer to keep runloop alive
        [NSTimer scheduledTimerWithTimeInterval:3600 target:_app selector:@selector(dummy_runLoopKeepAlive) userInfo:nil repeats:YES];
    });
    return _app;
}

// dummy method to keep runloop alive
- (void)dummy_runLoopKeepAlive{}

- (id)init
{
    if (_app) {
        NSAssert(_app, @"You can't init application twice"); // should throw excption?
    }
    self = [super init];
    if (self) {
        _currentEvent = [[UIEvent alloc] initWithEventType:UIEventTypeTouches];
        [_currentEvent _setTouch:[[UITouch alloc] init]];
        _visibleWindows = [[NSMutableSet alloc] init];
    }
    return self;
}

- (void)finishLaunching
{
    if (self.delegate) {
        [self.delegate application:self didFinishLaunchingWithOptions:nil];
    }
}

#pragma mark - Android glue
static void handle_app_command(struct android_app* app, int32_t cmd);
static int32_t handle_input(struct android_app* app, AInputEvent* event);
bool app_has_focus = false;
static struct android_app* app_state;
static EAGLContext *_mainContext = nil;
static CARenderer *_mainRenderer = nil;

/**
 * Shared state for our app.
 */
struct engine {
    struct android_app* app;
    
    int animating;
    bool isScreenReady;
};

static void constructExecutablePath(char *result, struct android_app* state)
{
    char buffer[1024];
    char basePath[1024];
    
    // externalDataPath: /storage/emulated/0/Android/data/org.tiny4.BasicCairo/files
    const char * externalDataPath = app_state->activity->externalDataPath;
    
    // remove last component
    char *lastSlash = strrchr(externalDataPath, '/');
    strncpy(basePath, externalDataPath, lastSlash - externalDataPath);
    
    // get last component
    char activityName[1024];
    memset(activityName, 0, 1024);
    lastSlash = strrchr(basePath, '/');
    strcpy(activityName, lastSlash+1);
    
    // construct path
    memset(buffer, 0, 1024);
    sprintf(buffer, "%s/%s.app/UIKitApp",basePath,activityName);
    
    strcpy(result, buffer);
}

//workaround for call objc methods in gdb
//should move to Foundation or objc library
void* ___gdb_android_workaround_malloc(size_t size)
{
    return malloc(size);
}

// Entry point from android part
void android_main(struct android_app* state)
{
    @autoreleasepool {
        
        // Forward NSLog to android logging system
        _NSLog_printf_handler = *_NSLog_android_log_handler;
        
        app_state = state;
        
        char buffer[1024];
        constructExecutablePath(buffer, state);
        
        // Initialize process info
        int argc = 1;
        char * argv[] = {buffer};
        [NSProcessInfo initializeWithArguments:argv count:argc environment:NULL];
        
        // Cheat current current thread as main thread
        // The default main thread(thread 0), which is Android's Java side
        // Java side run our codes on secondly thread (thread 1)
        // we treat thread 1 as main thread, to keep our codes insulate with Java,
        // and gain ability to run our runloop.
        [NSThread setCurrentThreadAsMainThread];
        
        // Make sure glue isn't stripped.
        app_dummy();
        
        NSString *internalDataPath = [NSString stringWithCString:app_state->activity->internalDataPath];
        
        // FIXME: hard code cache path is ugly
        NSString *cachePath = [[internalDataPath stringByDeletingLastPathComponent] stringByAppendingPathComponent:@"cache"];
        
        
        NSString *fontconfigFilePath = [cachePath stringByAppendingPathComponent:@"fontconfig.conf"];
        // settign font config file
        setenv("FONTCONFIG_FILE",[fontconfigFilePath UTF8String],1);
        
        //setup engine
        struct engine engine;
        memset(&engine, 0, sizeof(engine));
        app_state->userData = &engine;
        app_state->onAppCmd = handle_app_command;
        app_state->onInputEvent = handle_input;
        engine.app = app_state;
        
        // Wait until screen is ready
        // which is wait to receive APP_CMD_INIT_WINDOW cmd
        while (!engine.isScreenReady) {
            int ident;
            int events;
            struct android_poll_source* source;
            int pollTimeout = 0;
            
            while ((ident=ALooper_pollAll(pollTimeout, NULL, &events, (void**)&source)) >= 0) {
                if (source != NULL) {
                    source->process(app_state, source);
                }
                
                if (engine.isScreenReady) {
                    break;
                }
            }
        }
        
        // unzip assets to bundle path
        NSString *bundlePath = [NSString stringWithUTF8String:buffer];
        bundlePath = [bundlePath stringByDeletingLastPathComponent];
        _prepareAsset(bundlePath);
        
        // call launcher, launcher will call the main()
        [TNAndroidLauncher launchWithArgc:argc argv:argv];
    }
    
}

#pragma mark Events

static void handle_app_command(struct android_app* app, int32_t cmd) {
    /* app->userData is available here */
    
    struct engine* engine = (struct engine*)app->userData;
    switch (cmd) {
        case APP_CMD_INIT_WINDOW:
            // The window is being shown, get it ready.
            if (engine->app->window != NULL) {
                engine_init_display(engine);
            }
            engine->isScreenReady = true;
            break;
        case APP_CMD_TERM_WINDOW:
            // The window is being hidden or closed, clean it up.
            engine_term_display(engine);
            break;
        case APP_CMD_LOST_FOCUS:
            app_has_focus=false;
            // Also stop animating.
            engine->animating = 0;
            break;
        case APP_CMD_GAINED_FOCUS:
            app_has_focus=true;
            break;
        case APP_CMD_INPUT_CHANGED:break;
        case APP_CMD_WINDOW_RESIZED:break;
        case APP_CMD_WINDOW_REDRAW_NEEDED:break;
        case APP_CMD_CONTENT_RECT_CHANGED:{
            ARect rect = app->contentRect;
            NSLog(@"contentRect:{%d,%d %d,%d}", rect.top,rect.left,rect.bottom,rect.right);
        } break;
        case APP_CMD_CONFIG_CHANGED: {
            TNAConfiguration *config = [[TNAConfiguration alloc] initWithAConfiguration:app->config];
            _app->_landscaped = (config.orientation == TNAConfigurationOrientationLand);
        } break;
        case APP_CMD_LOW_MEMORY:break;
        case APP_CMD_START:break;
        case APP_CMD_RESUME:break;
        case APP_CMD_SAVE_STATE:break;
        case APP_CMD_PAUSE:break;
        case APP_CMD_STOP:break;
        case APP_CMD_DESTROY:break;
    }
}

static int32_t handle_input(struct android_app* app, AInputEvent* aEvent) {
    /* app->userData is available here */
    [_app handleAEvent:aEvent];
    return 1;
}

#pragma mark Display setup
/**
 * Initialize an EGL context for the current display.
 */
static int engine_init_display(struct engine* engine) {
    BKRenderingServiceBegin(engine->app);
    CGRect bounds = BKRenderingServiceGetPixelBounds();
    
    [[UIScreen mainScreen] _setPixelBounds:bounds];
    [[UIScreen mainScreen] _setScale:1];
    
    return 0;
}

/**
 * Tear down the EGL context currently associated with the display.
 */
static void engine_term_display(struct engine* engine) {
    BKRenderingServiceEnd();
}

#pragma mark Logging
static void _NSLog_android_log_handler (NSString *message)
{
    __android_log_write(ANDROID_LOG_INFO,"NSLog",[message UTF8String]);
}

#pragma mark MainBundle
#define BUFSIZ 1024

static void _extractFolder(NSString *folder, NSString *path)
{
    // we should not call [NSBundle mainBundle] before extract files to mainBundle's path
    NSString *destPath = [path stringByAppendingPathComponent:folder];
    if (! [[NSFileManager defaultManager] fileExistsAtPath:destPath]) {
        NSLog(@"create folder:%@",destPath);
        NSError *creationError = nil;
        BOOL createSuccess = [[NSFileManager defaultManager] createDirectoryAtPath:destPath withIntermediateDirectories:YES attributes:nil error:&creationError];
        if (!createSuccess) {
            NSLog(@"%@",creationError);
        }
    }
    
    AAssetManager *mgr = app_state->activity->assetManager;
//    NSLog(@"open dir:%@",folder);
    AAssetDir *assetDir = AAssetManager_openDir(mgr, [folder UTF8String]);
    const char * filename = NULL;
    while ((filename = AAssetDir_getNextFileName(assetDir)) != NULL) {
//        NSLog(@"process filename:%s",filename);
        NSString *NS_filename = [NSString stringWithUTF8String:filename];
        const char *destion = [[destPath stringByAppendingPathComponent:NS_filename] UTF8String];
        FILE *isExist = fopen(destion, "r");
        if (isExist) {
            //FIXME: what if the file is updated?
//            NSLog(@"skip exist file:%s",destion);
            fclose(isExist);
            continue;
        }
        
        NSString *relativePath = [folder stringByAppendingPathComponent:NS_filename];
//        NSLog(@"relativePath:%@",relativePath);
//        NSLog(@"extract bundle file: %s",destion);
        AAsset *asset = AAssetManager_open(mgr, [relativePath UTF8String], AASSET_MODE_STREAMING);
//        NSLog(@"asset:<%p>",asset);
        char buf[BUFSIZ];
        int nb_read = 0;
        FILE *out = fopen(destion, "w");
        while ((nb_read = AAsset_read(asset, buf, BUFSIZ)) > 0) {
            fwrite(buf, nb_read, 1, out);
        }
        fclose(out);
        AAsset_close(asset);
    }
    AAssetDir_close(assetDir);
    
}

static void _prepareAsset(NSString *path)
{
    //
    // FIXME: should only check files after the apk file changed
    //
    
    // we should not call [NSBundle mainBundle] before extract files to mainBundle's path
    // FIXME: workaround, should enumerate subfolders.
    _extractFolder(@"",path);
    _extractFolder(@"Resources",path);
    _extractFolder(@"Resources/UIKit.bundle",path);
    
    //    NSLog(@"main resourcePath: %@",[[NSBundle mainBundle] resourcePath]);
    //    NSLog(@"main bundlePath: %@",[[NSBundle mainBundle] bundlePath]);
    //    NSLog(@"main executablePath: %@",[[NSBundle mainBundle] executablePath]);
    
}

#pragma mark - mainRunLoop
- (void)_run
{
    static BOOL didlaunch = NO;
    @autoreleasepool {
        _isRunning = YES;
        
        if (!didlaunch) {
            didlaunch = YES;
            @autoreleasepool {
                NSLog(@"will finish");
                [self finishLaunching];
                NSLog(@"did finish");

            }
        }
        
        NSLog(@"start loop");
        struct engine* engine = (struct engine*)app_state->userData;

        BKRenderingServiceRun();
        CGRect screenBounds = [[UIScreen mainScreen] bounds];
        CGRect landscapedBounds = CGRectMake(0, 0, screenBounds.size.height, screenBounds.size.width);

        @try {
        do {
            @autoreleasepool {
                // Read all pending events. If app_has_focus is true, then we are going
                // to read any events that are ready then render the screen. If we don't
                // have focus, we are going to block and spin around the poll loop until
                // we get focus again, preventing us from doing a bunch of rendering
                // when the app isn't even visible.
                int ident;
                int events;
                struct android_poll_source* source;
//                int pollTimeout = engine->animating ? 0 : -1;
                int pollTimeout = 0;
                
                BOOL runLoopFired = NO;
                while ((ident=ALooper_pollAll(pollTimeout, NULL, &events, (void**)&source)) >= 0) {
                    
                    if (!runLoopFired) {
                        NSDate *untilDate = nil;
                        
                        if (source != NULL) {
                            untilDate = [NSDate date];
                        } else {
                            untilDate = [NSDate distantFuture];
                        }
        
                        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:untilDate];
                        runLoopFired = YES;
                    }
                    
                    // Process this event.
                    if (source != NULL) {
                        source->process(app_state, source);
                    }

                    // Check if we are exiting.
                    if (app_state->destroyRequested != 0) {
                        NSLog(@"Engine thread destroy requested!");
                        engine_term_display(engine);
                        return;
                    }
                }
                
                if (!runLoopFired) {
                    NSDate *untilDate = [NSDate date];
                    [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:untilDate];

                    runLoopFired = YES;
                }
                
//                EGLDisplay display = eglGetCurrentDisplay();
//                if (display != EGL_NO_DISPLAY) {
                    @autoreleasepool {
                        // commit?
                        UIWindow *keyWindow = _app.keyWindow;
                        
                        CALayer *layer = _app.keyWindow.layer;
                        CGRect bounds = screenBounds;
                        if (_landscaped) {
                            bounds = landscapedBounds;
                        }
                        
                        if (!CGRectEqualToRect(keyWindow.frame, bounds)) {
                            keyWindow.frame = bounds;
                            keyWindow.rootViewController.view.frame = bounds;
                            NSLog(@"set window layer frame:%@",NSStringFromCGRect(bounds));
                        }
                            
                        [layer _recursionLayoutAndDisplayIfNeeds];
                        
                        //
                        // The CARenderer work flow
                        //
                        // begin frame
                        // 1. commit transaction
                        // 2. update model layer
                        //      set render:current frame time
                        //      update presentationLayer
                        //      apply animation to presentation layer
                        //      set render:next frame time
                        //      schedule rasterization layer
                        
                        // render
                        // 1. layout if needs
                        // 2. render presentation layer
                        
                        // end frame
                        // 1. reset updatedBounds
                        
                        //
                        // The BKRenderingService work flow
                        //
                        
                        //Client Side
                        //  commitIfNeeds
                        [CATransaction commit];
                        
                        //      copy renderTree
                        CALayer *renderTree = [layer copyRenderLayer:nil];
                        //      send to server
                        BKRenderingServiceUploadRenderLayer(renderTree);
                        
                        //
                        // Server Side
                        //  copy renderTree
                        //  begin frame
                        //      set current frame time
                        //      update renderTree
                        //      apply animation to render layer
                        //      set nextFrameTime
                        //
                        //  render
                        //  end frame
                        
                    }
                }
            
                
//            }
        } while (_isRunning);
            
        }
        @catch (NSException *exception) {
            NSLog(@"exception:%@",exception);
            abort();
        }

    }

    NSLog(@"end running");

}


- (void)handleAEvent:(AInputEvent *)aEvent
{
    [[NSRunLoop currentRunLoop] runMode:UITrackingRunLoopMode beforeDate:[NSDate date]];

    int32_t aType = AInputEvent_getType(aEvent);
    if (aType == AINPUT_EVENT_TYPE_MOTION) {
        UITouch *touch = [[_currentEvent allTouches] anyObject];
        
        int64_t eventTime = AMotionEvent_getEventTime(aEvent);
        const NSTimeInterval eventTimestamp = eventTime/1000000000.0f; // convert nanoSeconds to Seconds
        [_currentEvent _setTimestamp:eventTimestamp];
        
        size_t pointerCount = AMotionEvent_getPointerCount(aEvent);
        for (size_t pointer_index = 0; pointer_index < pointerCount ; pointer_index++) {
            int32_t pointerIdentifier = AMotionEvent_getPointerId(aEvent, pointer_index);
        }

        int32_t action = AMotionEvent_getAction(aEvent);
        int32_t trueAction = action & AMOTION_EVENT_ACTION_MASK;
        int32_t pointerIndex = (action & AMOTION_EVENT_ACTION_POINTER_INDEX_MASK) >> AMOTION_EVENT_ACTION_POINTER_INDEX_SHIFT;
        float x = AMotionEvent_getX(aEvent, pointerIndex);
        float y = AMotionEvent_getY(aEvent, pointerIndex);

        CGFloat scale = [[UIScreen mainScreen] scale];
        
        const CGPoint screenLocation = CGPointMake(x/scale, y/scale);
        UITouchPhase phase = UITouchPhaseCancelled;
        switch (trueAction) {
            case AMOTION_EVENT_ACTION_DOWN:
                phase = UITouchPhaseBegan;
                break;
            case AMOTION_EVENT_ACTION_UP:
                phase = UITouchPhaseEnded;
                break;
            case AMOTION_EVENT_ACTION_MOVE:
                phase = UITouchPhaseMoved;
                break;
            case AMOTION_EVENT_ACTION_CANCEL:
                phase = UITouchPhaseCancelled;
                break;
            case AMOTION_EVENT_ACTION_OUTSIDE:
                phase = UITouchPhaseCancelled;
                break;
            case AMOTION_EVENT_ACTION_POINTER_DOWN:
                //FIXME: what?
                phase = UITouchPhaseStationary;
                break;
            case AMOTION_EVENT_ACTION_POINTER_UP:
                phase = UITouchPhaseStationary;
                break;
            default:
                phase = UITouchPhaseCancelled;
                break;
        }
        [touch _updatePhase:phase screenLocation:screenLocation timestamp:eventTimestamp];

        //update touche.view
        UIView *previousView = touch.view;
        UIScreen *theScreen = [UIScreen mainScreen];
        [touch _setTouchedView:[theScreen _hitTest:screenLocation event:_currentEvent]];
        
        [self sendEvent:_currentEvent];
    }
}

#pragma mark -
- (void)_setKeyWindow:(UIWindow *)newKeyWindow
{
    _keyWindow = newKeyWindow;
}

- (void)_windowDidBecomeVisible:(UIWindow *)theWindow
{
    [_visibleWindows addObject:[NSValue valueWithNonretainedObject:theWindow]];
}

- (void)_windowDidBecomeHidden:(UIWindow *)theWindow
{
    if (theWindow == _keyWindow) [self _setKeyWindow:nil];
    [_visibleWindows removeObject:[NSValue valueWithNonretainedObject:theWindow]];
}

- (NSArray *)windows
{
    NSSortDescriptor *sort = [[NSSortDescriptor alloc] initWithKey:@"windowLevel" ascending:YES];
    
    //FIXME: valueForKey crashed in Android
//    return [[_visibleWindows valueForKey:@"nonretainedObjectValue"] sortedArrayUsingDescriptors:[NSArray arrayWithObject:sort]];
    NSMutableArray *windows = [NSMutableArray array];
    for (NSValue *wValue in _visibleWindows) {
        UIWindow *window = [wValue nonretainedObjectValue];
        [windows addObject:window];
    }
    return [windows sortedArrayUsingDescriptors:[NSArray arrayWithObject:sort]];
}


#pragma mark - 
- (void)beginIgnoringInteractionEvents
{
    NS_UNIMPLEMENTED_LOG;
}
- (void)endIgnoringInteractionEvents
{
    NS_UNIMPLEMENTED_LOG;
}
- (BOOL)isIgnoringInteractionEvents
{
    NS_UNIMPLEMENTED_LOG;
    return NO;
}

- (BOOL)openURL:(NSURL*)url
{
    NS_UNIMPLEMENTED_LOG;
    return NO;
}

- (BOOL)canOpenURL:(NSURL *)url
{
    NS_UNIMPLEMENTED_LOG;
    return NO;
}

- (void)sendEvent:(UIEvent *)event
{
    for (UITouch *touch in [event allTouches]) {
        [touch.window sendEvent:event];
    }
}

- (BOOL)sendAction:(SEL)action to:(id)target from:(id)sender forEvent:(UIEvent *)event
{
    if (!target) {
        // The docs say this method will start with the first responder if target==nil. Initially I thought this meant that there was always a given
        // or set first responder (attached to the window, probably). However it doesn't appear that is the case. Instead it seems UIKit is perfectly
        // happy to function without ever having any UIResponder having had a becomeFirstResponder sent to it. This method seems to work by starting
        // with sender and traveling down the responder chain from there if target==nil. The first object that responds to the given action is sent
        // the message. (or no one is)
        
        // My confusion comes from the fact that motion events and keyboard events are supposed to start with the first responder - but what is that
        // if none was ever set? Apparently the answer is, if none were set, the message doesn't get delivered. If you expicitly set a UIResponder
        // using becomeFirstResponder, then it will receive keyboard/motion events but it does not receive any other messages from other views that
        // happen to end up calling this method with a nil target. So that's a seperate mechanism and I think it's confused a bit in the docs.
        
        // It seems that the reality of message delivery to "first responder" is that it depends a bit on the source. If the source is an external
        // event like motion or keyboard, then there has to have been an explicitly set first responder (by way of becomeFirstResponder) in order for
        // those events to even get delivered at all. If there is no responder defined, the action is simply never sent and thus never received.
        // This is entirely independent of what "first responder" means in the context of a UIControl. Instead, for a UIControl, the first responder
        // is the first UIResponder (including the UIControl itself) that responds to the action. It starts with the UIControl (sender) and not with
        // whatever UIResponder may have been set with becomeFirstResponder.
        
        id responder = sender;
        while (responder) {
            if ([responder respondsToSelector:action]) {
                target = responder;
                break;
            } else if ([responder respondsToSelector:@selector(nextResponder)]) {
                responder = [responder nextResponder];
            } else {
                responder = nil;
            }
        }
    }
    
    if (target) {
        [target performSelector:action withObject:sender withObject:event];
        return YES;
    } else {
        return NO;
    }
}

- (UIBackgroundTaskIdentifier)beginBackgroundTaskWithExpirationHandler:(void(^)(void))handler
{
    NS_UNIMPLEMENTED_LOG;
    return 0;
}

- (UIBackgroundTaskIdentifier)beginBackgroundTaskWithName:(NSString *)taskName expirationHandler:(void(^)(void))handler
{
    NS_UNIMPLEMENTED_LOG;
    return 0;
}

- (void)endBackgroundTask:(UIBackgroundTaskIdentifier)identifier
{
    NS_UNIMPLEMENTED_LOG;
}

- (void)setMinimumBackgroundFetchInterval:(NSTimeInterval)minimumBackgroundFetchInterval
{
    NS_UNIMPLEMENTED_LOG;
}

- (BOOL)setKeepAliveTimeout:(NSTimeInterval)timeout handler:(void(^)(void))keepAliveHandler
{
    NS_UNIMPLEMENTED_LOG;
    return NO;
}

- (void)clearKeepAliveTimeout
{
    NS_UNIMPLEMENTED_LOG;
}

// this sets the touches view property to nil (while retaining the window property setting)
// this is used when a view is removed from its superview while it may have been the origin
// of an active touch. after a view is removed, we don't want to deliver any more touch events
// to it, but we still may need to route the touch itself for the sake of gesture recognizers
// so we need to retain the touch's original window setting so that events can still be routed.
//
// note that the touch itself is not being cancelled here so its phase remains unchanged.
// I'm not entirely certain if that's the correct thing to do, but I think it makes sense. The
// touch itself has not gone anywhere - just the view that it first touched. That breaks the
// delivery of the touch events themselves as far as the usual responder chain delivery is
// concerned, but that appears to be what happens in the real UIKit when you remove a view out
// from under an active touch.
//
// this whole thing is necessary because otherwise a gesture which may have been initiated over
// some specific view would end up getting cancelled/failing if the view under it happens to be
// removed. this is more common than you might expect. a UITableView that is not reusing rows
// does exactly this as it scrolls - which coincidentally is how I found this bug in the first
// place. :P
- (void)_removeViewFromTouches:(UIView *)aView
{
    for (UITouch *touch in [_currentEvent allTouches]) {
        if (touch.view == aView) {
            [touch _removeFromView];
        }
    }
}

@end



@implementation UIApplication (UIRemoteNotifications)

- (void)registerForRemoteNotificationTypes:(UIRemoteNotificationType)types
{
    NS_UNIMPLEMENTED_LOG;
}

- (void)unregisterForRemoteNotifications
{
    NS_UNIMPLEMENTED_LOG;
}

- (UIRemoteNotificationType)enabledRemoteNotificationTypes
{
    NS_UNIMPLEMENTED_LOG;
    return UIRemoteNotificationTypeNone;
}

@end

@implementation UIApplication (UILocalNotifications)

- (void)presentLocalNotificationNow:(UILocalNotification *)notification
{
    NS_UNIMPLEMENTED_LOG;
}

- (void)scheduleLocalNotification:(UILocalNotification *)notification
{
    NS_UNIMPLEMENTED_LOG;
}

- (void)cancelLocalNotification:(UILocalNotification *)notification
{
    NS_UNIMPLEMENTED_LOG;
}

- (void)cancelAllLocalNotifications
{
    NS_UNIMPLEMENTED_LOG;
}

- (void)setScheduledLocalNotifications:(NSArray *)scheduledLocalNotifications
{
    NS_UNIMPLEMENTED_LOG;
}

- (NSArray *)scheduledLocalNotifications
{
    NS_UNIMPLEMENTED_LOG;
    return nil;
}

@end

@implementation UIApplication (UIRemoteControlEvents)

- (void)beginReceivingRemoteControlEvents
{
    NS_UNIMPLEMENTED_LOG;
}

- (void)endReceivingRemoteControlEvents
{
    NS_UNIMPLEMENTED_LOG;
}

@end

@implementation UIApplication (UIStateRestoration)

- (void)extendStateRestoration
{
    NS_UNIMPLEMENTED_LOG;
}

- (void)completeStateRestoration
{
    NS_UNIMPLEMENTED_LOG;
}

- (void)ignoreSnapshotOnNextApplicationLaunch
{
    NS_UNIMPLEMENTED_LOG;
}

+ (void) registerObjectForStateRestoration:(id<UIStateRestoring>)object restorationIdentifier:(NSString *)restorationIdentifier
{
    NS_UNIMPLEMENTED_LOG;
}

@end

@implementation UIApplication (UIApplicationDeprecated)

- (BOOL)isProximitySensingEnabled
{
    NS_UNIMPLEMENTED_LOG;
    return NO;
}

- (void)setProximitySensingEnabled:(BOOL)proximitySensingEnabled
{
    NS_UNIMPLEMENTED_LOG;
}

- (void)setStatusBarHidden:(BOOL)hidden animated:(BOOL)animated
{
    NS_UNIMPLEMENTED_LOG;
}

@end

int UIApplicationMain(int argc, char *argv[], NSString *principalClassName, NSString *delegateClassName)
{
    NSLog(@"enter UIApplicationMain");
    id<UIApplicationDelegate>delegate = nil;
    @autoreleasepool {
//        if (![UIScreen mainScreen]) {
//            UIScreen *screen = [[UIScreen alloc] initWithAndroidNativeWindow:app_state->window];
//        }
        
        Class class = principalClassName ? NSClassFromString(principalClassName) : nil;
        if (!class) {}// TODO: load principalClassName from plist
        
        if (!class) {
            class = [UIApplication class];
        }
        
        UIApplication *app = [class sharedApplication];
        Class delegateClass = delegateClassName ? NSClassFromString(delegateClassName) : nil;
        
        if (delegateClass) {
            delegate = [[delegateClass alloc] init];
            app.delegate = delegate;
        }
    }
    
    [_app _run];
    

    return 0;
}

NSString *const UIApplicationInvalidInterfaceOrientationException = @"UIApplicationInvalidInterfaceOrientationException";

const UIBackgroundTaskIdentifier UIBackgroundTaskInvalid = 0;
const NSTimeInterval UIMinimumKeepAliveTimeout = 600.0; //seconds
const NSTimeInterval UIApplicationBackgroundFetchIntervalMinimum = 0.0;
const NSTimeInterval UIApplicationBackgroundFetchIntervalNever = INFINITY;


NSString *const UITrackingRunLoopMode = @"UITrackingRunLoopMode";
NSString *const UIApplicationDidEnterBackgroundNotification = @"UIApplicationDidEnterBackgroundNotification";
NSString *const UIApplicationWillEnterForegroundNotification = @"UIApplicationWillEnterForegroundNotification";
NSString *const UIApplicationDidFinishLaunchingNotification = @"UIApplicationDidFinishLaunchingNotification";
NSString *const UIApplicationDidBecomeActiveNotification = @"UIApplicationDidBecomeActiveNotification";
NSString *const UIApplicationWillResignActiveNotification = @"UIApplicationWillResignActiveNotification";
NSString *const UIApplicationDidReceiveMemoryWarningNotification = @"UIApplicationDidReceiveMemoryWarningNotification";
NSString *const UIApplicationWillTerminateNotification = @"UIApplicationWillTerminateNotification";
NSString *const UIApplicationSignificantTimeChangeNotification = @"UIApplicationSignificantTimeChangeNotification";
NSString *const UIApplicationWillChangeStatusBarOrientationNotification = @"UIApplicationWillChangeStatusBarOrientationNotification";
NSString *const UIApplicationDidChangeStatusBarOrientationNotification = @"UIApplicationDidChangeStatusBarOrientationNotification";
NSString *const UIApplicationStatusBarOrientationUserInfo = @"UIApplicationStatusBarOrientationUserInfoKey";
NSString *const UIApplicationWillChangeStatusBarFrameNotification = @"UIApplicationWillChangeStatusBarFrameNotification";
NSString *const UIApplicationDidChangeStatusBarFrameNotification = @"UIApplicationDidChangeStatusBarFrameNotification";
NSString *const UIApplicationStatusBarFrameUserInfo = @"UIApplicationStatusBarFrameUserInfoKey";
NSString *const UIApplicationBackgroundRefreshStatusDidChangeNotification = @"UIApplicationBackgroundRefreshStatusDidChangeNotification";
NSString *const UIApplicationLaunchOptionsURLKey = @"UIApplicationLaunchOptionsURLKey";
NSString *const UIApplicationLaunchOptionsSourceApplication = @"UIApplicationLaunchOptionsSourceApplicationKey";
NSString *const UIApplicationLaunchOptionsRemoteNotificationKey = @"UIApplicationLaunchOptionsRemoteNotificationKey";
NSString *const UIApplicationLaunchOptionsLocalNotificationKey = @"UIApplicationLaunchOptionsLocalNotificationKey";
NSString *const UIApplicationLaunchOptionsAnnotationKey = @"UIApplicationLaunchOptionsAnnotationKey";
NSString *const UIApplicationProtectedDataWillBecomeUnavailable = @"UIApplicationProtectedDataWillBecomeUnavailable";
NSString *const UIApplicationProtectedDataDidBecomeAvailable = @"UIApplicationProtectedDataDidBecomeAvailable";
NSString *const UIApplicationLaunchOptionsLocationKey = @"UIApplicationLaunchOptionsLocationKey";
NSString *const UIApplicationLaunchOptionsNewsstandDownloadsKey = @"UIApplicationLaunchOptionsNewsstandDownloadsKey";
NSString *const UIApplicationLaunchOptionsBluetoothCentralsKey = @"UIApplicationLaunchOptionsBluetoothCentralsKey";
NSString *const UIApplicationLaunchOptionsBluetoothPeripheralsKey = @"UIApplicationLaunchOptionsBluetoothPeripheralsKey";
NSString *const UIContentSizeCategoryExtraSmall = @"UIContentSizeCategoryExtraSmall";
NSString *const UIContentSizeCategorySmall = @"UIContentSizeCategorySmall";
NSString *const UIContentSizeCategoryMedium = @"UIContentSizeCategoryMedium";
NSString *const UIContentSizeCategoryLarge = @"UIContentSizeCategoryLarge";
NSString *const UIContentSizeCategoryExtraLarge = @"UIContentSizeCategoryExtraLarge";
NSString *const UIContentSizeCategoryExtraExtraLarge = @"UIContentSizeCategoryExtraExtraLarge";
NSString *const UIContentSizeCategoryExtraExtraExtraLarge = @"UIContentSizeCategoryExtraExtraExtraLarge";
NSString *const UIContentSizeCategoryAccessibilityMedium = @"UIContentSizeCategoryAccessibilityMedium";
NSString *const UIContentSizeCategoryAccessibilityLarge = @"UIContentSizeCategoryAccessibilityLarge";
NSString *const UIContentSizeCategoryAccessibilityExtraLarge = @"UIContentSizeCategoryAccessibilityExtraLarge";
NSString *const UIContentSizeCategoryAccessibilityExtraExtraLarge = @"UIContentSizeCategoryAccessibilityExtraExtraLarge";
NSString *const UIContentSizeCategoryAccessibilityExtraExtraExtraLarge = @"UIContentSizeCategoryAccessibilityExtraExtraExtraLarge";
NSString *const UIContentSizeCategoryDidChangeNotification = @"UIContentSizeCategoryDidChangeNotification";
NSString *const UIContentSizeCategoryNewValueKey = @"UIContentSizeCategoryNewValueKey";
NSString *const UIApplicationUserDidTakeScreenshotNotification = @"UIApplicationUserDidTakeScreenshotNotification";


