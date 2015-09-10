//
//  UIGestureRecognizeProcess.m
//  UIKit
//
//  Created by TaoZeyu on 15/8/24.
//  Copyright (c) 2015年 Shanghai Tinynetwork Inc. All rights reserved.
//

#import "UIGestureRecognizeProcess.h"
#import "UIGestureRecognizerSimultaneouslyGroup.h"
#import "UIGestureRecognizer+UIPrivate.h"
#import "UIGestureRecognizerSubclass.h"
#import "UIResponder.h"
#import "UITouch+Private.h"

@implementation UIGestureRecognizeProcess
{
    UIView *_view;
    UIMultiTouchProcess *_multiTouchProcess;
    
    UIGestureRecognizerSimultaneouslyGroup *_effectRecognizersNode;
    NSMutableSet *_banSimultaneouslyGroups;
    
    NSMutableSet *_trackingTouches;
    NSMutableSet *_changedStateRecognizersCache;
    NSMutableArray *_delaysBufferedBlocks;
    
    NSArray *_trackingTouchesArrayCache;
    
    BOOL _delaysTouchesBegan;
    BOOL _delaysTouchesEnded;
    
    BOOL _lastTimeHasMakeConclusion;
    BOOL _anyRecognizersMakeConclusion;
    BOOL _hasCallAttachedViewCancelledMethod;
    BOOL _hasCallAttachedViewAnyMethod;
    
    BOOL _cancelsTouchesInView;
}

- (instancetype)initWithView:(UIView *)view multiTouchProcess:(UIMultiTouchProcess *)multiTouchProcess
{
    if (self = [self init]) {
        _view = view;
        _multiTouchProcess = multiTouchProcess;
        
        _anyRecognizersMakeConclusion = YES;
        _banSimultaneouslyGroups = [[NSMutableSet alloc] init];
        _trackingTouches = [[NSMutableSet alloc] init];
        _effectRecognizersNode = [[UIGestureRecognizerSimultaneouslyGroup alloc] initWithView:view];
        _changedStateRecognizersCache = [[NSMutableSet alloc] init];
        _delaysBufferedBlocks = [[NSMutableArray alloc] init];
        
        //UIGestureRecognizer's delaysTouchesXXX may be changed, so I cached them when called init method.
        _delaysTouchesBegan = [self _anyGestureRecognizerWillDelaysProperty:@"delaysTouchesBegan"];
        _delaysTouchesEnded = [self _anyGestureRecognizerWillDelaysProperty:@"delaysTouchesEnded"];
    }
    NSLog(@"generate UIGestureRecognizeProcess [%@] includes %li gesture recognizers.",
          _view.className, _effectRecognizersNode.count);
    
    return self;
}

- (BOOL)_anyGestureRecognizerWillDelaysProperty:(NSString *)property
{
    return nil != [_effectRecognizersNode findGestureRecognizer:^BOOL(UIGestureRecognizer *recognizer) {
        return [[recognizer valueForKey:property] boolValue];
    }];
}

- (UIView *)view
{
    return _view;
}

- (BOOL)hasMakeConclusion
{
    return _anyRecognizersMakeConclusion || _effectRecognizersNode.count == 0;
}

- (NSSet *)trackingTouches
{
    return _trackingTouches;
}

- (NSArray *)gestureRecognizers
{
    return [_effectRecognizersNode allGestureRecognizers];
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
    [_effectRecognizersNode eachGestureRecognizer:^(UIGestureRecognizer *recognizer) {
        [recognizer _bindRecognizeProcess:self];
    }];
    _lastTimeHasMakeConclusion = self.hasMakeConclusion;
    _anyRecognizersMakeConclusion = NO;
    _cancelsTouchesInView = NO;
}

- (void)recognizeEvent:(UIEvent *)event touches:(NSSet *)touches
{
    [self _clearEffectRecognizerWhichBecomeDisabled];
    // before send event to recognizer, send pending actions
    [self _sendActionIfNeedForEachGestureRecognizers];
    [self _sendToRecognizersWithTouches:touches event:event];
    [self _checkAndClearExcluedRecognizers];
    [self _clearAndHandleAllMadeConclusionGestureRecognizers];
}

