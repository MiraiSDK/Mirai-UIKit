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
#import "UITouch+Android.h"

#include <string.h>
#include <jni.h>
#include <android/log.h>
#import <Foundation/NSObjCRuntime.h>
#include "android_native_app_glue.h"

#include <EGL/egl.h>
#include <GLES2/gl2.h>

#define ANDROID 1
#import <OpenGLES/EAGL.h>


@interface TNAndroidLauncher : NSObject
+ (void)launchWithArgc:(int)argc argv:(char *[])argv;
@end
@implementation TNAndroidLauncher
@end

@interface UIApplication ()

@end

@implementation UIApplication {
    BOOL _isRunning;
    EAGLContext *_context;
    CARenderer *_renderer;
    
    UIEvent *_currentEvent;
    NSMutableSet *_visibleWindows;

}

static UIApplication *_app;
+ (UIApplication *)sharedApplication
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _app = [[self alloc] init];
    });
    return _app;
}

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
    NSLog(@"in finishLaunching...");
    NSLog(@"delegate: %s",[self.delegate description].UTF8String);
    if (self.delegate) {
        NSLog(@"will coll didfinish");
        [self.delegate application:self didFinishLaunchingWithOptions:nil];
    }
}

static void draw_frame(ANativeWindow_Buffer *buffer);
static void handle_app_command(struct android_app* app, int32_t cmd);
static int32_t handle_input(struct android_app* app, AInputEvent* event);
bool app_has_focus = false;
static struct android_app* app_state;

/**
 * Shared state for our app.
 */
struct engine {
    struct android_app* app;
    
    int animating;
};

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
        
        // Make sure glue isn't stripped.
        app_dummy();
        struct engine engine;
        memset(&engine, 0, sizeof(engine));
        app_state->userData = &engine;
        app_state->onAppCmd = handle_app_command;
        app_state->onInputEvent = handle_input;
        engine.app = app_state;
        
        NSLog(@"start loop");
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
//                int pollTimeout = engine.animating ? 0 : -1;
                int pollTimeout = 0;
                
                while ((ident=ALooper_pollAll(pollTimeout, NULL, &events, (void**)&source)) >= 0) {
                    NSLog(@"handle event");
                    // Process this event.
                    if (source != NULL) {
                        source->process(app_state, source);
                    }

                    // Check if we are exiting.
                    if (app_state->destroyRequested != 0) {
                        NSLog(@"Engine thread destroy requested!");
                        engine_term_display(&engine);
                        return;
                    }
                }
                
                EGLDisplay display = eglGetCurrentDisplay();
                if (display != EGL_NO_DISPLAY) {
                    @autoreleasepool {
                        _renderer.layer = _app.keyWindow.layer;
                        [_renderer beginFrameAtTime:CACurrentMediaTime() timeStamp:NULL];
                        [_renderer render];
                        [_renderer endFrame];
                        eglSwapBuffers(eglGetCurrentDisplay(), eglGetCurrentSurface(EGL_DRAW));
                    }
                }
                
                
            }
        } while (_isRunning);
    }

    NSLog(@"end running");

}


/**
 * Initialize an EGL context for the current display.
 */
static int engine_init_display(struct engine* engine) {
    // initialize OpenGL ES and EGL
    
    [UIScreen androidSetupMainScreenWith:engine->app];
    
    // Initialize GL state.
    
    EAGLContext *ctx = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
    _app->_renderer = [CARenderer rendererWithEAGLContext:ctx options:nil];
    _app->_context = ctx;
    
    return 0;
}

/**
 * Tear down the EGL context currently associated with the display.
 */
static void engine_term_display(struct engine* engine) {
    _app->_renderer = nil;
    _app->_context = nil;

    [UIScreen androidTeardownMainScreen];
}

