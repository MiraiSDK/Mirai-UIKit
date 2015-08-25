//
//  UIGestureRecognizeProcess.m
//  UIKit
//
//  Created by TaoZeyu on 15/8/24.
//  Copyright (c) 2015年 Shanghai Tinynetwork Inc. All rights reserved.
//

#import "UIGestureRecognizeProcess.h"
#import "UIGestureRecognizer+UIPrivate.h"
#import "UIGestureRecognizerSubclass.h"
#import "UIResponder.h"

@implementation UIGestureRecognizeProcess
{
    UIView *_view;
    NSMutableSet *_trackingTouches;
    NSMutableSet *_effectRecognizers;
    
    NSArray *_trackingTouchesArrayCache;
}

- (instancetype) initWithView:(UIView *)view
{
    if (self = [self init]) {
        _view = view;
        _trackingTouches = [[NSMutableSet alloc] init];
        _effectRecognizers = [[NSMutableSet alloc] initWithArray:[view gestureRecognizers]];
    }
    return self;
}

- (UIView *)view
{
    return _view;
}

- (BOOL)hasMakeConclusion
{
    return _effectRecognizers.count > 0;
}

- (NSSet *)trackingTouches
{
    return _trackingTouches;
}

- (NSArray *)trackingTouchesArray
{
    static NSArray *descriptors;
    
    if (!descriptors) {
        descriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"timestamp" ascending:YES]];
    }
    
    if (!_trackingTouchesArrayCache) {
        _trackingTouchesArrayCache = [_trackingTouches sortedArrayUsingDescriptors:descriptors];
    }
    return _trackingTouchesArrayCache;
}

+ (BOOL)canViewCatchTouches:(UIView *)view
{
    return [self _hasRegisteredAnyGestureRecognizer:view] ||
           [self _hasImplementTouchBeganMethod:view.class];
}

+ (BOOL)_hasRegisteredAnyGestureRecognizer:(UIView *)view
{
    return view.gestureRecognizers.count > 0;
}

+ (BOOL)_hasImplementTouchBeganMethod:(Class)clazz
{
    IMP checkedMethod = [clazz instanceMethodForSelector:@selector(touchesBegan:withEvent:)];
    IMP oringinalMethod = [UIResponder instanceMethodForSelector:@selector(touchesBegan:withEvent:)];
    
    return oringinalMethod != checkedMethod;
}

- (void)trackTouch:(UITouch *)touch
{
    [_trackingTouches addObject:touch];
    _trackingTouchesArrayCache = nil;
}

- (void)multiTouchBegin
{
    for (UIGestureRecognizer *recognizer in _effectRecognizers) {
        [recognizer _bindRecognizeProcess:self];
    }
}

