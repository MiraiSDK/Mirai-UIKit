//
//  UIWindow.m
//  UIKit
//
//  Created by Chen Yonghui on 12/6/13.
//  Copyright (c) 2013 Shanghai Tinynetwork Inc. All rights reserved.
//

#import "UIWindow+UIPrivate.h"
#import "UIScreen.h"
#import "UIScreenPrivate.h"
#import <QuartzCore/QuartzCore.h>
#import "UIViewController.h"
#import "UIEvent.h"
#import "UITouch.h"
#import "UITouch+Private.h"
#import "UIApplication+UIPrivate.h"
#import "UIScreenPrivate.h"
#import "UITopFloatView.h"
#import "UIMultiTouchProcess.h"

NSString *const UIWindowDidBecomeVisibleNotification = @"UIWindowDidBecomeVisibleNotification";
NSString *const UIWindowDidBecomeHiddenNotification = @"UIWindowDidBecomeHiddenNotification";

NSString *const UIWindowDidBecomeKeyNotification = @"UIWindowDidBecomeKeyNotification";
NSString *const UIWindowDidResignKeyNotification = @"UIWindowDidResignKeyNotification";

NSString *const UIKeyboardWillShowNotification = @"UIKeyboardWillShowNotification";
NSString *const UIKeyboardDidShowNotification = @"UIKeyboardDidShowNotification";
NSString *const UIKeyboardWillHideNotification = @"UIKeyboardWillHideNotification";
NSString *const UIKeyboardDidHideNotification = @"UIKeyboardDidHideNotification";

NSString *const UIKeyboardFrameBeginUserInfoKey = @"UIKeyboardFrameBeginUserInfoKey";
NSString *const UIKeyboardFrameEndUserInfoKey = @"UIKeyboardFrameEndUserInfoKey";
NSString *const UIKeyboardAnimationDurationUserInfoKey = @"UIKeyboardAnimationDurationUserInfoKey";
NSString *const UIKeyboardAnimationCurveUserInfoKey = @"UIKeyboardAnimationCurveUserInfoKey";

NSString *const UIKeyboardWillChangeFrameNotification = @"UIKeyboardWillChangeFrameNotification";
NSString *const UIKeyboardDidChangeFrameNotification = @"UIKeyboardDidChangeFrameNotification";

@implementation UIWindow
{
    UIMultiTouchProcess *_currentMultiTouchProcess;
    NSInteger _currentPressFingersCount;
    BOOL _landscaped;

}
- (id)initWithFrame:(CGRect)theFrame
{
    if ((self=[super initWithFrame:theFrame])) {
        _undoManager = [[NSUndoManager alloc] init];
        [self _makeHidden];	// do this first because before the screen is set, it will prevent any visibility notifications from being sent.
        self.screen = [UIScreen mainScreen];
        self.opaque = NO;
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self _makeHidden];	// I don't really like this here, but the real UIKit seems to do something like this on window destruction as it sends a notification and we also need to remove it from the app's list of windows
    
}

- (UIView *)superview
{
    return nil;		// lies!
}

- (void)removeFromSuperview
{
    // does nothing
}

- (UIWindow *)window
{
    return self;
}

- (UIResponder *)nextResponder
{
    return [UIApplication sharedApplication];
}

- (void)setRootViewController:(UIViewController *)rootViewController
{
    if (rootViewController != _rootViewController) {
        if (_rootViewController) {
            [_rootViewController.view removeFromSuperview];
        }
        _rootViewController = rootViewController;
        _rootViewController.view.frame = self.bounds;    // unsure about this
        _rootViewController.view.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [self addSubview:_rootViewController.view];
        
        UIViewController *vc = rootViewController;
        vc.view.frame = self.window.bounds;
    }
}

- (void)setScreen:(UIScreen *)theScreen
{
    if (theScreen != _screen) {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:UIScreenModeDidChangeNotification object:_screen];
        
        const BOOL wasHidden = self.hidden;
        [self _makeHidden];
        
        [self.layer removeFromSuperlayer];
        _screen = theScreen;
        [self _setLandscaped:[theScreen _isLandscaped]];
        
        self.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleLeftMargin;
        [[_screen _windowLayer] addSublayer:self.layer];
        
        if (!wasHidden) {
            [self _makeVisible];
        }
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_screenModeChangedNotification:) name:UIScreenModeDidChangeNotification object:_screen];
    }
}

