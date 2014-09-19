//
//  UIWindow.m
//  UIKit
//
//  Created by Chen Yonghui on 12/6/13.
//  Copyright (c) 2013 Shanghai Tinynetwork Inc. All rights reserved.
//

#import "UIWindow.h"
#import "UIScreen.h"
#import <QuartzCore/QuartzCore.h>
#import "UIViewController.h"
#import "UIEvent.h"
#import "UITouch.h"
#import "UITouch+Private.h"
#import "UIApplication+UIPrivate.h"
#import "UIScreenPrivate.h"
#import "UIGestureRecognizer+UIPrivate.h"
#import "UIGestureRecognizerSubclass.h"

NSString *const UIWindowDidBecomeVisibleNotification = @"UIWindowDidBecomeVisibleNotification";
NSString *const UIWindowDidBecomeHiddenNotification = @"UIWindowDidBecomeHiddenNotification";

@implementation UIWindow
{
    NSMutableSet *_touches;
    NSMutableSet *_excludedRecognizers;
    
    BOOL _landscaped;

}
- (id)initWithFrame:(CGRect)theFrame
{
    if ((self=[super initWithFrame:theFrame])) {
        _undoManager = [[NSUndoManager alloc] init];
        [self _makeHidden];	// do this first because before the screen is set, it will prevent any visibility notifications from being sent.
        self.screen = [UIScreen mainScreen];
        self.opaque = NO;
        _touches = [NSMutableSet set];
        _excludedRecognizers = [NSMutableSet set];
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
        UIViewController *vc = [self _topestViewController];
        vc.view.transform = landscaped ? CGAffineTransformMakeRotation(-M_PI_2) : CGAffineTransformIdentity;
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
    NS_UNIMPLEMENTED_LOG;
//    if ([[self _firstResponder] respondsToSelector:@selector(becomeKeyWindow)]) {
//        [(id)[self _firstResponder] becomeKeyWindow];
//    }
//    [[NSNotificationCenter defaultCenter] postNotificationName:UIWindowDidBecomeKeyNotification object:self];
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
    return ([UIApplication sharedApplication].keyWindow == self);
}

- (void)resignKeyWindow
{
    NS_UNIMPLEMENTED_LOG;
//    if ([[self _firstResponder] respondsToSelector:@selector(resignKeyWindow)]) {
//        [(id)[self _firstResponder] resignKeyWindow];
//    }
//    [[NSNotificationCenter defaultCenter] postNotificationName:UIWindowDidResignKeyNotification object:self];
}

- (void)_makeHidden
{
    if (!self.hidden) {
        [super setHidden:YES];
        if (self.screen) {
            [[UIApplication sharedApplication] _windowDidBecomeHidden:self];
            [[NSNotificationCenter defaultCenter] postNotificationName:UIWindowDidBecomeHiddenNotification object:self];
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
        NSSet *touches = [event touchesForWindow:self];
        
        for (UITouch *t in touches) {
            if (t.phase == UITouchPhaseBegan) {
                [_touches addObject:t];
            } else if (t.phase == UITouchPhaseEnded || t.phase == UITouchPhaseCancelled) {
                [_touches removeObject:t];
            }
        }
        BOOL isAllTouchesEnded = (_touches.count == 0);
        
        NSMutableSet *gestureRecognizers = [NSMutableSet setWithCapacity:0];
        
        for (UITouch *touch in touches) {
            [gestureRecognizers addObjectsFromArray:touch.gestureRecognizers];
        }
        
        for (UIGestureRecognizer *recognizer in gestureRecognizers) {
            if (![_excludedRecognizers containsObject:recognizer]) {
                [recognizer _recognizeTouches:touches withEvent:event];
            }
        }
        
        for (UIGestureRecognizer *recognizer in gestureRecognizers) {
            if (![recognizer _isFailed]) {
                for (UIGestureRecognizer *other in gestureRecognizers) {
                    if (![other _isFailed]) {
                        BOOL exclued = [recognizer _isExcludedByGesture:other];
                        if (exclued) {
                            [recognizer _setExcluded];
                            [_excludedRecognizers addObject:recognizer];
                        }
                    }
                }
            }
        }
        if (isAllTouchesEnded) {
            [_excludedRecognizers removeAllObjects];
        }
        
        for (UITouch *touch in touches) {
            // normally there'd be no need to retain the view here, but this works around a strange problem I ran into.
            // what can happen is, now that UIView's -removeFromSuperview will remove the view from the active touch
            // instead of just cancel the touch (which is how I had implemented it previously - which was wrong), the
            // situation can arise where, in response to a touch event of some kind, the view may remove itself from its
            // superview in some fashion, which means that the handling of the touchesEnded:withEvent: (or whatever)
            // methods could somehow result in the view itself being destroyed before the method is even finished running!
            // I ran into this in particular with a load more button in Twitterrific which would crash in UIControl's
            // touchesEnded: implemention after sending actions to the registered targets (because one of those targets
            // ended up removing the button from view and thus reducing its retain count to 0). For some reason, even
            // though I attempted to rearrange stuff in UIControl so that actions were always the last thing done, it'd
            // still end up crashing when one of the internal methods returned to touchesEnded:, which didn't make sense
            // to me because there was no code after that (at the time) and therefore it should just have been unwinding
            // the stack to eventually get back here and all should have been okay. I never figured out exactly why that
            // crashed in that way, but by putting a retain here it works around this problem and perhaps others that have
            // gone so-far unnoticed. Converting to ARC should also work with this solution because there will be a local
            // strong reference to the view retainined throughout the rest of this logic and thus the same protection
            // against mid-method view destrustion should be provided under ARC. If someone can figure out some other,
            // better way to fix this without it having to have this hacky-feeling retain here, that'd be cool, but be
            // aware that this is here for a reason and that the problem it prevents is very rare and somewhat contrived.
            UIView *view = touch.view;
            
            const UITouchPhase phase = touch.phase;
            const _UITouchGesture gesture = [touch _gesture];
            
            static NSDictionary *map = nil;
            if (!map) {
                map = @{
                        @(UITouchPhaseBegan):@"UITouchPhaseBegan",
                        @(UITouchPhaseMoved):@"UITouchPhaseMoved",
                        @(UITouchPhaseEnded):@"UITouchPhaseEnded",
                        @(UITouchPhaseCancelled):@"UITouchPhaseCancelled",
                        @(UITouchPhaseStationary):@"UITouchPhaseStationary",
                        @(_UITouchPhaseGestureBegan):@"_UITouchPhaseGestureBegan",
                        @(_UITouchPhaseGestureChanged):@"_UITouchPhaseGestureChanged",
                        @(_UITouchPhaseGestureEnded):@"_UITouchPhaseGestureEnded",
                        @(_UITouchPhaseDiscreteGesture):@"_UITouchPhaseDiscreteGesture",};
            }
            
            NSLog(@"phase:%@",[map objectForKey:@(phase)]);
            
            if (phase == UITouchPhaseBegan) {
                [view touchesBegan:touches withEvent:event];
            } else if (phase == UITouchPhaseMoved) {
                [view touchesMoved:touches withEvent:event];
            } else if (phase == UITouchPhaseEnded) {
                [view touchesEnded:touches withEvent:event];
            } else if (phase == UITouchPhaseCancelled) {
                [view touchesCancelled:touches withEvent:event];
            } else {
                NSLog(@"Unknow touch phase:%d",phase);
            }
        }
    }
}
@end

const UIWindowLevel UIWindowLevelNormal = 0;
const UIWindowLevel UIWindowLevelAlert = 2000;
const UIWindowLevel UIWindowLevelStatusBar = 1000;