- (void)recognizeEvent:(UIEvent *)event touches:(NSSet *)touches
{
    [self _clearEffectRecognizerWhichBecomeDisabled];
    
    // before send event to recognizer, send pending actions
    [self _sendActionIfNeedForEachGestureRecognizers];
    
    // send event to effect gesture recognizers
    for (UIGestureRecognizer *recognizer in _effectRecognizers) {
        if ([recognizer _shouldAttemptToRecognize]) {
            [self _searchNewTouchFrom:touches andTellRecognizer:recognizer];
            [recognizer _recognizeTouches:touches withEvent:event];
        }
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
    [self _removeEffectGestureRecognizersWithCondition:^BOOL(UIGestureRecognizer *recognizer) {
        
        return !recognizer.isEnabled;
    }];
}

- (void)_searchNewTouchFrom:(NSSet *)touches andTellRecognizer:(UIGestureRecognizer *)recognizer
{
    for (UITouch *touch in touches) {
        if (touch.phase == UITouchPhaseBegan) {
            [recognizer _foundNewTouch:touch];
        }
    }
}

- (void)_checkAndClearExcluedRecognizers
{
    
    // [NSPredicate predicateWithBlock:] didn't implemented.
    // I can only replace with another way.
    
//    static NSPredicate *predicate;
//    
//    if (!predicate) {
//        predicate = [NSPredicate predicateWithBlock:^BOOL(UIGestureRecognizer *recognizer, NSDictionary *bindings) {
//            
//            NSLog(@"=> call filter block");
//            
//            if ([recognizer _isFailed]) {
//                return YES;
//            }
//            
//            if ([self _isRecognizerExcluedByOther:recognizer]) {
//                [recognizer _setExcluded];
//                return NO;
//            }
//            return YES;
//        }];
//    }
//    
//    [_effectRecognizers filterUsingPredicate:predicate];
    
    [self _removeEffectGestureRecognizersWithCondition:^BOOL(UIGestureRecognizer *recognizer) {
        
        return [recognizer _isFailed] || [self _isRecognizerExcluedByOther:recognizer];
    }];
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

- (void)_sendActionIfNeedForEachGestureRecognizers
{
    for (UIGestureRecognizer *recognizer in _effectRecognizers) {
        if ([recognizer _shouldSendActions]) {
            [recognizer _sendActions];
        }
    }
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

- (void)sendToAttachedViewIfNeedWithEvent:(UIEvent *)event touches:(NSSet *)touches
{
    NSMutableSet *touchesBeganSet = nil;
    NSMutableSet *touchesMovedSet = nil;
    NSMutableSet *touchesEndedSet = nil;
    NSMutableSet *touchesCancelledSet = nil;
    
    for (UITouch *touch in touches) {
        if ([self _willHandleAndSendThisTouche:touch]) {
            
            UITouchPhase phase = touch.phase;
            
            if (phase == UITouchPhaseBegan) {
                [self _setTouch:touch intoMutableSet:&touchesBeganSet];
                
            } else if (phase == UITouchPhaseMoved) {
                [self _setTouch:touch intoMutableSet:&touchesMovedSet];
                
            } else if (phase == UITouchPhaseEnded) {
                [self _setTouch:touch intoMutableSet:&touchesEndedSet];
                
            } else if (phase == UITouchPhaseCancelled) {
                [self _setTouch:touch intoMutableSet:&touchesCancelledSet];
            }
        }
    }
    
    [self _callAttachedViewMethod:@selector(touchesBegan:withEvent:)
                            event:event touches:touchesBeganSet phase:UITouchPhaseBegan];
    
    [self _callAttachedViewMethod:@selector(touchesMoved:withEvent:)
                            event:event touches:touchesMovedSet phase:UITouchPhaseMoved];
    
    [self _callAttachedViewMethod:@selector(touchesEnded:withEvent:)
                            event:event touches:touchesEndedSet phase:UITouchPhaseEnded];
    
    [self _callAttachedViewMethod:@selector(touchesCancelled:withEvent:)
                            event:event touches:touchesCancelledSet phase:UITouchPhaseCancelled];
    
}

- (BOOL)_willHandleAndSendThisTouche:(UITouch *)touch
{
    if (![_trackingTouches containsObject:touch]) {
        return NO;
    }
    
//    for (UIGestureRecognizer *recognizer in _effectRecognizers) {
//        if ([recognizer _isEatenTouche:touch]) {
//            return NO;
//        }
//    }
    
    return YES;
}

- (void)_setTouch:(UITouch *)touch intoMutableSet:(NSMutableSet **)set
{
    if (!*set) {
        *set = [[NSMutableSet alloc] init];
    }
    [*set addObject:touch];
}

- (void)_callAttachedViewMethod:(SEL)callbackMethod
                          event:(UIEvent *)event touches:(NSMutableSet *)touches
                          phase:(UITouchPhase)phase
{
    if (touches) {
        [self _printLogForTouchPhase:phase];
        
        for (UITouch *touch in touches) {
            NSSet *wrapTouch = [[NSSet alloc] initWithObjects:touch, nil];
            [_view performSelector:callbackMethod withObject:wrapTouch withObject:event];
        }
    }
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

- (void)multiTouchEnd
{
    [self _clearAndCallResetIfRecognizersMakeConclusion];
    
    [_trackingTouches removeAllObjects];
    _trackingTouchesArrayCache = @[];
}

- (void)_clearAndCallResetIfRecognizersMakeConclusion
{
    [self _removeEffectGestureRecognizersWithCondition:^BOOL(UIGestureRecognizer *recognizer) {
        
        UIGestureRecognizerState state = recognizer.state;
        
        if (state == UIGestureRecognizerStateCancelled ||
            state == UIGestureRecognizerStateEnded ||
            state == UIGestureRecognizerStateFailed) {
            
            [recognizer reset];
            
            return YES;
        }
        return NO;
        
        [recognizer reset];
        
        return YES;
    }];
}

- (void)_removeEffectGestureRecognizersWithCondition:(BOOL(^)(UIGestureRecognizer *recognizer))condition
{
    NSMutableSet *toRemove = [NSMutableSet new];
    
    for (UIGestureRecognizer *recognizer in _effectRecognizers) {
        if (condition(recognizer)) {
            [recognizer _unbindRecognizeProcess];
            [toRemove addObject:recognizer];
        }
    }
    [_effectRecognizers minusSet:toRemove];
}

@end