- (void)_clearEffectRecognizerWhichBecomeDisabled
{
    [self _removeEffectGestureRecognizersWithCondition:^BOOL(UIGestureRecognizer *recognizer) {
        
        return !recognizer.isEnabled;
    }];
}

- (void)_sendActionIfNeedForEachGestureRecognizers
{
    [_effectRecognizersNode eachGestureRecognizer:^(UIGestureRecognizer *recognizer) {
        if (![recognizer _isFailed] && [recognizer _shouldSendActions]) {
            [recognizer _sendActions];
        }
    }];
}

- (void)_sendToRecognizersWithTouches:(NSSet *)touches event:(UIEvent *)event
{
    for (NSSet *group in [_effectRecognizersNode allSimulataneouslyGroups]) {
        
        if ([_banSimultaneouslyGroups containsObject:group]) {
            continue;
        }
        
        BOOL allFail = YES;
        for (UIGestureRecognizer *recognizer in group) {
            [self _sendTouches:touches event:event toRecognizer:recognizer];
            if (![recognizer _isFailed]) {
                allFail = NO;
            }
        }
        
        if (allFail) {
            [_banSimultaneouslyGroups addObject:group];
        } else {
            break;
        }
    }
}

- (void)_sendTouches:(NSSet *)touches event:(UIEvent *)event
        toRecognizer:(UIGestureRecognizer *)recognizer
{
    [self _searchNewTouchFrom:touches andTellRecognizer:recognizer];
    [recognizer _recognizeTouches:touches withEvent:event];
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
    [self _removeEffectGestureRecognizersWithCondition:^BOOL(UIGestureRecognizer *recognizer) {
        
        return [self _isRecognizerExcluedByOther:recognizer];
    }];
}

- (BOOL)_isRecognizerExcluedByOther:(UIGestureRecognizer *)recognizer
{
    return nil != [_effectRecognizersNode findGestureRecognizer:^BOOL(UIGestureRecognizer *other) {
        return ![other _isFailed] && [recognizer _isExcludedByGesture:other];
    }];
}

- (void)_handleChangedStateGestureRecognizer:(UIGestureRecognizer *)recognizer
{
    // the next line is a recursion invoking.
    // but UIGestureRecognizer requireGestureRecognizerToFail relationship may have Ring in them.
    // Ring will make a death-recursion invoking.
    // So, I make a exceptSet to exclude duplicated UIGestureRecognizer objects.
    NSMutableSet *exceptSet = [NSMutableSet set];
    
    [self _handleChangedStateGestureRecognizer:recognizer exceptSet:exceptSet];
}

- (void)_handleChangedStateGestureRecognizer:(UIGestureRecognizer *)recognizer
                                   exceptSet:(NSMutableSet *)exceptSet
{
    if ([exceptSet containsObject:recognizer]) {
        return;
    }
    [exceptSet addObject:recognizer];
    
    [self _handleResultThroughStateOfGestureRecognozer:recognizer];
    
    if ([recognizer _isFailed]) {
        for (UIGestureRecognizer *afterFailRecognizer in [recognizer _recognizersWhoRequireThisToFail]) {
            [self _handleChangedStateGestureRecognizer:afterFailRecognizer exceptSet:exceptSet];
        }
    }
}

- (void)_handleResultThroughStateOfGestureRecognozer:(UIGestureRecognizer *)recognizer
{
    if (![recognizer _isFailed] &&
        [recognizer _shouldSendActions]) {
        
        [recognizer _sendActions];
    }
    
    if ([recognizer _hasRecognizedGesture] && [recognizer cancelsTouchesInView]) {
        _cancelsTouchesInView = YES;
    }
    
    if ([recognizer _hasMadeConclusion]) {
        [recognizer reset];
        _anyRecognizersMakeConclusion = YES;
    }
}

- (void)sendToAttachedViewIfNeedWithEvent:(UIEvent *)event touches:(NSSet *)touches
{
    if ([self _needSendEventToAttachedView]) {
        
        if (_cancelsTouchesInView) {
            if ([self _needCallAttachedViewCancelledMethod]) {
                [self _sendToAttachedViewWithCancelledEvent:event touches:touches];
                _hasCallAttachedViewCancelledMethod = YES;
                [_delaysBufferedBlocks removeAllObjects];
            }
        } else {
            [self _sendToAttachedViewWithEvent:event touches:touches];
        }
    }
}

