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

#import "UIControl+UIPrivate.h"
#import "UIEvent.h"
#import "UITouch.h"
#import "UIApplication.h"
#import "UIControlAction.h"
#import "UIGeometry.h"

#import "UIGestureRecognizer.h"
#import "UIGestureRecognizerSubclass.h"

@interface _UIControlGestureRecognizer : UIGestureRecognizer
- (instancetype)initWIthControl:(UIControl *)control;
@end

@implementation UIControl
{
    NSMutableDictionary *_touchBeginLocationContainer;
    _UIControlGestureRecognizer *_controlGestureRecognizer;
}
@synthesize tracking=_tracking, touchInside=_touchInside, selected=_selected, enabled=_enabled, highlighted=_highlighted;
@synthesize contentHorizontalAlignment=_contentHorizontalAlignment, contentVerticalAlignment=_contentVerticalAlignment;

- (id)initWithFrame:(CGRect)frame
{
    if ((self=[super initWithFrame:frame])) {
        _registeredActions = [[NSMutableArray alloc] init];
        _touchBeginLocationContainer = [[NSMutableDictionary alloc] init];
        _controlGestureRecognizer = [[_UIControlGestureRecognizer alloc] initWIthControl:self];
        self.enabled = YES;
        self.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
        self.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
        [self addGestureRecognizer:_controlGestureRecognizer];
    }
    return self;
}

- (void)addTarget:(id)target action:(SEL)action forControlEvents:(UIControlEvents)controlEvents
{
    UIControlAction *controlAction = [[UIControlAction alloc] init];
    controlAction.target = target;
    controlAction.action = action;
    controlAction.controlEvents = controlEvents;
    [_registeredActions addObject:controlAction];
}

- (void)removeTarget:(id)target action:(SEL)action forControlEvents:(UIControlEvents)controlEvents
{
    NSMutableArray *discard = [[NSMutableArray alloc] init];
    
    for (UIControlAction *controlAction in _registeredActions) {
        if (controlAction.target == target && (action == NULL || controlAction.controlEvents == controlEvents)) {
            [discard addObject:controlAction];
        }
    }
    
    [_registeredActions removeObjectsInArray:discard];
}

- (NSArray *)actionsForTarget:(id)target forControlEvent:(UIControlEvents)controlEvent
{
    NSMutableArray *actions = [[NSMutableArray alloc] init];
    
    for (UIControlAction *controlAction in _registeredActions) {
        if ((target == nil || controlAction.target == target) && (controlAction.controlEvents & controlEvent) ) {
            [actions addObject:NSStringFromSelector(controlAction.action)];
        }
    }
    
    if ([actions count] == 0) {
        return nil;
    } else {
        return actions;
    }
}

- (NSSet *)allTargets
{
    return [NSSet setWithArray:[_registeredActions valueForKey:@"target"]];
}

- (UIControlEvents)allControlEvents
{
    UIControlEvents allEvents = 0;
    
    for (UIControlAction *controlAction in _registeredActions) {
        allEvents |= controlAction.controlEvents;
    }
    
    return allEvents;
}

- (void)_sendActionsForControlEvents:(UIControlEvents)controlEvents withEvent:(UIEvent *)event
{
    for (UIControlAction *controlAction in _registeredActions) {
        if (controlAction.controlEvents & controlEvents) {
            [self sendAction:controlAction.action to:controlAction.target forEvent:event];
        }
    }
}

- (void)sendActionsForControlEvents:(UIControlEvents)controlEvents
{
    [self _sendActionsForControlEvents:controlEvents withEvent:nil];
}

- (void)sendAction:(SEL)action to:(id)target forEvent:(UIEvent *)event
{
    [[UIApplication sharedApplication] sendAction:action to:target from:self forEvent:event];
}

- (BOOL)beginTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event
{
    return YES;
}

- (BOOL)continueTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event
{
    return YES;
}

- (void)endTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event
{
}

- (void)cancelTrackingWithEvent:(UIEvent *)event
{
}

- (void)_touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    for (UITouch *touch in touches) {
        [self _setBeginLocation:[touch locationInView:self.window] forTouch:touch];
    }
    UITouch *touch = [touches anyObject];
    _touchInside = YES;
    _tracking = [self beginTrackingWithTouch:touch withEvent:event];

    self.highlighted = YES;

    if (_tracking) {
        UIControlEvents currentEvents = UIControlEventTouchDown;

        if (touch.tapCount > 1) {
            currentEvents |= UIControlEventTouchDownRepeat;
        }

        [self _sendActionsForControlEvents:currentEvents withEvent:event];
    }
}

