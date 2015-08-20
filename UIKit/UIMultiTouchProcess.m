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
    
    BOOL _hasGestureRecognized;
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

- (void)onBegan
{
    
}

- (void)onEnded
{
    
}

- (void)sendEvent:(UIEvent *)event
{
    [self _sendGesturesForEvent:event];
    
    NSMutableSet *touches = [[event touchesForWindow:_window] mutableCopy];
    
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
            NSLog(@"Unknow touch phase:%ld",phase);
        }
    }
}

- (void)_sendGesturesForEvent:(UIEvent *)event
{
    NSSet *touches = [event touchesForWindow:_window];
    
    NSMutableSet *gestureRecognizers = [NSMutableSet setWithCapacity:0];
    
    for (UITouch *touch in touches) {
        [gestureRecognizers addObjectsFromArray:touch.gestureRecognizers];
    }
    
    BOOL isFirstTouchDownEvent = (_touches.count == 0);
    // if first touch down
    if (isFirstTouchDownEvent) {
        //    collect effect gestures
        [_effectRecognizers unionSet:gestureRecognizers];
        _hasGestureRecognized = NO;
    }
    
    // remember new touches
    for (UITouch *touch in touches) {
        if (touch.phase == UITouchPhaseBegan) {
            [_touches addObject:touch];
        }
    }
    
    // remove disabled gesture recognizer
    NSMutableSet *disabled = [NSMutableSet set];
    for (UIGestureRecognizer *recognizer in _effectRecognizers) {
        if (!recognizer.isEnabled) {
            [disabled addObject:recognizer];
        }
    }
    [_effectRecognizers minusSet:disabled];
    
    
    // before send event to recognizer, send pending actions
    for (UIGestureRecognizer *recognizer in _effectRecognizers) {
        if ([recognizer _shouldSendActions]) {
            [recognizer _sendActions];
        }
    }
    
    // send event to effect gesture recognizers
    for (UIGestureRecognizer *recognizer in _effectRecognizers) {
        [recognizer _recognizeTouches:touches withEvent:event];
    }
    
    // determine relationship
    NSMutableSet *toRemove = [NSMutableSet set];
    for (UIGestureRecognizer *recognizer in _effectRecognizers) {
        if (![recognizer _isFailed]) {
            for (UIGestureRecognizer *other in _effectRecognizers) {
                if (![other _isFailed]) {
                    BOOL exclued = [recognizer _isExcludedByGesture:other];
                    if (exclued) {
                        [recognizer _setExcluded];
                        [_excludedRecognizers addObject:recognizer];
                        
                        [toRemove addObject:recognizer];
                    }
                }
            }
        }
    }
    
    // remove invaild gestures
    [_effectRecognizers minusSet:toRemove];
    
    // cancel touches if needs
    BOOL shouldSendsTouchCancelled = NO;
    if (!_hasGestureRecognized) {
        for (UIGestureRecognizer *recognizer in _effectRecognizers) {
            if ([recognizer _shouldSendActions] &&
                [recognizer cancelsTouchesInView]) {
                shouldSendsTouchCancelled = YES;
                break;
            }
        }
    }
    
    if (shouldSendsTouchCancelled) {
        for (UITouch *touch in touches) {
            [touch.view touchesCancelled:touches withEvent:event];
        }
    }
    
    // send action if needs
    for (UIGestureRecognizer *recognizer in _effectRecognizers) {
        if ([recognizer _shouldSendActions]) {
            [recognizer _sendActions];
        }
    }
    
    for (UITouch *touch in touches) {
        if (touch.phase == UITouchPhaseEnded || touch.phase == UITouchPhaseCancelled) {
            [_touches removeObject:touch];
        }
    }
    
    // if all touch up
    NSSet *set = [event allTouches];
    BOOL allTouchUp = YES;
    for (UITouch *t in set) {
        if (t.phase != UITouchPhaseCancelled &&
            t.phase != UITouchPhaseEnded) {
            allTouchUp = NO;
            break;
        }
    }
    if (allTouchUp) {
        NSLog(@"reset all gesture recognizer");
        
        //  reset
        for (UIGestureRecognizer *recognizer in _effectRecognizers) {
            [recognizer reset];
        }
        
        // reset exclued ges
        for (UIGestureRecognizer *recognizer in _excludedRecognizers) {
            [recognizer reset];
        }
        
        //  clean up
        [_effectRecognizers removeAllObjects];
        [_excludedRecognizers removeAllObjects];
        
        _hasGestureRecognized = NO;
        
        [_touches removeAllObjects];
    }
}


@end
