//
//  UIMultiTouchProcess.m
//  UIKit
//
//  Created by TaoZeyu on 15/8/20.
//  Copyright (c) 2015年 Shanghai Tinynetwork Inc. All rights reserved.
//

#import "UIMultiTouchProcess.h"
#import "UITouch+Private.h"
#import "UIGestureRecognizeProcess.h"
#import "UIGestureRecognizerSubclass.h"
#import "UIGestureRecognizer+UIPrivate.h"

@implementation UIMultiTouchProcess
{
    UIWindow *_window;
    
    NSInteger _currentPressFingersCount;
    BOOL _legacyAnyRecognizeProcesses;
    BOOL _multiTouchNotEnded;
    
    NSMutableDictionary *_effectRecognizeProcesses;
    NSMutableSet *_trackedTouches;
}
@synthesize handingTouchEvent=_handingTouchEvent;

- (instancetype)init
{
    if (self = [super init]) {
        _effectRecognizeProcesses = [NSMutableDictionary dictionary];
        _trackedTouches = [NSMutableSet set];
    }
    return self;
}

- (instancetype)initWithWindow:(UIWindow *)window
{
    if (self = [self init]) {
        _window = window;
    }
    return self;
}

- (UIWindow *)window
{
    return _window;
}

- (void)sendEvent:(UIEvent *)event
{
    NSSet *touches = [event touchesForWindow:_window];
    
    BOOL touchBegin = NO;
    BOOL touchEnd = NO;
    
    [self _reciveTouches:touches andCheckMultiTouchProcessStateWithTouchBegin:&touchBegin
                touchEnd:&touchEnd];
    
    if (touchBegin) {
        NSLog(@"[begin multi-touch]");
        [self _initializeMultiTouchContextWhenBegin];
    }
    _handingTouchEvent = YES;
    
    [self _trackTouches:touches generateRecognizeProcessIfNotExist:!_legacyAnyRecognizeProcesses];
    
    if (touchBegin) {
        [self _beginWithEvent:event touches:touches];
    }
    NSArray *recognizerProcesses = [_effectRecognizeProcesses allValues];
    
    for (UIGestureRecognizeProcess *recognizeProcess in recognizerProcesses) {
        [recognizeProcess recognizeEvent:event touches:touches];
    }
    
    for (UIGestureRecognizeProcess *recognizeProcess in recognizerProcesses) {
        [recognizeProcess sendToAttachedViewIfNeedWithEvent:event touches:touches];
    }
    [self _handleNotTrackedTouches:touches event:event];
    
    if (touchEnd) {
        [self _end];
        _multiTouchNotEnded = NO;
        NSLog(@"[end multi-touch]");
    }
    _handingTouchEvent = NO;
}

- (void)_reciveTouches:(NSSet *)touches andCheckMultiTouchProcessStateWithTouchBegin:(BOOL *)touchBegin
            touchEnd:(BOOL *)touchEnd
{
    // I can't set _currentPressFingersCount as [touches count].
    // because when [touches count] become 0, the sendEvent: will never be called.
    // but I must call _end method when touches ended.
    
    // So, I check [UITouch phase] and get the next [touches count] will be.
    
    NSInteger originalPressFingersCount = _currentPressFingersCount;
    NSInteger incrementCount = [self _incrementPressFingersCountWithTouches:touches];
    
    _currentPressFingersCount += incrementCount;
    
    if (incrementCount != 0) {
        
        if (originalPressFingersCount == 0) {
            *touchBegin = YES;
            
        } else if (_currentPressFingersCount == 0) {
            *touchEnd = YES;
        }
    }
}

- (NSInteger)_incrementPressFingersCountWithTouches:(NSSet *)touches
{
    NSInteger incrementCount = 0;
    
    for (UITouch *touch in touches) {
        
        UITouchPhase phase = touch.phase;
        
        if (phase == UITouchPhaseBegan) {
            incrementCount++;
            
        } else if(phase == UITouchPhaseEnded || phase == UITouchPhaseCancelled) {
            incrementCount--;
        }
    }
    return incrementCount;
}

- (void)_initializeMultiTouchContextWhenBegin
{
    _multiTouchNotEnded = YES;
    _legacyAnyRecognizeProcesses = _effectRecognizeProcesses.count > 0;
    
    if (_legacyAnyRecognizeProcesses) {
        
        NSMutableSet *legacyNames = [NSMutableSet set];
        for (UIGestureRecognizeProcess *recognizeProcess in [_effectRecognizeProcesses allValues]) {
            for (UIGestureRecognizer *recognizer in recognizeProcess.gestureRecognizers) {
                [legacyNames addObject:recognizer.className];
            }
        }
        
        NSLog(@"legacy any recognize processes. it won't generate any new recognize processes before legacy processes make conclusion.");
        NSLog(@"there are %li recognize processes didn't make conclusion. list : %@",
              _effectRecognizeProcesses.count, legacyNames);
    }
}