- (void)_touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    const BOOL wasTouchInside = _touchInside;
    _touchInside = [self pointInside:[touch locationInView:self] withEvent:event];

    self.highlighted = _touchInside;

    if (_tracking) {
        _tracking = [self continueTrackingWithTouch:touch withEvent:event];
        if (_tracking) {
            UIControlEvents currentEvents = ((_touchInside)? UIControlEventTouchDragInside : UIControlEventTouchDragOutside);

            if (!wasTouchInside && _touchInside) {
                currentEvents |= UIControlEventTouchDragEnter;
            } else if (wasTouchInside && !_touchInside) {
                currentEvents |= UIControlEventTouchDragExit;
            }

            [self _sendActionsForControlEvents:currentEvents withEvent:event];
        }
    }
}

- (void)_touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    _touchInside = [self pointInside:[touch locationInView:self] withEvent:event];

    self.highlighted = NO;

    if (_tracking && ![self _isTouchMoveTooMuchDistance:touch]) {
        [self endTrackingWithTouch:touch withEvent:event];
        [self _sendActionsForControlEvents:((_touchInside)? UIControlEventTouchUpInside : UIControlEventTouchUpOutside) withEvent:event];
    }

    _tracking = NO;
    _touchInside = NO;
    
    [_touchBeginLocationContainer removeAllObjects];
}

- (void)_touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    self.highlighted = NO;

    if (_tracking) {
        [self cancelTrackingWithEvent:event];
        [self _sendActionsForControlEvents:UIControlEventTouchCancel withEvent:event];
    }

    _touchInside = NO;
    _tracking = NO;
    
    [_touchBeginLocationContainer removeAllObjects];
}

- (BOOL)_isTouchMoveTooMuchDistance:(UITouch *)touch
{
    CGPoint beginLocation = [self _beginLocationForTouch:touch];
    CGPoint currentLocation = [touch locationInView:self.window];
    
    CGFloat distance = MAX(ABS(beginLocation.x - currentLocation.x),
                           ABS(beginLocation.y - currentLocation.y));
    
    return distance > 20;
}

- (void)_setBeginLocation:(CGPoint)beginLoction forTouch:(UITouch *)touch
{
    NSValue *key = [NSValue valueWithNonretainedObject:touch];
    [_touchBeginLocationContainer setObject:[NSValue valueWithCGPoint:beginLoction]  forKey:key];
}

- (CGPoint)_beginLocationForTouch:(UITouch *)touch
{
    NSValue *key = [NSValue valueWithNonretainedObject:touch];
    NSValue *value = [_touchBeginLocationContainer objectForKey:key];
    
    if (value) {
        return [value CGPointValue];
    } else {
        return CGPointZero;
    }
}

- (void)_stateDidChange
{
    [self setNeedsDisplay];
    [self setNeedsLayout];
}

- (void)setEnabled:(BOOL)newEnabled
{
    if (newEnabled != _enabled) {
        _enabled = newEnabled;
        [self _stateDidChange];
        self.userInteractionEnabled = _enabled;
    }
}

- (void)setHighlighted:(BOOL)newHighlighted
{
    if (newHighlighted != _highlighted) {
        _highlighted = newHighlighted;
        [self _stateDidChange];
    }
}

- (void)setSelected:(BOOL)newSelected
{
    if (newSelected != _selected) {
        _selected = newSelected;
        [self _stateDidChange];
    }
}

- (UIControlState)state
{
    UIControlState state = UIControlStateNormal;
    
    if (_highlighted)	state |= UIControlStateHighlighted;
    if (!_enabled)		state |= UIControlStateDisabled;
    if (_selected)		state |= UIControlStateSelected;

    return state;
}

@end

@implementation _UIControlGestureRecognizer
{
    NSUInteger _touchedCount;
    __unsafe_unretained UIControl *_control;
}

-(instancetype)initWIthControl:(UIControl *)control
{
    if (self = [super init]) {
        _control = control;
        self.cancelsTouchesInView = NO;
    }
    return self;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    _touchedCount += [self _countOfTouches:touches withPhase:UITouchPhaseBegan];
    [_control _touchesBegan:touches withEvent:event];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    [_control _touchesMoved:touches withEvent:event];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    _touchedCount -= [self _countOfTouches:touches withPhase:UITouchPhaseEnded];
    [_control _touchesEnded:touches withEvent:event];
    
    if (_touchedCount == 0) {
        self.state = UIGestureRecognizerStateFailed;
    }
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    [_control _touchesCancelled:touches withEvent:event];
    self.state = UIGestureRecognizerStateCancelled;
    _touchedCount = 0;
}

- (NSUInteger)_countOfTouches:(NSSet *)touches withPhase:(UITouchPhase)phase
{
    NSUInteger count = 0;
    for (UITouch *touch in touches) {
        if (touch.phase == phase) {
            count ++;
        }
    }
    return count;
}

@end