- (void)handleAEvent:(AInputEvent *)aEvent
{
    int32_t aType = AInputEvent_getType(aEvent);
    if (aType == AINPUT_EVENT_TYPE_MOTION) {
        UITouch *touch = [[_currentEvent allTouches] anyObject];
        
        int64_t eventTime = AMotionEvent_getEventTime(aEvent);
        const NSTimeInterval timestamp = eventTime/1000000000.0f; // convert nanoSeconds to Seconds
        
        int32_t action = AMotionEvent_getAction(aEvent);
        int32_t trueAction = action & AMOTION_EVENT_ACTION_MASK;
        int32_t pointerIndex = (action & AMOTION_EVENT_ACTION_POINTER_INDEX_MASK) >> AMOTION_EVENT_ACTION_POINTER_INDEX_SHIFT;
        float x = AMotionEvent_getX(aEvent, pointerIndex);
        float y = AMotionEvent_getY(aEvent, pointerIndex);

        const CGPoint screenLocation = CGPointMake(x, y);
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
        [touch _updatePhase:phase screenLocation:screenLocation timestamp:timestamp];

        //update touche.view
        UIView *previousView = touch.view;
        UIScreen *theScreen = [UIScreen mainScreen];
        [touch _setTouchedView:[theScreen _hitTest:screenLocation event:_currentEvent]];
        
        [self sendEvent:_currentEvent];

        
    }
    
}

static int32_t handle_input(struct android_app* app, AInputEvent* aEvent) {
    /* app->userData is available here */
    
    [_app handleAEvent:aEvent];
    return 1;
//    
//    UIEvent *ui_Event = [[UIEvent alloc] initWithAInputEvent:aEvent];
//    
//    if (ui_Event) {
//        [_app sendEvent:ui_Event];
//        return 1;
//    }
//    
//    return 0;
}

static void handle_app_command(struct android_app* app, int32_t cmd) {
    /* app->userData is available here */
    struct engine* engine = (struct engine*)app->userData;
    
    switch (cmd) {
        case APP_CMD_INIT_WINDOW:
            // The window is being shown, get it ready.
            if (engine->app->window != NULL) {
                engine_init_display(engine);
//                engine_draw_frame(engine);
            }
            break;
        case APP_CMD_TERM_WINDOW:
            // The window is being hidden or closed, clean it up.
            engine_term_display(engine);
            break;
        case APP_CMD_LOST_FOCUS:
            app_has_focus=false;
            // Also stop animating.
            engine->animating = 0;
//            engine_draw_frame(engine);
            break;
        case APP_CMD_GAINED_FOCUS:
            app_has_focus=true;
            break;
    }
}

static void _NSLog_android_log_handler (NSString *message)
{
    __android_log_write(ANDROID_LOG_INFO,"NSLog",[message UTF8String]);
}

//int main(int argc, char * argv[]);
void android_main(struct android_app* state)
{
    _NSLog_printf_handler = *_NSLog_android_log_handler;
    
    app_state = state;
    int argc = 1;
    char * argv[] = {"/data/local/fileName"};
    [NSProcessInfo initializeWithArguments:argv count:argc environment:NULL];
    NSLog(@"on android_main");

    [TNAndroidLauncher launchWithArgc:argc argv:argv];
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
    NSLog(@"%s",__PRETTY_FUNCTION__);
    for (UITouch *touch in [event allTouches]) {
        [touch.window sendEvent:event];
    }
}

