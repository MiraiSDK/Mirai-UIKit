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
#import "UIWindow+UIPrivate.h"
#import <QuartzCore/QuartzCore.h>
#import "UIScreenPrivate.h"
#import "UIGraphics.h"
#import "UIEvent.h"
#import "UITouch.h"
#import "UIEvent+Android.h"
#import "UITouch+Private.h"
#import "UIViewController+Private.h"

#import <Foundation/NSObjCRuntime.h>
#include "AndroidMain.h"

#import "BKRenderingService.h"
#import <TNJavaHelper/TNJavaHelper.h>
#import "UIAndroidEventsServer.h"

@interface UIApplication ()

@end

@implementation UIApplication {
    BOOL _isRunning;
    
    UIEvent *_currentEvent;
    NSMutableSet *_visibleWindows;

    __weak UIWindow *_keyWindow;
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

#pragma mark - Orientation
- (UIViewController *)_topestViewController
{
    UIViewController *vc = self.keyWindow.rootViewController;
    while (vc.presentedViewController) {
        vc = vc.presentedViewController;
    }
    
    return vc;
}
- (NSUInteger)supportedInterfaceOrientations
{
    //FIXME: Legcy modelViewController not supported.
    UIViewController *vc = [self _topestViewController];
    return vc.supportedInterfaceOrientations;
}

typedef NS_ENUM(NSInteger, SCREEN_ORIENTATION) {
    SCREEN_ORIENTATION_UNSPECIFIED = -1,

    SCREEN_ORIENTATION_LANDSCAPE = 0,
    SCREEN_ORIENTATION_PORTRAIT = 1,
    SCREEN_ORIENTATION_USER = 2,
    SCREEN_ORIENTATION_BEHIND = 3,

    SCREEN_ORIENTATION_SENSOR = 4,
    SCREEN_ORIENTATION_NOSENSOR = 5,
    
    SCREEN_ORIENTATION_SENSOR_LANDSCAPE = 6,
    SCREEN_ORIENTATION_SENSOR_PORTRAIT = 7,
    SCREEN_ORIENTATION_REVERSE_LANDSCAPE = 8,
    SCREEN_ORIENTATION_REVERSE_PORTRAIT = 9,
    SCREEN_ORIENTATION_FULL_SENSOR = 10,
    SCREEN_ORIENTATION_USER_LANDSCAPE = 11,
    SCREEN_ORIENTATION_USER_PORTRAIT = 12,
    SCREEN_ORIENTATION_FULL_USER = 13,
    SCREEN_ORIENTATION_LOCKED = 14,
};

- (int)JAVA_SCREEN_ORIENTATIONForCocoaInterfaceOrientations:(NSUInteger)supportedInterfaceOrientations
{
    jint o = SCREEN_ORIENTATION_SENSOR;
    
    BOOL supportedPortrait = (supportedInterfaceOrientations & UIInterfaceOrientationMaskPortrait) == UIInterfaceOrientationMaskPortrait;
    BOOL supportedPortraitUpsideDown = (supportedInterfaceOrientations & UIInterfaceOrientationMaskPortraitUpsideDown) == UIInterfaceOrientationMaskPortraitUpsideDown;
    BOOL supportedLandscapeLeft = (supportedInterfaceOrientations & UIInterfaceOrientationMaskLandscapeLeft) == UIInterfaceOrientationMaskLandscapeLeft;
    BOOL supportedLandscapeRight = (supportedInterfaceOrientations & UIInterfaceOrientationMaskLandscapeRight) == UIInterfaceOrientationMaskLandscapeRight;
    
    BOOL portrait = supportedPortrait || supportedPortraitUpsideDown;
    BOOL landscape = supportedLandscapeLeft || supportedLandscapeRight;
    if (portrait && landscape) {
        o = SCREEN_ORIENTATION_SENSOR;
    } else if (portrait && !landscape) {
        o = SCREEN_ORIENTATION_PORTRAIT;
    } else if (!portrait && landscape) {
        o = SCREEN_ORIENTATION_LANDSCAPE;
    }

    return o;
}

- (void)updateAndroidOrientation:(JNIEnv *)env
{
    
    jclass thiz = [[TNJavaHelper sharedHelper] clazz];
    
    jclass test = (*env)->GetObjectClass(env, thiz);

    jmethodID messageID = (*env)->GetMethodID(env,test,"updateSupportedOrientation","(I)V");

    NSUInteger supportedInterfaceOrientations = [_app supportedInterfaceOrientations];
    jint o = [self JAVA_SCREEN_ORIENTATIONForCocoaInterfaceOrientations:supportedInterfaceOrientations];
    
    (*env)->CallVoidMethod(env,thiz,messageID,o);

    (*env)->DeleteLocalRef(env,test);
}

- (void)_performMemoryWarning
{
    NSLog(@"%s",__PRETTY_FUNCTION__);

    // post notification
    NSLog(@"postNotificationName:%@",UIApplicationDidReceiveMemoryWarningNotification);
    [[NSNotificationCenter defaultCenter] postNotificationName:UIApplicationDidReceiveMemoryWarningNotification object:nil];

    // call -didReceiveMemoryWarning on view controllers
    [UIViewController _performMemoryWarning];
    
}
void Java_org_tiny4_CocoaActivity_CocoaActivity_nativeOnTrimMemory(JNIEnv *env, jobject obj, int level) {
    //onTrimMemory
    NSLog(@"%s",__PRETTY_FUNCTION__);
    
    @autoreleasepool {
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            [_app _performMemoryWarning];
        }];
    }
    
}

