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

#import "UIGestureRecognizer.h"
#import "UIGestureRecognizerSubclass.h"
#import "UITouch+Private.h"
#import "UIAction.h"
#import "UIApplication.h"
#import "UIView+UIPrivate.h"

@implementation UIGestureRecognizer
{
    BOOL _excluded;
    NSMutableSet *_excludedTouches;
    BOOL _shouldSendActions;
    BOOL _shouldReset;
}
@synthesize delegate=_delegate, delaysTouchesBegan=_delaysTouchesBegan, delaysTouchesEnded=_delaysTouchesEnded, cancelsTouchesInView=_cancelsTouchesInView;
@synthesize state=_state, enabled=_enabled, view=_view;

- (id)initWithTarget:(id)target action:(SEL)action
{
    if ((self=[super init])) {
        _state = UIGestureRecognizerStatePossible;
        _cancelsTouchesInView = YES;
        _delaysTouchesBegan = NO;
        _delaysTouchesEnded = YES;
        _enabled = YES;

        _registeredActions = [[NSMutableArray alloc] initWithCapacity:1];
        _trackingTouches = [[NSMutableArray alloc] initWithCapacity:1];
        _excludedTouches = [[NSMutableSet alloc] initWithCapacity:1];

        [self addTarget:target action:action];
    }
    return self;
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
}

- (NSUInteger)numberOfTouches
{
    return [_trackingTouches count];
}

- (CGPoint)locationInView:(UIView *)view
{
    // by default, this should compute the centroid of all the involved points
    // of course as of this writing, Chameleon only supports one point but at least
    // it may be semi-correct if that ever changes. :D YAY FOR COMPLEXITY!
    
    CGFloat x = 0;
    CGFloat y = 0;
    CGFloat k = 0;
    
    for (UITouch *touch in _trackingTouches) {
        const CGPoint p = [touch locationInView:view];
        x += p.x;
        y += p.y;
        k++;
    }
    
    if (k > 0) {
        return CGPointMake(x/k, y/k);
    } else {
        return CGPointZero;
    }
}

- (CGPoint)locationOfTouch:(NSUInteger)touchIndex inView:(UIView *)view
{
    return [[_trackingTouches objectAtIndex:touchIndex] locationInView:view];
}

- (void)setState:(UIGestureRecognizerState)state
{
    // the docs didn't say explicitly if these state transitions were verified, but I suspect they are. if anything, a check like this
    // should help debug things. it also helps me better understand the whole thing, so it's not a total waste of time :)

    typedef struct { UIGestureRecognizerState fromState, toState; BOOL shouldNotify, shouldReset; } StateTransition;

    #define NumberOfStateTransitions 9
    static const StateTransition allowedTransitions[NumberOfStateTransitions] = {
        // discrete gestures
        {UIGestureRecognizerStatePossible,		UIGestureRecognizerStateRecognized,     YES,    YES},
        {UIGestureRecognizerStatePossible,		UIGestureRecognizerStateFailed,         NO,     YES},

        // continuous gestures
        {UIGestureRecognizerStatePossible,		UIGestureRecognizerStateBegan,          YES,    NO },
        {UIGestureRecognizerStateBegan,			UIGestureRecognizerStateChanged,        YES,    NO },
        {UIGestureRecognizerStateBegan,			UIGestureRecognizerStateCancelled,      YES,    YES},
        {UIGestureRecognizerStateBegan,			UIGestureRecognizerStateEnded,          YES,    YES},
        {UIGestureRecognizerStateChanged,		UIGestureRecognizerStateChanged,        YES,    NO },
        {UIGestureRecognizerStateChanged,		UIGestureRecognizerStateCancelled,      YES,    YES},
        {UIGestureRecognizerStateChanged,		UIGestureRecognizerStateEnded,          YES,    YES}
    };
    
    const StateTransition *transition = NULL;

    for (NSUInteger t=0; t<NumberOfStateTransitions; t++) {
        if (allowedTransitions[t].fromState == _state && allowedTransitions[t].toState == state) {
            transition = &allowedTransitions[t];
            break;
        }
    }

    NSAssert2((transition != NULL), @"invalid state transition from %d to %d", _state, state);

    // should began? (possible -> began) or (possible -> end)
    if (_state == UIGestureRecognizerStatePossible &&
            (state == UIGestureRecognizerStateBegan ||
             state == UIGestureRecognizerStateEnded)) {
        BOOL shouldBegan = [self _shouldBegan];
        if (!shouldBegan) {
            [self _setExcluded];
            _state = UIGestureRecognizerStateFailed;
            _shouldSendActions = NO;
            _shouldReset = YES;
            return;
        }
    }
    
    if (transition) {
        _state = transition->toState;
        _shouldSendActions = transition->shouldNotify;
        _shouldReset = transition->shouldReset;

    }
    
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
    
    NSLog(@"%s -> %@",__PRETTY_FUNCTION__,shouldBegan?@"YES":@"NO");
    return shouldBegan;
}

