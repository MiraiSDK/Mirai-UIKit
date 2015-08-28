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
#import "UITouch+Private.h"

@implementation UIGestureRecognizeProcess
{
    UIView *_view;
    NSMutableSet *_trackingTouches;
    NSMutableSet *_effectRecognizers;
    NSMutableArray *_delaysBufferedBlocks;
    
    NSArray *_trackingTouchesArrayCache;
    
    BOOL _delaysTouchesBegan;
    BOOL _delaysTouchesEnded;
    
    BOOL _lastTimeHasMakeConclusion;
    BOOL _hasCallAttachedViewCancelledMethod;
    BOOL _hasCallAttachedViewAnyMethod;
}

- (instancetype)initWithView:(UIView *)view
{
    if (self = [self init]) {
        _view = view;
        _lastTimeHasMakeConclusion = YES;
        _trackingTouches = [[NSMutableSet alloc] init];
        _effectRecognizers = [[NSMutableSet alloc] initWithArray:[view gestureRecognizers]];
        _delaysBufferedBlocks = [[NSMutableArray alloc] init];
        
        //UIGestureRecognizer's delaysTouchesXXX may be changed, so I cached them when called init method.
        _delaysTouchesBegan = [self _anyGestureRecognizerWillDelaysProperty:@"delaysTouchesBegan"];
        _delaysTouchesEnded = [self _anyGestureRecognizerWillDelaysProperty:@"delaysTouchesEnded"];
    }
    NSLog(@"generate UIGestureRecognizeProcess view - %@", _view.className);
    
    return self;
}

- (BOOL)_anyGestureRecognizerWillDelaysProperty:(NSString *)property
{
    for (UIGestureRecognizer *recognizer in _effectRecognizers) {
        NSNumber *propertyNumber = [recognizer valueForKey:property];
        if ([propertyNumber boolValue]) {
            return YES;
        }
    }
    return NO;
}

- (UIView *)view
{
    return _view;
}

- (BOOL)hasMakeConclusion
{
    return _lastTimeHasMakeConclusion;
}

- (NSSet *)trackingTouches
{
    return _trackingTouches;
}

- (NSArray *)gestureRecognizers
{
    return [_effectRecognizers allObjects];
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

- (void)sendToAttachedViewIfNeedWithEvent:(UIEvent *)event touches:(NSSet *)touches
{
    if ([self _needSendEventToAttachedView]) {
        
        if ([self _anyRecognizerRecognizedCancelsTouchesInView]) {
            
            if (_delaysTouchesBegan) {
                [self _runAndClearDelaysBufferedBlocks];
                
            } else {
                if ([self _needCallAttachedViewCancelledMethod]) {
                    [self _sendToAttachedViewWithCancelledEvent:event touches:touches];
                    _hasCallAttachedViewCancelledMethod = YES;
                }
            }
        } else {
            [self _sendToAttachedViewWithEvent:event touches:touches];
            _hasCallAttachedViewAnyMethod = YES;
        }
    }
}

- (BOOL)_needSendEventToAttachedView
{
    return _lastTimeHasMakeConclusion;
}

- (BOOL)_needCallAttachedViewCancelledMethod
{
    return _hasCallAttachedViewAnyMethod && !_hasCallAttachedViewCancelledMethod;
}

- (BOOL)_anyRecognizerRecognizedCancelsTouchesInView
{
    for (UIGestureRecognizer *recognizer in _effectRecognizers) {
        
        if ([recognizer cancelsTouchesInView]) {
            return recognizer.state == UIGestureRecognizerStateBegan ||
                   recognizer.state == UIGestureRecognizerStateChanged ||
                   recognizer.state == UIGestureRecognizerStateEnded;
        }
    }
    return NO;
}

- (void)_runAndClearDelaysBufferedBlocks
{
    if (_delaysBufferedBlocks.count > 0) {
        for (void (^block)(void) in _delaysBufferedBlocks) {
            block();
        }
        [_delaysBufferedBlocks removeAllObjects];
    }
}

- (void)_sendToAttachedViewWithCancelledEvent:(UIEvent *)event touches:(NSSet *)touches
{
    for (UITouch *touch in touches) {
        [touch _setOnlyShowPhaseAsCancelled:YES];
    }
    
    [_view touchesCancelled:touches withEvent:event];
    
    for (UITouch *touch in touches) {
        [touch _setOnlyShowPhaseAsCancelled:NO];
    }
}

- (void)_sendToAttachedViewWithEvent:(UIEvent *)event touches:(NSSet *)touches
{
    NSMutableSet *touchesBeganSet = nil;
    NSMutableSet *touchesMovedSet = nil;
    NSMutableSet *touchesEndedSet = nil;
    
    for (UITouch *touch in touches) {
        if ([self _willHandleAndSendThisTouche:touch]) {
            
            UITouchPhase phase = touch.phase;
            
            if (phase == UITouchPhaseBegan) {
                [self _setTouch:touch intoMutableSet:&touchesBeganSet];
                
            } else if (phase == UITouchPhaseMoved) {
                [self _setTouch:touch intoMutableSet:&touchesMovedSet];
                
            } else if (phase == UITouchPhaseEnded) {
                [self _setTouch:touch intoMutableSet:&touchesEndedSet];
            }
        }
    }
    
    [self _callAttachedViewMethod:@selector(touchesBegan:withEvent:)
                            event:event touches:touchesBeganSet phase:UITouchPhaseBegan
                           delays:_delaysTouchesBegan];
    
    if (!_delaysTouchesBegan) {
        [self _callAttachedViewMethod:@selector(touchesMoved:withEvent:)
                                event:event touches:touchesMovedSet phase:UITouchPhaseMoved delays:NO];
    }
    
    [self _callAttachedViewMethod:@selector(touchesEnded:withEvent:)
                            event:event touches:touchesEndedSet phase:UITouchPhaseEnded
                           delays:_delaysTouchesBegan || _delaysTouchesEnded];
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
                          phase:(UITouchPhase)phase delays:(BOOL)delays
{
    if (touches) {
        [self _printLogForTouchPhase:phase];
        
        for (UITouch *touch in touches) {
            NSSet *wrapTouch = [[NSSet alloc] initWithObjects:touch, nil];
            
            if (delays) {
                [_delaysBufferedBlocks addObject:^{
                    [_view performSelector:callbackMethod withObject:wrapTouch withObject:event];
                }];
            } else {
                [_view performSelector:callbackMethod withObject:wrapTouch withObject:event];
            }
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
    [self _runAndClearDelaysBufferedBlocks];
    [self _clearAndCallResetIfRecognizersMakeConclusion];
    
    [_trackingTouches removeAllObjects];
    
    _trackingTouchesArrayCache = @[];
    _lastTimeHasMakeConclusion = _effectRecognizers.count == 0;
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
