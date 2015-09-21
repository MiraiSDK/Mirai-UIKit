//
//  UIGestureRecognizeProcess.m
//  UIKit
//
//  Created by TaoZeyu on 15/8/24.
//  Copyright (c) 2015年 Shanghai Tinynetwork Inc. All rights reserved.
//

#import "TNGestureRecognizeProcess.h"
#import "TNGestureRecognizerSimultaneouslyRelationship.h"
#import "TNGestureFailureRequirementRelationship.h"
#import "UIGestureRecognizer+UIPrivate.h"
#import "UIGestureRecognizerSubclass.h"
#import "UIResponder.h"
#import "UITouch+Private.h"

typedef BOOL (^CallbackAndCheckerMethod)(UIGestureRecognizer *recognizer, BOOL* requiredWasFialed);

@implementation TNGestureRecognizeProcess
{
    UIView *_view;
    TNMultiTouchProcess *_multiTouchProcess;
    
    TNGestureRecognizerSimultaneouslyRelationship *_effectRecognizersNode;
    TNGestureFailureRequirementRelationship *_failureRequirementNode;
    
    NSMutableSet *_trackingTouches;
    NSMutableSet *_ignoredTouches;
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

- (instancetype)initWithView:(UIView *)view multiTouchProcess:(TNMultiTouchProcess *)multiTouchProcess
{
    if (self = [self init]) {
        _view = view;
        _multiTouchProcess = multiTouchProcess;
        
        _anyRecognizersMakeConclusion = YES;
        _trackingTouches = [[NSMutableSet alloc] init];
        _ignoredTouches = [[NSMutableSet alloc] init];
        _effectRecognizersNode = [[TNGestureRecognizerSimultaneouslyRelationship alloc] initWithView:view
                                                                            gestureRecongizeProcess:self];
        _failureRequirementNode = [[TNGestureFailureRequirementRelationship alloc] initWithView:view];
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

- (BOOL)trackTouch:(UITouch *)touch
{
    if ([_trackingTouches containsObject:touch]) {
        return YES;
    } else if ([_ignoredTouches containsObject:touch]) {
        return NO;
    }
    
    if ([self _willIgnoreTouch:touch]) {
        [_ignoredTouches addObject:touch];
        return NO;
    } else {
        [_trackingTouches addObject:touch];
        _trackingTouchesArrayCache = nil;
        return YES;
    }
}

- (BOOL)_willIgnoreTouch:(UITouch *)touch
{
    UIGestureRecognizer *notIngoreRecognizer = [_effectRecognizersNode findGestureRecognizer:
    ^BOOL(UIGestureRecognizer *recognizer)
    {
        return ![recognizer _hasIgnoredTouch:touch];
    }];
    
    return notIngoreRecognizer == nil;
}

- (void)multiTouchBegin
{
    _lastTimeHasMakeConclusion = self.hasMakeConclusion;
    _anyRecognizersMakeConclusion = NO;
    _cancelsTouchesInView = NO;
}

- (void)recognizeEvent:(UIEvent *)event touches:(NSSet *)touches
{
    [self _clearEffectRecognizerWhichBecomeDisabled];
    [self _sendToRecognizersWithTouches:touches event:event];
    [self _clearAndHandleAllMadeConclusionGestureRecognizersWithTouches:touches event:event];
    [self _clearHasMadeConclusionRecongizers];
    [self _tellMultiTouchProcessMadeConclusionIfNeed];
}

- (void)_clearEffectRecognizerWhichBecomeDisabled
{
    [_effectRecognizersNode removeWithCondition:^BOOL(UIGestureRecognizer *recognizer) {
        return !recognizer.isEnabled;
    }];
}

- (void)_sendToRecognizersWithTouches:(NSSet *)touches event:(UIEvent *)event
{
    [_effectRecognizersNode eachGestureRecognizer:^(UIGestureRecognizer *recognizer) {
        [self _searchNewTouchFrom:touches andTellRecognizer:recognizer];
        [recognizer _recognizeTouches:touches withEvent:event];
    }];
}

- (void)_clearAndHandleAllMadeConclusionGestureRecognizersWithTouches:(NSSet *)touches
                                                                event:(UIEvent *)event
{
    [self _sendActionsAndForceFailForAllChangedStateRecongizerCache];
    [self _cancelsTouchesInViewIfNeedWithTouches:touches event:event];
    [self _handleAllChangedStateRecongizersIfTheyHasMadeConclusion];
    
    [_changedStateRecognizersCache removeAllObjects];
}

- (void)_sendActionsAndForceFailForAllChangedStateRecongizerCache
{
    // The code in loop will force fail some recognizers. It would make state of recognizers change.
    // Then, more and more recognizers will be inserted into _changedStateRecognizersCache.
    
    // So, I only iterate recognizers that in the initial _changedStateRecognizersCache.
    // The recognizers that inserted later are ban because of failure requirement.
    // It's OK to ignore them.
    
    NSArray *allRecognizers = [_changedStateRecognizersCache allObjects];
    
    for (UIGestureRecognizer *recognizer in allRecognizers) {
        if ([self _recognizerNotBanBecauseOfFailureRequirement:recognizer]) {
            [self _sendActionsForRecognizerAndItsRequireFailRecognizers:recognizer];
        }
    }
}

- (void)_cancelsTouchesInViewIfNeedWithTouches:(NSSet *)touches event:(UIEvent *)event
{
    for (UIGestureRecognizer *recognizer in _changedStateRecognizersCache) {
        if ([self _touchesWouldBeCancelledByRecognizer:recognizer]) {
            _cancelsTouchesInView = YES;
            break;
        }
    }
    
    if (_cancelsTouchesInView && _hasCallAttachedViewAnyMethod) {
        [self _sendToAttachedViewWithCancelledEvent:event touches:touches];
        _hasCallAttachedViewCancelledMethod = YES;
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

- (void)_handleAllChangedStateRecongizersIfTheyHasMadeConclusion
{
    for (UIGestureRecognizer *recognizer in _changedStateRecognizersCache) {
        if ([self _recognizerNotBanBecauseOfFailureRequirement:recognizer]) {
            [self _handleIfHasMadeConclusionForRecognizer:recognizer];
        }
    }
}

- (void)_clearHasMadeConclusionRecongizers
{
    [_effectRecognizersNode removeWithCondition:^BOOL(UIGestureRecognizer *recognizer) {
        return [recognizer _hasMadeConclusion];
    }];
}

- (void)_tellMultiTouchProcessMadeConclusionIfNeed
{
    if (self.hasMakeConclusion) {
        [_multiTouchProcess gestureRecognizeProcessMakeConclusion:self];
    }
}

- (void)_searchNewTouchFrom:(NSSet *)touches andTellRecognizer:(UIGestureRecognizer *)recognizer
{
    for (UITouch *touch in touches) {
        if (touch.phase == UITouchPhaseBegan) {
            [recognizer _foundNewTouch:touch];
        }
    }
}

- (BOOL)_isRecognizerExcluedByOther:(UIGestureRecognizer *)recognizer
{
    return nil != [_effectRecognizersNode findGestureRecognizer:^BOOL(UIGestureRecognizer *other) {
        return ![other _isFailed] && [recognizer _isExcludedByGesture:other];
    }];
}

- (BOOL)_recognizerNotBanBecauseOfFailureRequirement:(UIGestureRecognizer *)recognizer
{
    UIGestureRecognizer *requireToFailRecongizer = [recognizer _requireToFailRecognizer];
    return !requireToFailRecongizer || [requireToFailRecongizer _isFailed];
}

- (void)_sendActionsForRecognizerAndItsRequireFailRecognizers:(UIGestureRecognizer *)recognizer
{
    if ([recognizer _hasRecognizedGesture]) {
        [self _forceFailAllRecongizersRequireToFail:recognizer];
    }
    [self _sendActionForRecongizerAndItsFailureRequires:recognizer];
}

- (void)_handleIfHasMadeConclusionForRecognizer:(UIGestureRecognizer *)recognizer
{
    if ([recognizer _hasMadeConclusion]) {
        [self _callResetMethodForRecongizerAndItsFailureRequires:recognizer];
        _anyRecognizersMakeConclusion = YES;
    }
}

- (BOOL)_touchesWouldBeCancelledByRecognizer:(UIGestureRecognizer *)recognizer
{
    return [recognizer _hasRecognizedGesture] && [recognizer cancelsTouchesInView];
}

- (void)_forceFailAllRecongizersRequireToFail:(UIGestureRecognizer *)requireToFailRecongizer
{
    [_failureRequirementNode recursiveSearchFromRecongizer:requireToFailRecongizer
                                                  requires:^(UIGestureRecognizer * recognizer)
    {
        if (recognizer != requireToFailRecongizer) {
            [recognizer _forceFail];
        }
    }];
}

- (void)_sendActionForRecongizerAndItsFailureRequires:(UIGestureRecognizer *)recognizer
{
    BOOL (^conditionChecker)(UIGestureRecognizer *) = ^BOOL(UIGestureRecognizer *recognizer) {
        return [recognizer _isFailed];
    };
    
    void (^handler)(UIGestureRecognizer *) = ^(UIGestureRecognizer *recognizer) {
        if ([self _willSendActionsForRecognizer:recognizer]) {
            [self _chooseSimultaneouslyGroupAndForceFailOthersIfNeedWithRecognizer:recognizer];
            [recognizer _sendActions];
        }
    };
    
    [_failureRequirementNode recursiveSearchFromRecongizer:recognizer
                                        recursiveCondition:conditionChecker requires:handler];
}

- (BOOL)_willSendActionsForRecognizer:(UIGestureRecognizer *)recognizer
{
    return ![recognizer _isFailed] &&
           [recognizer _shouldSendActions] &&
           [_effectRecognizersNode canRecongizerBeHandledSimultaneously:recognizer];
}

- (void)_chooseSimultaneouslyGroupAndForceFailOthersIfNeedWithRecognizer:(UIGestureRecognizer *)recognizer
{
    if (![_effectRecognizersNode hasChoosedAnySimultaneouslyGroup]) {
        [_effectRecognizersNode chooseSimultaneouslyGroupWhoIncludes:recognizer];
        [_effectRecognizersNode eachGestureRecognizerThatNotChoosed:^(UIGestureRecognizer *recognizer) {
            [recognizer _forceFail];
        }];
    }
}

- (void)_callResetMethodForRecongizerAndItsFailureRequires:(UIGestureRecognizer *)recognizer
{
    [_failureRequirementNode recursiveSearchFromRecongizer:recognizer
                                                  requires:^(UIGestureRecognizer * recognizer)
    {
        if ([recognizer _shouldReset]) {
            [recognizer reset];
            [_effectRecognizersNode removeGestureRecognizer:recognizer];
        }
    }];
}

- (void)sendToAttachedViewIfNeedWithEvent:(UIEvent *)event touches:(NSSet *)touches
{
    if([self _needSendEventToAttachedView]) {
        [self _sendToAttachedViewWithEvent:event touches:touches];
    }
}

- (BOOL)_needSendEventToAttachedView
{
    return !_cancelsTouchesInView && !_hasCallAttachedViewCancelledMethod;
}

- (void)_runAndClearDelaysBufferedBlocksIfNeed
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
    return !_cancelsTouchesInView && self.hasMakeConclusion &&
           _delaysBufferedBlocks.count > 0 && !_hasCallAttachedViewCancelledMethod;
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
                           delays:[self _shouldDelaysBeganTouches]];
    
    if (!_delaysTouchesBegan && _lastTimeHasMakeConclusion) {
        [self _callAttachedViewMethod:@selector(touchesMoved:withEvent:)
                                event:event touches:touchesMovedSet phase:UITouchPhaseMoved delays:NO];
    }
    
    [self _callAttachedViewMethod:@selector(touchesEnded:withEvent:)
                            event:event touches:touchesEndedSet phase:UITouchPhaseEnded
                           delays:[self _shouldDelaysEndedTouches]];
    
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

- (BOOL)_shouldDelaysBeganTouches
{
    return _delaysTouchesBegan || !_lastTimeHasMakeConclusion;
}

- (BOOL)_shouldDelaysEndedTouches
{
    return _delaysTouchesBegan || _delaysTouchesEnded || !_lastTimeHasMakeConclusion;
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
    [self _runAndClearDelaysBufferedBlocksIfNeed];
    
    _trackingTouchesArrayCache = @[];
    [_trackingTouches removeAllObjects];
    [_ignoredTouches removeAllObjects];
}

- (void)gestureRecognizerChangedState:(UIGestureRecognizer *)getureRecognizer
{
    if (_multiTouchProcess.handingTouchEvent) {
        [_changedStateRecognizersCache addObject:getureRecognizer];
        return;
    }
    
    if ([self _recognizerNotBanBecauseOfFailureRequirement:getureRecognizer]) {
        [self _sendActionsForRecognizerAndItsRequireFailRecognizers:getureRecognizer];
        [self _handleIfHasMadeConclusionForRecognizer:getureRecognizer];
    }
    if ([self _touchesWouldBeCancelledByRecognizer:getureRecognizer]) {
        _cancelsTouchesInView = YES;
    }
    [self _tellMultiTouchProcessMadeConclusionIfNeed];
    
    if (!_multiTouchProcess.handingMultiTouchEvent) {
        [self _runAndClearDelaysBufferedBlocksIfNeed];
    }
}

@end
