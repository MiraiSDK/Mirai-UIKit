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

#import "UILongPressGestureRecognizer.h"
#import "UITapGestureRecognizer+UIPrivate.h"
#import "UIGestureRecognizerSubclass.h"
#import "UIGestureRecognizer+UIPrivate.h"
#import "UITouch+Private.h"
#import "UIEvent.h"
#import "TNMultiTapHelper.h"

BOOL isGestureRecognizerFailedOrCancelled(UIGestureRecognizer *recognizer) {
    return recognizer.state == UIGestureRecognizerStateCancelled ||
           recognizer.state == UIGestureRecognizerStateFailed;
}

@interface UILongPressGestureRecognizer () <TNMultiTapHelperDelegate> @end

@interface _TNTapRequireGestureRecognizer : UITapGestureRecognizer
- (instancetype)initWithLongPressGestureRecognizer:(UILongPressGestureRecognizer *)longPressGestureRecognizer;
- (BOOL)remainLastTap;
- (void)clear;
@end

@implementation UILongPressGestureRecognizer
{
    TNMultiTapHelper *_multiTapHelper;
    _TNTapRequireGestureRecognizer *_tapRequireGestureRecognizer;
    BOOL _waitForNewTouchBegin;
    BOOL _hasRecivedAnyTouches;
}
@synthesize minimumPressDuration=_minimumPressDuration, allowableMovement=_allowableMovement, numberOfTapsRequired=_numberOfTapsRequired;
@synthesize numberOfTouchesRequired=_numberOfTouchesRequired;

- (instancetype)init
{
    if ((self=[super init])) {
        _allowableMovement = 10;
        _minimumPressDuration = 0.5;
        _numberOfTapsRequired = 0;
        _numberOfTouchesRequired = 1;
        _waitForNewTouchBegin = YES;
        _multiTapHelper = [[TNMultiTapHelper alloc] initWithTimeInterval:_minimumPressDuration
                                                       gestureRecognizer:self];
    }
    return self;
}

- (void)setMinimumPressDuration:(CFTimeInterval)minimumPressDuration
{
    _minimumPressDuration = minimumPressDuration;
    _multiTapHelper.timeInterval = minimumPressDuration;
}

- (void)setNumberOfTouchesRequired:(NSInteger)numberOfTouchesRequired
{
    _numberOfTouchesRequired = numberOfTouchesRequired;
    _multiTapHelper.numberOfTouchesRequired = numberOfTouchesRequired + 1;
}

- (void)onOverTime
{
    if (![self _hasMadeConclusion]) {
        if (_multiTapHelper.pressedTouchesCount == 0) {
            // fail when no fingers touching screen.
            [_multiTapHelper cancelTap];
            
        } else if (![_multiTapHelper anyTouchesOutOfArea:_allowableMovement] &&
                   _multiTapHelper.pressedTouchesCount >= self.numberOfTouchesRequired) {
            [self _setStateForce:UIGestureRecognizerStateBegan];
        }
    }
}

- (void)onCompleteTap
{
    if (_multiTapHelper.hasOverTime) {
        [self _setStateForce:UIGestureRecognizerStateEnded];
    } else {
        [_multiTapHelper cancelTap];
    }
}