- (BOOL)_needSendEventToAttachedView
{
    return _lastTimeHasMakeConclusion && !_hasCallAttachedViewCancelledMethod;
}

- (BOOL)_needCallAttachedViewCancelledMethod
{
    return _hasCallAttachedViewAnyMethod;
}

- (void)_runAndClearDelaysBufferedBlocks
{
    if ([self _needToRunDelaysBlockedBlocks]) {
        for (void (^block)(void) in _delaysBufferedBlocks) {
            block();
        }
        [_delaysBufferedBlocks removeAllObjects];
    }
}

- (BOOL)_needToRunDelaysBlockedBlocks
{
    return _delaysBufferedBlocks.count > 0 && !_hasCallAttachedViewCancelledMethod;
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
                            event:event touches:touchesBeganSet phase:UITouchPhaseBegan
                           delays:_delaysTouchesBegan];
    
    if (!_delaysTouchesBegan) {
        [self _callAttachedViewMethod:@selector(touchesMoved:withEvent:)
                                event:event touches:touchesMovedSet phase:UITouchPhaseMoved delays:NO];
    }
    
    [self _callAttachedViewMethod:@selector(touchesEnded:withEvent:)
                            event:event touches:touchesEndedSet phase:UITouchPhaseEnded
                           delays:_delaysTouchesBegan || _delaysTouchesEnded];
    
    [self _callAttachedViewMethod:@selector(touchesCancelled:withEvent:)
                            event:event touches:touchesCancelledSet
                            phase:UITouchPhaseCancelled delays:NO];
    
    if (touchesCancelledSet && touchesCancelledSet.count > 0) {
        _hasCallAttachedViewCancelledMethod = YES;
        [_delaysBufferedBlocks removeAllObjects];
    }
}

- (BOOL)_willHandleAndSendThisTouche:(UITouch *)touch
{
    return [_trackingTouches containsObject:touch];
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
                _hasCallAttachedViewAnyMethod = YES;
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
    
//    NSLog(@"phase:%@",[map objectForKey:@(phase)]);
}

- (void)multiTouchEnd
{
    if (!_cancelsTouchesInView) {
        [self _runAndClearDelaysBufferedBlocks];
    }
    _trackingTouchesArrayCache = @[];
    
    [_trackingTouches removeAllObjects];
}

- (void)_removeEffectGestureRecognizersWithCondition:(BOOL(^)(UIGestureRecognizer *recognizer))condition
{
    [_effectRecognizersNode removeWithCondition:^BOOL(UIGestureRecognizer *recognizer) {
        if (condition(recognizer)) {
            [recognizer _unbindRecognizeProcess];
            return YES;
        }
        return NO;
    }];
    
    if (_effectRecognizersNode.count == 0) {
        [_multiTouchProcess gestureRecognizeProcessMakeConclusion:self];
    }
}

- (void)gestureRecognizerChangedState:(UIGestureRecognizer *)getureRecognizer
{
    if (![getureRecognizer _requireToFailRecognizer] ||
        [[getureRecognizer _requireToFailRecognizer] _isFailed]) {
        
        if (_multiTouchProcess.handingTouchEvent) {
            [_changedStateRecognizersCache addObject:getureRecognizer];
            
        } else {
            [self _handleChangedStateGestureRecognizer:getureRecognizer];
            [self _tellMultiTouchProcessMadeConclusionIfNeed];
        }
    }
}

- (void)_clearAndHandleAllMadeConclusionGestureRecognizers
{
    for (UIGestureRecognizer *recognizer in _changedStateRecognizersCache) {
        [self _handleChangedStateGestureRecognizer:recognizer];
    }
    [_changedStateRecognizersCache removeAllObjects];
    [self _tellMultiTouchProcessMadeConclusionIfNeed];
}

- (void)_tellMultiTouchProcessMadeConclusionIfNeed
{
    if (self.hasMakeConclusion) {
        [_multiTouchProcess gestureRecognizeProcessMakeConclusion:self];
    }
}

@end