- (UIViewController *)_topestViewController
{
    UIViewController *vc = self.rootViewController;
    while (vc.presentedViewController) {
        vc = vc.presentedViewController;
    }
    
    return vc;
}

- (void)_setLandscaped:(BOOL)landscaped
{
    if (_landscaped != landscaped) {
        CGRect newFrame = self.frame;
        newFrame.size = CGSizeMake(newFrame.size.height, newFrame.size.width);
        self.frame = newFrame;
        
        UIViewController *vc = [self _topestViewController];
        vc.view.frame = self.window.bounds;
        _landscaped = landscaped;
    }
}

- (UIInterfaceOrientation)_currentOrientation
{
    if (_landscaped) {
        return UIInterfaceOrientationLandscapeLeft;
    }
    
    return UIInterfaceOrientationPortrait;
}

- (void)_screenModeChangedNotification:(NSNotification *)note
{
    NS_UNIMPLEMENTED_LOG;
//    UIScreenMode *previousMode = [[note userInfo] objectForKey:@"_previousMode"];
//    UIScreenMode *newMode = _screen.currentMode;
//    
//    if (!CGSizeEqualToSize(previousMode.size,newMode.size)) {
//        [self _superviewSizeDidChangeFrom:previousMode.size to:newMode.size];
//    }
}

- (CGPoint)convertPoint:(CGPoint)toConvert toWindow:(UIWindow *)toWindow
{
    NS_UNIMPLEMENTED_LOG;
    return toConvert;
//    if (toWindow == self) {
//        return toConvert;
//    } else {
//        // Convert to screen coordinates
//        toConvert.x += self.frame.origin.x;
//        toConvert.y += self.frame.origin.y;
//        
//        if (toWindow) {
//            // Now convert the screen coords into the other screen's coordinate space
//            toConvert = [self.screen convertPoint:toConvert toScreen:toWindow.screen];
//            
//            // And now convert it from the new screen's space into the window's space
//            toConvert.x -= toWindow.frame.origin.x;
//            toConvert.y -= toWindow.frame.origin.y;
//        }
//        
//        return toConvert;
//    }
}

- (CGPoint)convertPoint:(CGPoint)toConvert fromWindow:(UIWindow *)fromWindow
{
    NS_UNIMPLEMENTED_LOG;
    return toConvert;
//    if (fromWindow == self) {
//        return toConvert;
//    } else {
//        if (fromWindow) {
//            // Convert to screen coordinates
//            toConvert.x += fromWindow.frame.origin.x;
//            toConvert.y += fromWindow.frame.origin.y;
//            
//            // Change to this screen.
//            toConvert = [self.screen convertPoint:toConvert fromScreen:fromWindow.screen];
//        }
//        
//        // Convert to window coordinates
//        toConvert.x -= self.frame.origin.x;
//        toConvert.y -= self.frame.origin.y;
//        
//        return toConvert;
//    }
}

- (CGRect)convertRect:(CGRect)toConvert fromWindow:(UIWindow *)fromWindow
{
    CGPoint convertedOrigin = [self convertPoint:toConvert.origin fromWindow:fromWindow];
    return CGRectMake(convertedOrigin.x, convertedOrigin.y, toConvert.size.width, toConvert.size.height);
}

- (CGRect)convertRect:(CGRect)toConvert toWindow:(UIWindow *)toWindow
{
    CGPoint convertedOrigin = [self convertPoint:toConvert.origin toWindow:toWindow];
    return CGRectMake(convertedOrigin.x, convertedOrigin.y, toConvert.size.width, toConvert.size.height);
}

- (void)becomeKeyWindow
{
    if ([[self _firstResponder] respondsToSelector:@selector(becomeKeyWindow)]) {
        [(id)[self _firstResponder] becomeKeyWindow];
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:UIWindowDidBecomeKeyNotification object:self];
}

- (void)makeKeyWindow
{
    if (!self.isKeyWindow) {
        [[UIApplication sharedApplication].keyWindow resignKeyWindow];
        [[UIApplication sharedApplication] _setKeyWindow:self];
        [self becomeKeyWindow];
    }
}

- (BOOL)isKeyWindow
{
    return ([[UIApplication sharedApplication] _cachedKeyWindow] == self);
}