- (void)_performKeyboardEvent:(BOOL)show keyboardHeight:(CGFloat)keyboarHeight
{
    CGRect screenBounds = [[UIScreen mainScreen] bounds];
    CGSize keyboardSize = CGSizeMake(CGRectGetWidth(screenBounds), keyboarHeight);
    
    CGRect showFrame = CGRectMake(0, screenBounds.size.height - keyboarHeight,
                                  keyboardSize.width, keyboarHeight);
    CGRect hiddenFrame = CGRectMake(0, screenBounds.size.height,
                                    keyboardSize.width, keyboarHeight);
    showFrame = [_app.keyWindow.rootViewController.view convertRect:showFrame toView:nil];
    hiddenFrame = [_app.keyWindow.rootViewController.view convertRect:hiddenFrame toView:nil];
    
    CGRect frameBegin = CGRectZero;
    CGRect frameEnd = CGRectZero;
    NSString *notificationName = nil;
    //FIXME: android event only has keyboard did show/hide event
    // should we post event twice here?
    if (show) {
        frameBegin = hiddenFrame;
        frameEnd = showFrame;
        notificationName = UIKeyboardWillShowNotification;
    } else {
        frameBegin = showFrame;
        frameEnd = hiddenFrame;
        notificationName = UIKeyboardWillHideNotification;
    }
    NSLog(@"send notification:%@",notificationName);
    
    
    NSTimeInterval duration = 0.25;
    UIViewAnimationCurve curve = UIViewAnimationCurveEaseInOut;
    
    NSDictionary *userInfo =
    @{
      UIKeyboardFrameBeginUserInfoKey : [NSValue valueWithCGRect:frameBegin],
      UIKeyboardFrameEndUserInfoKey : [NSValue valueWithCGRect:frameEnd],
      UIKeyboardAnimationCurveUserInfoKey:@(curve),
      UIKeyboardAnimationDurationUserInfoKey:@(duration)
      };
    
    
    [[NSNotificationCenter defaultCenter] postNotificationName:notificationName object:nil userInfo:userInfo];
}

void Java_org_tiny4_CocoaActivity_GLViewRender_nativeOnKeyboardShowHide(JNIEnv *env, jobject obj, int shown,int height) {
    NSLog(@"%s, shown:%d height:%d",__PRETTY_FUNCTION__,shown,height);
    @autoreleasepool {
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            [_app _performKeyboardEvent:shown keyboardHeight:height];
        }];
    }
}

- (void)_appDidBecomeActive
{
    NSLog(@"%s",__PRETTY_FUNCTION__);
    NSAssert([NSThread isMainThread], @"%s should been called in main thread");

    if ([self.delegate respondsToSelector:@selector(applicationDidBecomeActive:)]) {
        [self.delegate applicationDidBecomeActive:self];
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:UIApplicationDidBecomeActiveNotification object:self];
    
}

- (void)_appWillResignActive
{
    NSAssert([NSThread isMainThread], @"%s should been called in main thread");

    if ([self.delegate respondsToSelector:@selector(applicationWillResignActive:)]) {
        [self.delegate applicationWillResignActive:self];
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:UIApplicationWillResignActiveNotification object:self];

}

- (void)_appWillEnterForeground
{
    NSAssert([NSThread isMainThread], @"%s should been called in main thread");

    if ([self.delegate respondsToSelector:@selector(applicationWillEnterForeground:)]) {
        [self.delegate applicationWillEnterForeground:self];
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:UIApplicationWillEnterForegroundNotification object:self];
    
}

- (void)_appDidEnterBackground
{
    NSLog(@"%s",__PRETTY_FUNCTION__);
    NSAssert([NSThread isMainThread], @"%s should been called in main thread");

    if ([self.delegate respondsToSelector:@selector(applicationDidEnterBackground:)]) {
        [self.delegate applicationDidEnterBackground:self];
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:UIApplicationDidEnterBackgroundNotification object:self];
}

