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
#import "UIGestureRecognizerSubclass.h"
#import "UITouch+Private.h"
#import "UIEvent.h"
#import "TNMultiTapHelper.h"

@interface UILongPressGestureRecognizer () <TNMultiTapHelperDelegate> @end

@implementation UILongPressGestureRecognizer
{
    TNMultiTapHelper *_multiTapHelper;
    BOOL _waitForNewTouchBegin;
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
    if (_multiTapHelper.pressedTouchesCount == 0) {
        // fail when no fingers touching screen.
        [_multiTapHelper cancelTap];
        
    } else if (![_multiTapHelper anyTouchesOutOfArea:_allowableMovement] &&
        _multiTapHelper.pressedTouchesCount >= self.numberOfTouchesRequired) {
        [self setState:UIGestureRecognizerStateBegan];
    }
}

- (void)onCompleteTap
{
    if (_multiTapHelper.hasOverTime) {
        [self setState:UIGestureRecognizerStateEnded];
    } else {
        [_multiTapHelper cancelTap];
    }
}

- (void)reset
{
    [super reset];
    [_multiTapHelper reset];
    
    _waitForNewTouchBegin = YES;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [_multiTapHelper trackTouches:touches];
    [_multiTapHelper beginOneTap];
    
    if (!_waitForNewTouchBegin || _multiTapHelper.pressedTouchesCount > self.numberOfTouchesRequired) {
        [_multiTapHelper cancelTap];
    }
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (self.state == UIGestureRecognizerStateBegan ||
        self.state == UIGestureRecognizerStateChanged) {
        
        [self setState:UIGestureRecognizerStateChanged];
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    _waitForNewTouchBegin = NO;
    [_multiTapHelper releaseFingersWithTouches:touches];
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    [_multiTapHelper cancelTap];
}

@end