- (void)resignKeyWindow
{
    if ([[self _firstResponder] respondsToSelector:@selector(resignKeyWindow)]) {
        [(id)[self _firstResponder] resignKeyWindow];
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:UIWindowDidResignKeyNotification object:self];
}

- (void)_makeHidden
{
    if (!self.hidden) {
        [super setHidden:YES];
        if (self.screen) {
            [[UIApplication sharedApplication] _windowDidBecomeHidden:self];
            __weak typeof(self) weakSelf = self;
            [[NSNotificationCenter defaultCenter] postNotificationName:UIWindowDidBecomeHiddenNotification object:weakSelf];
        }
    }
}

- (void)_makeVisible
{
    if (self.hidden) {
        [super setHidden:NO];
        if (self.screen) {
            [[UIApplication sharedApplication] _windowDidBecomeVisible:self];
            [[NSNotificationCenter defaultCenter] postNotificationName:UIWindowDidBecomeVisibleNotification object:self];
        }
    }
}

- (void)setHidden:(BOOL)hide
{
    if (hide) {
        [self _makeHidden];
    } else {
        [self _makeVisible];
    }
}

- (void)makeKeyAndVisible
{
    [self _makeVisible];
    [self makeKeyWindow];
}

- (void)setWindowLevel:(UIWindowLevel)level
{
    self.layer.zPosition = level;
}

- (UIWindowLevel)windowLevel
{
    return self.layer.zPosition;
}

- (UIResponder *)_firstResponder
{
    return _firstResponder;
}

- (void)_setFirstResponder:(UIResponder *)newFirstResponder
{
    _firstResponder = newFirstResponder;
}

- (void)sendEvent:(UIEvent *)event
{
    if (event.type == UIEventTypeTouches) {
        
        BOOL touchBegin = NO;
        BOOL touchEnd = NO;
        
        [self _reciveEvent:event andCheckMultiTouchProcessStateWithTouchBegin:&touchBegin touchEnd:&touchEnd];
        
        if (touchBegin) {
            NSLog(@"[begin multi-touch]");
            _currentMultiTouchProcess = [[UIMultiTouchProcess alloc] initWithWindow:self];
            [_currentMultiTouchProcess onBeganWithEvent:event];
        }
        
        if (_currentMultiTouchProcess) {
            [_currentMultiTouchProcess sendEvent:event];
        }
        
        if (touchEnd) {
            NSLog(@"[end multi-touch]");
            [_currentMultiTouchProcess onEnded];
            _currentMultiTouchProcess = nil;
        }
    }
}

- (void)_reciveEvent:(UIEvent *)event andCheckMultiTouchProcessStateWithTouchBegin:(BOOL *)touchBegin
            touchEnd:(BOOL *)touchEnd
{
    NSInteger originalPressFingersCount = _currentPressFingersCount;
    NSInteger incrementCount = [self _incrementPressFingersCountWithEvent:event];
    
    _currentPressFingersCount += incrementCount;
    
    if (originalPressFingersCount == 0 && incrementCount > 0) {
        *touchBegin = YES;
        
    } else if (_currentPressFingersCount == 0 && incrementCount < 0) {
        *touchEnd = YES;
    }
}

- (NSInteger)_incrementPressFingersCountWithEvent:(UIEvent *)event
{
    NSInteger incrementCount = 0;
    
    for (UITouch *touch in [event touchesForWindow:self]) {
        
        UITouchPhase phase = touch.phase;
        
        if (phase == UITouchPhaseBegan) {
            incrementCount++;
            
        } else if(phase == UITouchPhaseEnded || phase == UITouchPhaseCancelled) {
            incrementCount--;
        }
    }
    return incrementCount;
}

- (BOOL)_topFloatView:(UITopFloatView *)topFloatView willMaskTouchWithView:(UIView *)checkedView
{
    while (checkedView) {
        if ([topFloatView allowedReceiveViewAndItsSubviews:checkedView]) {
            return NO;
        }
        checkedView = checkedView.superview;
    }
    return YES;
}

@end

const UIWindowLevel UIWindowLevelNormal = 0;
const UIWindowLevel UIWindowLevelAlert = 2000;
const UIWindowLevel UIWindowLevelStatusBar = 1000;

