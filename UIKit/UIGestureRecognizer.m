/*
 * Copyright (c) 2011, The Iconfactory. All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are met:
 *
 * 1. Redistributions of source code must retain the above copyright
 *    notice, this list of conditions and the following disclaimer.
 *
 * 2. Redistributions in binary form must reproduce the above copyright notice,
 *    this list of conditions and the following disclaimer in the documentation
 *    and/or other materials provided with the distribution.
 *
 * 3. Neither the name of The Iconfactory nor the names of its contributors may
 *    be used to endorse or promote products derived from this software without
 *    specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
 * ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
 * WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
 * DISCLAIMED. IN NO EVENT SHALL THE ICONFACTORY BE LIABLE FOR ANY DIRECT,
 * INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING,
 * BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
 * DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
 * LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE
 * OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF
 * ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

#import "UIGestureRecognizer+UIPrivate.h"
#import "UIGestureRecognizerSubclass.h"
#import "TNGestureRecognizeProcess.h"
#import "UITouch+Private.h"
#import "UIAction.h"
#import "UIApplication.h"
#import "UIView+UIPrivate.h"

@implementation UIGestureRecognizer
{
    BOOL _excluded;
    NSMutableSet *_excludedTouches;
    NSMutableSet *_ignoredTouches;
    BOOL _foredFailed;
    BOOL _shouldSendActions;
    BOOL _shouldReset;
    BOOL _preventByOtherGestureRecognizer;
    
    TNGestureRecognizeProcess *_bindingRecognizeProcess;
    UIGestureRecognizer *_requireToFailRecognizer;
}
@synthesize delegate=_delegate, cancelsTouchesInView=_cancelsTouchesInView;

@synthesize state=_state, enabled=_enabled, view=_view;

- (instancetype)init
{
    if (self = [super init]) {
        _state = UIGestureRecognizerStatePossible;
        _cancelsTouchesInView = YES;
        _delaysTouchesBegan = NO;
        _delaysTouchesEnded = YES;
        _enabled = YES;
        
        _registeredActions = [[NSMutableArray alloc] initWithCapacity:1];
        _excludedTouches = [[NSMutableSet alloc] initWithCapacity:1];
        _ignoredTouches = [[NSMutableSet alloc] initWithCapacity:1];
    }
    return self;
}

- (instancetype)initWithTarget:(id)target action:(SEL)action
{
    if ((self=[self init])) {
        [self addTarget:target action:action];
    }
    return self;
}

- (NSString *)_description
{
    NSMutableArray *actions = [NSMutableArray array];
    for (UIAction *actionRecord in _registeredActions) {
        [actions addObject:NSStringFromSelector(actionRecord.action)];
    }
    return [NSString stringWithFormat:@"%@(%@)", self.className, [actions componentsJoinedByString:@", "]];
}

- (void)_bindRecognizeProcess:(TNGestureRecognizeProcess *)recognizeProcess
{
    _bindingRecognizeProcess = recognizeProcess;
}

- (void)_unbindRecognizeProcess
{
    _bindingRecognizeProcess = nil;
    
    [self _resetMarkWhenUnbinding];
}

- (void)_resetMarkWhenUnbinding
{
    _preventByOtherGestureRecognizer = NO;
}

- (void)_setView:(UIView *)v
{
    [self reset];	// not sure about this, but it kinda makes sense
    _view = v;
}

- (void)setDelegate:(id<UIGestureRecognizerDelegate>)aDelegate
{
    if (aDelegate != _delegate) {
        _delegate = aDelegate;
        _delegateHas.shouldBegin = [_delegate respondsToSelector:@selector(gestureRecognizerShouldBegin:)];
        _delegateHas.shouldReceiveTouch = [_delegate respondsToSelector:@selector(gestureRecognizer:shouldReceiveTouch:)];
        _delegateHas.shouldRecognizeSimultaneouslyWithGestureRecognizer = [_delegate respondsToSelector:@selector(gestureRecognizer:shouldRecognizeSimultaneouslyWithGestureRecognizer:)];
    }
}

- (void)setDelaysTouchesBegan:(BOOL)delaysTouchesBegan
{
    _delaysTouchesBegan = delaysTouchesBegan;
    [self reset];
}

- (void)setDelaysTouchesEnded:(BOOL)delaysTouchesEnded
{
    _delaysTouchesEnded = delaysTouchesEnded;
    [self reset];
}

- (void)addTarget:(id)target action:(SEL)action
{
    NSAssert(target != nil, @"target must not be nil");
    NSAssert(action != NULL, @"action must not be NULL");
    
    UIAction *actionRecord = [[UIAction alloc] init];
    actionRecord.target = target;
    actionRecord.action = action;
    [_registeredActions addObject:actionRecord];
}

- (void)removeTarget:(id)target action:(SEL)action
{
    UIAction *actionRecord = [[UIAction alloc] init];
    actionRecord.target = target;
    actionRecord.action = action;
    [_registeredActions removeObject:actionRecord];
}

- (void)requireGestureRecognizerToFail:(UIGestureRecognizer *)otherGestureRecognizer
{
    _requireToFailRecognizer = otherGestureRecognizer;
}

- (UIGestureRecognizer *)_requireToFailRecognizer
{
    return _requireToFailRecognizer;
}

- (NSUInteger)numberOfTouches
{
    if (!_bindingRecognizeProcess) {
        return 0;
    }
    
    return _bindingRecognizeProcess.trackingTouches.count - _excludedTouches.count;
}

- (CGPoint)locationInView:(UIView *)view
{
    // by default, this should compute the centroid of all the involved points
    // of course as of this writing, Chameleon only supports one point but at least
    // it may be semi-correct if that ever changes. :D YAY FOR COMPLEXITY!
    
    CGFloat x = 0;
    CGFloat y = 0;
    CGFloat k = 0;
    
    if (_bindingRecognizeProcess) {
        for (UITouch *touch in _bindingRecognizeProcess.trackingTouches) {
            if (![_excludedTouches containsObject:touch]) {
                const CGPoint p = [touch locationInView:view];
                x += p.x;
                y += p.y;
                k++;
            }
        }
    }
    
    if (k > 0) {
        return CGPointMake(x/k, y/k);
    } else {
        return CGPointZero;
    }
}

- (CGPoint)locationOfTouch:(NSUInteger)touchIndex inView:(UIView *)view
{
    if (!_bindingRecognizeProcess) {
        return CGPointZero;
    }
    
    // Because the _bindingRecognizeProcess.trackingTouchesArray may includes exclued touches.
    
    NSUInteger index = 0;
    
    for (UITouch *touch in _bindingRecognizeProcess.trackingTouchesArray) {
        if (![_excludedTouches containsObject:touch]) {
            if (index == touchIndex) {
                return [touch locationInView:view];
            }
            index++;
        }
    }
    return CGPointZero;
}

- (void)setState:(UIGestureRecognizerState)state
{
    if (_foredFailed) {
        return;
    }
    // the docs didn't say explicitly if these state transitions were verified, but I suspect they are. if anything, a check like this
    // should help debug things. it also helps me better understand the whole thing, so it's not a total waste of time :)

    typedef struct {
        UIGestureRecognizerState fromState, toState;
        BOOL shouldNotify, shouldReset, checkPrevent;
    } StateTransition;

    #define NumberOfStateTransitions 9
    static const StateTransition allowedTransitions[NumberOfStateTransitions] = {
        // discrete gestures
        {UIGestureRecognizerStatePossible,		UIGestureRecognizerStateRecognized, YES,    YES,    YES},
        {UIGestureRecognizerStatePossible,		UIGestureRecognizerStateFailed,     NO,     YES,    NO},

        // continuous gestures
        {UIGestureRecognizerStatePossible,		UIGestureRecognizerStateBegan,      YES,    NO,     YES},
        {UIGestureRecognizerStateBegan,			UIGestureRecognizerStateChanged,    YES,    NO,     NO},
        {UIGestureRecognizerStateBegan,			UIGestureRecognizerStateCancelled,  YES,    YES,    NO},
        {UIGestureRecognizerStateBegan,			UIGestureRecognizerStateEnded,      YES,    YES,    NO},
        {UIGestureRecognizerStateChanged,		UIGestureRecognizerStateChanged,    YES,    NO,     NO},
        {UIGestureRecognizerStateChanged,		UIGestureRecognizerStateCancelled,  YES,    YES,    NO},
        {UIGestureRecognizerStateChanged,		UIGestureRecognizerStateEnded,      YES,    YES,    NO}
    };
    
    const StateTransition *transition = NULL;

    for (NSUInteger t=0; t<NumberOfStateTransitions; t++) {
        if (allowedTransitions[t].fromState == _state && allowedTransitions[t].toState == state) {
            transition = &allowedTransitions[t];
            break;
        }
    }

    NSAssert2((transition != NULL), @"invalid state transition from %d to %d", _state, state);
    UIGestureRecognizerState originalState = _state;
    
    
    if ([self _shouldBeginContinuesContinuityRecognizeWithState:state]) {
        
        [self _setExcluded];
        _state = UIGestureRecognizerStateFailed;
        _shouldSendActions = NO;
        _shouldReset = YES;
        
    } else if (transition) {
        
        if (transition->checkPrevent && [self _shouldBePrevent]) {
            _state = UIGestureRecognizerStateFailed;
            _shouldSendActions = NO;
            _shouldReset = YES;
            
        } else {
            if (transition->toState == UIGestureRecognizerStateFailed) {
            }
            _state = transition->toState;
            _shouldSendActions = transition->shouldNotify;
            _shouldReset = transition->shouldReset;
        }
        
    }
    
    if (originalState == UIGestureRecognizerStateChanged ||
        originalState != _state) {
        
        [_bindingRecognizeProcess gestureRecognizerChangedState:self];
    }
}

- (void)_forceFail
{
    UIGestureRecognizerState originalState = _state;
    
    if (!_foredFailed) {
        _state = UIGestureRecognizerStateFailed;
        _foredFailed = YES;
        _shouldSendActions = NO;
        _shouldReset = YES;
        
        if (originalState != UIGestureRecognizerStateFailed) {
            [_bindingRecognizeProcess gestureRecognizerChangedState:self];
        }
        [self _resetOtherPropertiesThatMustResetEachTime];
    }
}

- (void)_preventByOtherGestureRecognizer;
{
    _preventByOtherGestureRecognizer = YES;
}

- (BOOL)_hasBeenPreventedByOtherGestureRecognizer
{
    return _preventByOtherGestureRecognizer;
}

- (BOOL)_shouldBeginContinuesContinuityRecognizeWithState:(UIGestureRecognizerState)state
{
    if (_state == UIGestureRecognizerStatePossible) {
        return NO;
    }
    if (state != UIGestureRecognizerStateBegan &&
        state != UIGestureRecognizerStateEnded) {
        return NO;
    }
    return ![self _shouldBegan];
}

- (BOOL)_shouldBePrevent
{
    if (_preventByOtherGestureRecognizer) {
        return YES;
        
    } else if (_delegate && [_delegate respondsToSelector:@selector(gestureRecognizerShouldBegin:)]) {
        return ![_delegate gestureRecognizerShouldBegin:self];
    }
    return NO;
}

- (BOOL)_shouldBegan
{
    BOOL shouldBegan = YES;
    if (self.delegate && [self.delegate respondsToSelector:@selector(gestureRecognizerShouldBegin:)]) {
        shouldBegan = [self.delegate gestureRecognizerShouldBegin:self];
        
    }
    
    UIView *targetView = self.view;
    NSArray *views = targetView._allSubViews;
    
    if (shouldBegan) {
        for (UIView *v in views) {
            shouldBegan = [v gestureRecognizerShouldBegin:self];
            if (!shouldBegan) {
                break;
            }
        }
    }
    return shouldBegan;
}

- (void)_sendActions
{
    if (![self _isExcluded]) {
        for (UIAction *actionRecord in _registeredActions) {
            [actionRecord.target performSelector:actionRecord.action withObject:self];
        }
    }

    _shouldSendActions = NO;
}

- (void)reset
{
    _excluded = NO;
    _shouldReset = NO;
    _shouldSendActions = NO;
    _foredFailed = NO;
    _state = UIGestureRecognizerStatePossible;
    [self _resetOtherPropertiesThatMustResetEachTime];
}

- (void)_resetOtherPropertiesThatMustResetEachTime
{
    [_excludedTouches removeAllObjects];
    [_ignoredTouches removeAllObjects];
}

- (BOOL)canPreventGestureRecognizer:(UIGestureRecognizer *)preventedGestureRecognizer
{
    return YES;
}

- (BOOL)canBePreventedByGestureRecognizer:(UIGestureRecognizer *)preventingGestureRecognizer
{
    return YES;
}

- (BOOL)shouldRequireFailureOfGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    return NO;
}

- (BOOL)shouldBeRequiredToFailByGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    return NO;
}

- (void)ignoreTouch:(UITouch *)touch forEvent:(UIEvent*)event
{
    [_ignoredTouches addObject:touch];
}

- (BOOL)_hasIgnoredTouch:(UITouch *)touch
{
    return [_ignoredTouches containsObject:touch];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
}

- (void)_gesturesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
}

- (void)_gesturesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
}

- (void)_gesturesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
}

- (void)_discreteGestures:(NSSet *)touches withEvent:(UIEvent *)event
{
}

- (BOOL)_delegateCanPreventGestureRecognizer:(UIGestureRecognizer *)otherGesture
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(gestureRecognizer:shouldRecognizeSimultaneouslyWithGestureRecognizer:)]) {
        BOOL simultaneously = [self.delegate gestureRecognizer:self shouldRecognizeSimultaneouslyWithGestureRecognizer:otherGesture];
        return !simultaneously;
    }
    
    return NO;
}

- (BOOL)_isExcludedByGesture:(UIGestureRecognizer *)otherGesture
{
    if (self != otherGesture &&
        ![otherGesture _isExcluded] &&
        [otherGesture _isActivity] &&
        [otherGesture.view isDescendantOfView:self.view]) {
        
        BOOL canBePrevented = [self canBePreventedByGestureRecognizer:otherGesture];
        if (canBePrevented) {
            canBePrevented = [otherGesture canPreventGestureRecognizer:self];
        }
        
        if (canBePrevented && self.delegate) {
            canBePrevented = [self _delegateCanPreventGestureRecognizer:otherGesture];
        }
        
        if (canBePrevented && otherGesture.delegate) {
            canBePrevented = [otherGesture _delegateCanPreventGestureRecognizer:self];
        }
        
        return canBePrevented;
    }
    return NO;
}

- (BOOL)_isExcluded
{
    return _excluded;
}

- (void)_setExcluded
{
    _excluded = YES;
}

- (BOOL)_shouldSendActions
{
    return _shouldSendActions;
}

- (BOOL)_shouldReset
{
    return _shouldReset;
}

- (BOOL)_hasRecognizedGesture
{
    return _state == UIGestureRecognizerStateBegan ||
           _state == UIGestureRecognizerStateChanged ||
           _state == UIGestureRecognizerStateEnded;
}

- (BOOL)_hasMadeConclusion
{
    return _state == UIGestureRecognizerStateCancelled ||
           _state == UIGestureRecognizerStateEnded ||
           _state == UIGestureRecognizerStateFailed;
}

- (BOOL)_hasFinishedRecognizingProcess
{
    return _foredFailed || [self _hasMadeConclusion];
}

- (BOOL)_isFinishedRecognizing
{
    return _state == UIGestureRecognizerStateEnded;
}

- (BOOL)_isFailed
{
    return self.state == UIGestureRecognizerStateFailed;
}

- (BOOL)_canReceiveTouches
{
    return [self _shouldAttemptToRecognize];
}


- (BOOL)_isActivity
{
    switch (self.state) {
        case UIGestureRecognizerStateBegan:
        case UIGestureRecognizerStateChanged:
        case UIGestureRecognizerStateEnded:
            return YES;
            break;
            
        default:break;
    }
    return NO;
}

- (BOOL)_shouldAttemptToRecognize
{
    return (self.enabled &&
            self.state != UIGestureRecognizerStateFailed &&
            self.state != UIGestureRecognizerStateCancelled && 
            self.state != UIGestureRecognizerStateEnded);
}

- (void)_foundNewTouch:(UITouch *)touch
{
    if (!self.delegate) {
        return;
    }
    
    if (![_excludedTouches containsObject:touch] &&
        [_bindingRecognizeProcess.trackingTouches containsObject:touch]) {
        
        if (![self _shouldReciveTouch:touch]) {
            [_excludedTouches addObject:touch];
        }
    }
}

- (BOOL)_shouldReciveTouch:(UITouch *)touch
{
    if ([self.delegate respondsToSelector:@selector(gestureRecognizer:shouldReceiveTouch:)]) {
        return [self.delegate gestureRecognizer:self shouldReceiveTouch:touch];
    }
    return YES;
}

- (void)_recognizeTouches:(NSSet *)touches withEvent:(UIEvent *)event
{
    NSMutableSet *touchesBeginSet = nil;
    NSMutableSet *touchesMovedSet = nil;
    NSMutableSet *touchesEndedSet = nil;
    NSMutableSet *touchesCancelledSet = nil;
    
    for (UITouch *touch in touches) {
        
        if ([_bindingRecognizeProcess.trackingTouches containsObject:touch] &&
            ![_excludedTouches containsObject:touch]) {
            
            switch (touch.phase) {
                case UITouchPhaseBegan:
                    [self _setTouch:touch intoMutableSet:&touchesBeginSet];
                    break;
                    
                case UITouchPhaseMoved:
                    [self _setTouch:touch intoMutableSet:&touchesMovedSet];
                    break;
                    
                case UITouchPhaseEnded:
                    [self _setTouch:touch intoMutableSet:&touchesEndedSet];
                    break;
                    
                case UITouchPhaseCancelled:
                    [self _setTouch:touch intoMutableSet:&touchesCancelledSet];
                    break;
                    
                default:
                    break;
            }
        }
    }
    
    if (touchesBeginSet) {
        [self touchesBegan:touchesBeginSet withEvent:event];
    }
    
    if (touchesMovedSet) {
        [self touchesMoved:touchesMovedSet withEvent:event];
    }
    
    if (touchesEndedSet) {
        [self touchesEnded:touchesEndedSet withEvent:event];
    }
    
    if (touchesCancelledSet) {
        [self touchesCancelled:touchesCancelledSet withEvent:event];
    }
}

- (void)_setTouch:(UITouch *)touch intoMutableSet:(NSMutableSet **)set
{
    if (!*set) {
        *set = [[NSMutableSet alloc] init];
    }
    [*set addObject:touch];
}

- (NSString *)description
{
    NSString *state = @"";
    switch (self.state) {
        case UIGestureRecognizerStatePossible:
            state = @"Possible";
            break;
        case UIGestureRecognizerStateBegan:
            state = @"Began";
            break;
        case UIGestureRecognizerStateChanged:
            state = @"Changed";
            break;
        case UIGestureRecognizerStateEnded:
            state = @"Ended";
            break;
        case UIGestureRecognizerStateCancelled:
            state = @"Cancelled";
            break;
        case UIGestureRecognizerStateFailed:
            state = @"Failed";
            break;
    }
    return [NSString stringWithFormat:@"<%@: %p; state = %@; view = %@>", [self className], self, state, self.view];
}

@end