- (void)_appWillTerminate
{
    NSAssert([NSThread isMainThread], @"%s should been called in main thread");
    if ([self.delegate respondsToSelector:@selector(applicationWillTerminate:)]) {
        [self.delegate applicationWillTerminate:self];
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:UIApplicationWillTerminateNotification object:self];
}

- (id)nextEventBeforeDate:(NSDate *)limit inMode:(NSString *)mode
{
    return nil;
}

- (void)appstartEvent{}

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
        BKRenderingServiceRun();
        UIAndroidEventsServerResume();
        
        NSTimer *timer = [NSTimer timerWithTimeInterval:0 target:self selector:@selector(appstartEvent) userInfo:nil repeats:NO];
        [[NSRunLoop currentRunLoop] addTimer:timer forMode:NSDefaultRunLoopMode];
        
        @try {
        do {
            @autoreleasepool {
                NSDate *begin = [NSDate date];
                
                //TODO: should use distantFuture to reduce cpu usage
                // but use distantFuture has a bug:
                //      runMode:beforeDate: will wait until first input source processed or beforeDate is reached. timer is not considered an input source
                //      and performSelector:withObject:afterDelay: is a timer
                //      so if we do any ui change in a timer or performSelector, that will not at screen until runloop return
//                NSDate *untilDate = [NSDate distantFuture];
                NSDate *untilDate = [NSDate date];
                [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:untilDate];

                
//                UIEvent *event = [self nextEventBeforeDate:untilDate inMode:NSDefaultRunLoopMode];
                
                // send event
                NSTimeInterval eventUsage = 0.0;
                if (UIAndroidEventsServerHasEvents()) {
                    NSDate *evenStart = [NSDate date];
                    UIAndroidEventsGetEvent(_currentEvent);
                    
                    [self sendEvent:_currentEvent];
                    
                    [_currentEvent _cleanTouches];
                    int32_t handled = 1;
                    
                    eventUsage = -[evenStart timeIntervalSinceNow];
                }
                
                
                // check supportedInterfaceOrientations changes
                static NSUInteger prevSupportedInterfaceOrientation = UIInterfaceOrientationMaskAll;
                NSUInteger supportedInterfaceOrientations = [self supportedInterfaceOrientations];
                if (prevSupportedInterfaceOrientation != supportedInterfaceOrientations) {
                    //supportedInterfaceOrientations changed, notify android activity
                    [self updateAndroidOrientation:[[TNJavaHelper sharedHelper] env]];
                    prevSupportedInterfaceOrientation = supportedInterfaceOrientations;
                }
            
                @autoreleasepool {
                    // commit?
                    NSDate *layouStart = [NSDate date];
                    UIWindow *keyWindow = _app.keyWindow;
                    
                    CALayer *pixelLayer = [[UIScreen mainScreen] _pixelLayer];
                    [[UIScreen mainScreen] _setLandscaped:AMIsLandscaped()];
                    
                    [pixelLayer _recursionLayoutAndDisplayIfNeeds];
                    
                    NSTimeInterval layoutUsage = -[layouStart timeIntervalSinceNow];

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
                    
                    NSDate *commit = [NSDate date];

                    //Client Side
                    //  commitIfNeeds
                    [CATransaction commit];
                    NSTimeInterval commitUsage = -[commit timeIntervalSinceNow];

                    NSDate *copyRender = [NSDate date];
                    //      copy renderTree
                    CALayer *renderTree = [pixelLayer copyRenderLayer:nil];
                    NSTimeInterval copyUsage = -[copyRender timeIntervalSinceNow];

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
                    NSTimeInterval usage = -[begin timeIntervalSinceNow];
                    //NSLog(@"runloop:%fs, event:%f layout:%f commit:%f copy:%f",usage,eventUsage,layoutUsage,commitUsage,copyUsage);
                    
                }
            }
        } while (_isRunning);
            
        }
        @catch (NSException *exception) {
            NSLog(@"exception:%@",exception);
            abort();
        }

    }

    NSLog(@"end running");

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

- (UIWindow *)keyWindow
{
    if (_keyWindow) {
        return _keyWindow;
    }
    
     UIWindow *window = [[self windows] lastObject];
    return window;
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
    NSMutableSet *windows = [NSMutableSet set];
    for (UITouch *touch in [event allTouches]) {
        if (touch.window) {
            [windows addObject:touch.window];
        } else {
            NSLog(@"[WARNING]A touch missing it's window:%@",touch);
        }
    }
    
    for (UIWindow *w in windows) {
        [w sendEvent:event];
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
        // 1. start display services
        // 2. register event callback
        // 3. push runloop mode
        // 4. start windows server
        // 5. start status bar server
        // 6.
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