- (BOOL)sendAction:(SEL)action to:(id)target from:(id)sender forEvent:(UIEvent *)event
{
    NS_UNIMPLEMENTED_LOG;
    return NO;
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


NSString *const UITrackingRunLoopModeKey = @"UITrackingRunLoopMode";
NSString *const UIApplicationDidEnterBackgroundNotificationKey = @"UIApplicationDidEnterBackgroundNotification";
NSString *const UIApplicationWillEnterForegroundNotificationKey = @"UIApplicationWillEnterForegroundNotification";
NSString *const UIApplicationDidFinishLaunchingNotificationKey = @"UIApplicationDidFinishLaunchingNotification";
NSString *const UIApplicationDidBecomeActiveNotificationKey = @"UIApplicationDidBecomeActiveNotification";
NSString *const UIApplicationWillResignActiveNotificationKey = @"UIApplicationWillResignActiveNotification";
NSString *const UIApplicationDidReceiveMemoryWarningNotificationKey = @"UIApplicationDidReceiveMemoryWarningNotification";
NSString *const UIApplicationWillTerminateNotificationKey = @"UIApplicationWillTerminateNotification";
NSString *const UIApplicationSignificantTimeChangeNotificationKey = @"UIApplicationSignificantTimeChangeNotification";
NSString *const UIApplicationWillChangeStatusBarOrientationNotificationKey = @"UIApplicationWillChangeStatusBarOrientationNotification";
NSString *const UIApplicationDidChangeStatusBarOrientationNotificationKey = @"UIApplicationDidChangeStatusBarOrientationNotification";
NSString *const UIApplicationStatusBarOrientationUserInfoKeyKey = @"UIApplicationStatusBarOrientationUserInfoKey";
NSString *const UIApplicationWillChangeStatusBarFrameNotificationKey = @"UIApplicationWillChangeStatusBarFrameNotification";
NSString *const UIApplicationDidChangeStatusBarFrameNotificationKey = @"UIApplicationDidChangeStatusBarFrameNotification";
NSString *const UIApplicationStatusBarFrameUserInfoKeyKey = @"UIApplicationStatusBarFrameUserInfoKey";
NSString *const UIApplicationBackgroundRefreshStatusDidChangeNotificationKey = @"UIApplicationBackgroundRefreshStatusDidChangeNotification";
NSString *const UIApplicationLaunchOptionsURLKeyKey = @"UIApplicationLaunchOptionsURLKey";
NSString *const UIApplicationLaunchOptionsSourceApplicationKeyKey = @"UIApplicationLaunchOptionsSourceApplicationKey";
NSString *const UIApplicationLaunchOptionsRemoteNotificationKeyKey = @"UIApplicationLaunchOptionsRemoteNotificationKey";
NSString *const UIApplicationLaunchOptionsLocalNotificationKeyKey = @"UIApplicationLaunchOptionsLocalNotificationKey";
NSString *const UIApplicationLaunchOptionsAnnotationKeyKey = @"UIApplicationLaunchOptionsAnnotationKey";
NSString *const UIApplicationProtectedDataWillBecomeUnavailableKey = @"UIApplicationProtectedDataWillBecomeUnavailable";
NSString *const UIApplicationProtectedDataDidBecomeAvailableKey = @"UIApplicationProtectedDataDidBecomeAvailable";
NSString *const UIApplicationLaunchOptionsLocationKeyKey = @"UIApplicationLaunchOptionsLocationKey";
NSString *const UIApplicationLaunchOptionsNewsstandDownloadsKeyKey = @"UIApplicationLaunchOptionsNewsstandDownloadsKey";
NSString *const UIApplicationLaunchOptionsBluetoothCentralsKeyKey = @"UIApplicationLaunchOptionsBluetoothCentralsKey";
NSString *const UIApplicationLaunchOptionsBluetoothPeripheralsKeyKey = @"UIApplicationLaunchOptionsBluetoothPeripheralsKey";
NSString *const UIContentSizeCategoryExtraSmallKey = @"UIContentSizeCategoryExtraSmall";
NSString *const UIContentSizeCategorySmallKey = @"UIContentSizeCategorySmall";
NSString *const UIContentSizeCategoryMediumKey = @"UIContentSizeCategoryMedium";
NSString *const UIContentSizeCategoryLargeKey = @"UIContentSizeCategoryLarge";
NSString *const UIContentSizeCategoryExtraLargeKey = @"UIContentSizeCategoryExtraLarge";
NSString *const UIContentSizeCategoryExtraExtraLargeKey = @"UIContentSizeCategoryExtraExtraLarge";
NSString *const UIContentSizeCategoryExtraExtraExtraLargeKey = @"UIContentSizeCategoryExtraExtraExtraLarge";
NSString *const UIContentSizeCategoryAccessibilityMediumKey = @"UIContentSizeCategoryAccessibilityMedium";
NSString *const UIContentSizeCategoryAccessibilityLargeKey = @"UIContentSizeCategoryAccessibilityLarge";
NSString *const UIContentSizeCategoryAccessibilityExtraLargeKey = @"UIContentSizeCategoryAccessibilityExtraLarge";
NSString *const UIContentSizeCategoryAccessibilityExtraExtraLargeKey = @"UIContentSizeCategoryAccessibilityExtraExtraLarge";
NSString *const UIContentSizeCategoryAccessibilityExtraExtraExtraLargeKey = @"UIContentSizeCategoryAccessibilityExtraExtraExtraLarge";
NSString *const UIContentSizeCategoryDidChangeNotificationKey = @"UIContentSizeCategoryDidChangeNotification";
NSString *const UIContentSizeCategoryNewValueKeyKey = @"UIContentSizeCategoryNewValueKey";
NSString *const UIApplicationUserDidTakeScreenshotNotificationKey = @"UIApplicationUserDidTakeScreenshotNotification";