- (void)reset
{
    [super reset];
    [_multiTapHelper reset];
    
    if (_tapRequireGestureRecognizer) {
        [_tapRequireGestureRecognizer clear];
        _tapRequireGestureRecognizer = nil;
    }
    _waitForNewTouchBegin = YES;
    _hasRecivedAnyTouches = NO;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (!_hasRecivedAnyTouches) {
        [self _generateTapRequireGestureRecognizerIfNeed];
        _hasRecivedAnyTouches = YES;
    }
    
    if ([self _hasFinishedExtraTap]) {
        [_multiTapHelper trackTouches:touches];
        [_multiTapHelper beginOneTap];
        
        if (!_waitForNewTouchBegin || _multiTapHelper.pressedTouchesCount > self.numberOfTouchesRequired) {
            [_multiTapHelper cancelTap];
        }
    } else if ([self _tapRequireGestureRecognizerCanRecivedTouches]) {
        [_tapRequireGestureRecognizer touchesBegan:touches withEvent:event];
    }
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    if ([self _hasFinishedExtraTap]) {
        if (self.state == UIGestureRecognizerStateBegan ||
            self.state == UIGestureRecognizerStateChanged) {
            
            [self _setStateForce:UIGestureRecognizerStateChanged];
        }
    } else if ([self _tapRequireGestureRecognizerCanRecivedTouches]) {
        [_tapRequireGestureRecognizer touchesMoved:touches withEvent:event];
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    
    if ([self _hasFinishedExtraTap]) {
        _waitForNewTouchBegin = NO;
        [_multiTapHelper releaseFingersWithTouches:touches];
        
    } else if ([self _tapRequireGestureRecognizerCanRecivedTouches]) {
        [_tapRequireGestureRecognizer touchesEnded:touches withEvent:event];
    }
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    if ([self _hasFinishedExtraTap]) {
        [_multiTapHelper cancelTap];
        
    } else if ([self _tapRequireGestureRecognizerCanRecivedTouches]) {
        [_tapRequireGestureRecognizer touchesCancelled:touches withEvent:event];
    }
}

- (void)_generateTapRequireGestureRecognizerIfNeed
{
    if (_numberOfTapsRequired > 0) {
        _tapRequireGestureRecognizer = [[_TNTapRequireGestureRecognizer alloc] initWithLongPressGestureRecognizer:self];
    }
}

- (BOOL)_hasFinishedExtraTap
{
    if (_tapRequireGestureRecognizer &&
        ![_tapRequireGestureRecognizer _hasMadeConclusion] &&
        [_tapRequireGestureRecognizer remainLastTap]) {
        
        [_tapRequireGestureRecognizer clear];
        _tapRequireGestureRecognizer = nil;
    }
    return !_tapRequireGestureRecognizer;
}

- (BOOL)_tapRequireGestureRecognizerCanRecivedTouches
{
    return _tapRequireGestureRecognizer &&
           !isGestureRecognizerFailedOrCancelled(_tapRequireGestureRecognizer);
}

@end

@implementation _TNTapRequireGestureRecognizer
{
    __unsafe_unretained UILongPressGestureRecognizer *_longPressGestureRecognizer;
}

- (instancetype)initWithLongPressGestureRecognizer:(UILongPressGestureRecognizer *)longPressGestureRecognizer
{
    if (self = [super init]) {
        _longPressGestureRecognizer = longPressGestureRecognizer;
        self.numberOfTapsRequired = longPressGestureRecognizer.numberOfTapsRequired + 1;
        self.numberOfTouchesRequired = longPressGestureRecognizer.numberOfTouchesRequired;
    }
    return self;
}

- (void)setState:(UIGestureRecognizerState)state
{
    // I can't check the state of this gesture recognizer when touchesXXX:withEvent: is called.
    // Because the state may be changed at NSTimer callback method.
    // I must make long press gesture recognizer fail no matter when the tap require gesture recognizer is called setState: method.
    
    [super setState:state];
    
    if (_longPressGestureRecognizer &&
        ![_longPressGestureRecognizer _hasMadeConclusion] &&
        isGestureRecognizerFailedOrCancelled(self)) {
        
        [_longPressGestureRecognizer setState:self.state];
    }
}

- (BOOL)canPreventGestureRecognizer:(UIGestureRecognizer *)preventedGestureRecognizer
{
    return [preventedGestureRecognizer isKindOfClass:[UILongPressGestureRecognizer class]] ||
           [preventedGestureRecognizer isKindOfClass:[UITapGestureRecognizer class]];
}

- (BOOL)canBePreventedByGestureRecognizer:(UIGestureRecognizer *)preventingGestureRecognizer
{
    return [preventingGestureRecognizer isKindOfClass:[UILongPressGestureRecognizer class]] ||
           [preventingGestureRecognizer isKindOfClass:[UITapGestureRecognizer class]];
}

- (void)clear
{
    _longPressGestureRecognizer = nil;
}

- (BOOL)remainLastTap
{
    return self.currentTapCount >= self.numberOfTouchesRequired - 1;
}

@end