- (void)_beginWithEvent:(UIEvent *)event touches:(NSSet *)touches
{
    for (UIGestureRecognizeProcess *recognizeProcess in [_effectRecognizeProcesses allValues]) {
        [recognizeProcess multiTouchBegin];
    }
}

- (void)_trackTouches:(NSSet *)touches generateRecognizeProcessIfNotExist:(BOOL)generate
{
    for (UITouch *touch in touches) {
        
        if (touch.phase != UITouchPhaseBegan) {
            continue;
        }
        
        UIView *view = [self _findViewCanCatch:touch.view];
        
        if (!view) {
            continue;
        }
        
        NSValue *keyView = [NSValue valueWithNonretainedObject:view];
        UIGestureRecognizeProcess *recognizeProcess = [_effectRecognizeProcesses objectForKey:keyView];
        
        if (!recognizeProcess && generate) {
            recognizeProcess = [[UIGestureRecognizeProcess alloc] initWithView:view
                                                             multiTouchProcess:self];
            [_effectRecognizeProcesses setObject:recognizeProcess forKey:keyView];
        }
        
        if (recognizeProcess) {
            [recognizeProcess trackTouch:touch];
            [_trackedTouches addObject:touch];
        }
    }
}

- (UIView *)_findViewCanCatch:(UIView *)view
{
    while (view && ![UIGestureRecognizeProcess canViewCatchTouches:view]) {
        view = view.superview;
    }
    return view;
}

- (void)_handleNotTrackedTouches:(NSSet *)touches event:(UIEvent *)event
{
    for (UITouch *touch in touches) {
        if (![_trackedTouches containsObject:touch]) {
            [self _callViewAndSuperviewsWithForNotTrackedTouch:touch event:event];
        }
    }
}

- (void)_callViewAndSuperviewsWithForNotTrackedTouch:(UITouch *)touch event:(UIEvent *)event
{
    NSSet *wrapTouchSet = [[NSSet alloc] initWithObjects:touch, nil];
    SEL callbackMethod = [self _callbackMethodForTouchPhase:touch.phase];
    
    if (callbackMethod) {
        
        UIView *view = touch.view;
        
        while (view) {
            [view performSelector:callbackMethod withObject:wrapTouchSet withObject:event];
            view = view.superview;
        }
    }
}

- (SEL)_callbackMethodForTouchPhase:(UITouchPhase)phase
{
    switch (phase) {
        case UITouchPhaseBegan:
            return @selector(touchesBegan:withEvent:);
            
        case UITouchPhaseMoved:
            return @selector(touchesMoved:withEvent:);
            
        case UITouchPhaseEnded:
            return @selector(touchesEnded:withEvent:);
            
        case UITouchPhaseCancelled:
            return @selector(touchesCancelled:withEvent:);
            
        default:
            return NULL;
    }
}

- (void)_end
{
    for (UIGestureRecognizeProcess *recognizeProcess in [_effectRecognizeProcesses allValues]) {
        [recognizeProcess multiTouchEnd];
    }
    [_trackedTouches removeAllObjects];
    [self _clearHasMakeConclusionReconizeProcesses];
}

- (NSSet *)_leftRecognizerNames
{
    NSMutableSet *leftRecognizerNames = [[NSMutableSet alloc] init];
    for (UIGestureRecognizeProcess *recognizerProcess in [_effectRecognizeProcesses allValues]) {
        for (UIGestureRecognizer *recognizer in recognizerProcess.gestureRecognizers) {
            [leftRecognizerNames addObject:recognizer.className];
        }
    }
    return leftRecognizerNames;
}

- (void)gestureRecognizeProcessMakeConclusion:(UIGestureRecognizeProcess *)gestureRecognizeProcess
{
    if (!_multiTouchNotEnded) {
        
        NSValue *keyView = [NSValue valueWithNonretainedObject:gestureRecognizeProcess.view];
        [_effectRecognizeProcesses removeObjectForKey:keyView];
    }
}

- (void)_clearHasMakeConclusionReconizeProcesses
{
    NSMutableArray *hasMakeConclusionViews = [[NSMutableArray alloc]init];
    
    for (NSValue *key in [_effectRecognizeProcesses allKeys]) {
        
        UIGestureRecognizeProcess *recognizeProcess = [_effectRecognizeProcesses objectForKey:key];
        
        if (recognizeProcess.hasMakeConclusion) {
            [hasMakeConclusionViews addObject:key];
        }
    }
    [_effectRecognizeProcesses removeObjectsForKeys:hasMakeConclusionViews];
}

@end
