//
//  UIMultiTouchProcess.m
//  UIKit
//
//  Created by TaoZeyu on 15/8/20.
//  Copyright (c) 2015年 Shanghai Tinynetwork Inc. All rights reserved.
//

#import "UIMultiTouchProcess.h"
#import "UITouch+Private.h"
#import "UIGestureRecognizerSubclass.h"
#import "UIGestureRecognizer+UIPrivate.h"

@implementation UIMultiTouchProcess
{
    UIWindow *_window;
    
    NSMutableSet *_touches;
    NSMutableSet *_effectRecognizers;
    NSMutableSet *_excludedRecognizers;
}

- (instancetype)init
{
    if (self = [super init]) {
        _touches = [NSMutableSet set];
        _effectRecognizers = [NSMutableSet set];
        _excludedRecognizers = [NSMutableSet set];
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

- (void)onBeganWithEvent:(UIEvent *)event
{
    NSSet *touches = [event touchesForWindow:_window];
    NSMutableSet *gestureRecognizers = [self _collectAllGestureRecognizersFromTouches:touches];
    [_effectRecognizers unionSet:gestureRecognizers];
}

- (NSMutableSet *)_collectAllGestureRecognizersFromTouches:(NSSet *)touches
{
    NSMutableSet *gestureRecognizers = [NSMutableSet setWithCapacity:0];
    
    for (UITouch *touch in touches) {
        [gestureRecognizers addObjectsFromArray:touch.gestureRecognizers];
    }
    return gestureRecognizers;
}

- (void)sendEvent:(UIEvent *)event
{
    NSSet *touches = [event touchesForWindow:_window];
    
    [self _collectNewTouches:touches];
    [self _sendGesturesForEvent:event touches:touches];
    [self _sendAttachedViewsForEvent:event touches:touches];
    [self _removeCancelledOrEndedTouches:touches];
}

- (void)_collectNewTouches:(NSSet *)touches
{
    for (UITouch *touch in touches) {
        if (touch.phase == UITouchPhaseBegan) {
            [_touches addObject:touch];
        }
    }
}

- (void)_removeCancelledOrEndedTouches:(NSSet *)touches
{
    for (UITouch *touch in touches) {
        if (touch.phase == UITouchPhaseEnded || touch.phase == UITouchPhaseCancelled) {
            [_touches removeObject:touch];
        }
    }
}

- (void)_sendGesturesForEvent:(UIEvent *)event touches:(NSSet *)touches
{
    [self _clearEffectRecognizerWhichBecomeDisabled];
    
    // before send event to recognizer, send pending actions
    [self _sendActionIfNeedForEachGestureRecognizers];
    
    // send event to effect gesture recognizers
    for (UIGestureRecognizer *recognizer in _effectRecognizers) {
        [recognizer _recognizeTouches:touches withEvent:event];
    }
    [self _checkAndClearExcluedRecognizers];
    
    if ([self _shouldSendsTouchCancelled]) {
        for (UITouch *touch in touches) {
            [touch.view touchesCancelled:touches withEvent:event];
        }
    }
    [self _sendActionIfNeedForEachGestureRecognizers];
}

- (void)_clearEffectRecognizerWhichBecomeDisabled
{
    NSMutableSet *disabled = [NSMutableSet set];
    for (UIGestureRecognizer *recognizer in _effectRecognizers) {
        if (!recognizer.isEnabled) {
            [disabled addObject:recognizer];
        }
    }
    [_effectRecognizers minusSet:disabled];
}

- (void)_checkAndClearExcluedRecognizers
{
    NSMutableSet *toRemove = [NSMutableSet set];
    
    for (UIGestureRecognizer *recognizer in _effectRecognizers) {
        
        if ([recognizer _isFailed]) {
            continue;
        }
        if ([self _isRecognizerExcluedByOther:recognizer]) {
            [recognizer _setExcluded];
            [toRemove addObject:recognizer];
        }
    }
    [_effectRecognizers minusSet:toRemove];
}

- (BOOL)_isRecognizerExcluedByOther:(UIGestureRecognizer *)recognizer
{
    for (UIGestureRecognizer *other in _effectRecognizers) {
        if (![other _isFailed] && [recognizer _isExcludedByGesture:other]) {
            return YES;
        }
    }
    return NO;
}

- (BOOL)_shouldSendsTouchCancelled
{
    for (UIGestureRecognizer *recognizer in _effectRecognizers) {
        if ([recognizer _shouldSendActions] &&
            [recognizer cancelsTouchesInView]) {
            return YES;
        }
    }
    return NO;
}

- (void)_sendActionIfNeedForEachGestureRecognizers
{
    for (UIGestureRecognizer *recognizer in _effectRecognizers) {
        if ([recognizer _shouldSendActions]) {
            [recognizer _sendActions];
        }
    }
}

- (void)_sendAttachedViewsForEvent:(UIEvent *)event touches:(NSSet *)sendedTouches
{
    NSMutableSet *touches = [sendedTouches mutableCopy];
    [self _removeEatenTouchesByGestureRecognizerFromTouches:touches];
    
    for (UITouch *touch in touches) {
        
        UIView *view = touch.view;
        const UITouchPhase phase = touch.phase;
        
        [self _printLogForTouchPhase:phase];
        
        if (phase == UITouchPhaseBegan) {
            [view touchesBegan:touches withEvent:event];
        } else if (phase == UITouchPhaseMoved) {
            [view touchesMoved:touches withEvent:event];
        } else if (phase == UITouchPhaseEnded) {
            [view touchesEnded:touches withEvent:event];
        } else if (phase == UITouchPhaseCancelled) {
            [view touchesCancelled:touches withEvent:event];
        } else {
            NSLog(@"Unknow touch phase:%ld",phase);
        }
    }
}

- (void)_removeEatenTouchesByGestureRecognizerFromTouches:(NSMutableSet *)touches
{
    NSMutableSet *eaten = [NSMutableSet set];
    for (UITouch *touch in touches) {
        for (UIGestureRecognizer *recognizer in _effectRecognizers) {
            if ([recognizer _isEatenTouche:touch]) {
                [eaten addObject:touch];
                break;
            }
        }
    }
    [touches minusSet:eaten];
}

- (void)_printLogForTouchPhase:(UITouchPhase)phase
{
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
}

- (void)onEnded
{
    NSLog(@"reset all gesture recognizer");
    
    //  reset
    for (UIGestureRecognizer *recognizer in _effectRecognizers) {
        [recognizer reset];
    }
    
    // reset exclued ges
    for (UIGestureRecognizer *recognizer in _excludedRecognizers) {
        [recognizer reset];
    }
}

@end