- (BOOL)_isEatenTouche:(UITouch *)touch
{
    if (self.cancelsTouchesInView && (self.state == UIGestureRecognizerStateBegan ||
                                      self.state == UIGestureRecognizerStateChanged ||
                                      self.state == UIGestureRecognizerStateEnded)) {
        return [_trackingTouches containsObject:touch];
    }
    return NO;
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
    _state = UIGestureRecognizerStatePossible;
    [_trackingTouches removeAllObjects];
    [_excludedTouches removeAllObjects];
}

- (BOOL)canPreventGestureRecognizer:(UIGestureRecognizer *)preventedGestureRecognizer
{
    return YES;
}

- (BOOL)canBePreventedByGestureRecognizer:(UIGestureRecognizer *)preventingGestureRecognizer
{
    return YES;
}

- (void)ignoreTouch:(UITouch *)touch forEvent:(UIEvent*)event
{
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
    NSLog(@"-[%@ _setExcluded]",self.class);
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

- (void)_recognizeTouches:(NSSet *)touches withEvent:(UIEvent *)event
{
    if ([self _shouldAttemptToRecognize]) {
        for (UITouch *touch in touches) {
            if (touch.phase == UITouchPhaseBegan &&
                self.delegate &&
                ![_trackingTouches containsObject:touch] &&
                ![_excludedTouches containsObject:touch] &&
                [self.delegate respondsToSelector:@selector(gestureRecognizer:shouldReceiveTouch:)]&&
                ![self.delegate gestureRecognizer:self shouldReceiveTouch:touch]) {
                
                [_excludedTouches addObject:touch];
            }
        }

        
        NSMutableSet *ts = [touches mutableCopy];
        [ts minusSet:_excludedTouches];
        [_trackingTouches setArray:[ts allObjects]];

        for (UITouch *touch in _trackingTouches) {
            switch (touch.phase) {
                case UITouchPhaseBegan:
                    [self touchesBegan:touches withEvent:event];
                    break;

                case UITouchPhaseMoved:
                    [self touchesMoved:touches withEvent:event];
                    break;
                                    
                case UITouchPhaseEnded:
                    [self touchesEnded:touches withEvent:event];
                    break;
                    
                case UITouchPhaseCancelled:
                    [self touchesCancelled:touches withEvent:event];
                    break;

                case _UITouchPhaseGestureBegan:
                    [self _gesturesBegan:touches withEvent:event];
                    break;

                case _UITouchPhaseGestureChanged:
                    [self _gesturesMoved:touches withEvent:event];
                    break;

                case _UITouchPhaseGestureEnded:
                    [self _gesturesEnded:touches withEvent:event];
                    break;
                    
                case _UITouchPhaseDiscreteGesture:
                    [self _discreteGestures:touches withEvent:event];
                    break;
                    
                default:
                    break;
            }
        }
    }
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
