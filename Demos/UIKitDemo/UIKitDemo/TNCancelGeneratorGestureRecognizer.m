//
//  TNCancelGeneratorGestureRecognizer.m
//  UIKitDemo
//
//  Created by TaoZeyu on 15/10/8.
//  Copyright © 2015年 Shanghai TinyNetwork Inc. All rights reserved.
//

#import "TNCancelGeneratorGestureRecognizer.h"
#import <UIKit/UIGestureRecognizerSubclass.h>

@implementation TNCancelGeneratorGestureRecognizer
{
    NSTimer *_cancelFireTimer;
    BOOL _hasStartedTimer;
    BOOL _disableForwardMessage;
    __weak UIEvent *_lastCatchedEvent;
}

- (void)reset
{
    [super reset];
    [self _stopInvalidTimer];
    
    if (_proxyGestureRecognizer) {
        [_proxyGestureRecognizer reset];
    }
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesBegan:touches withEvent:event];
    [self _handleTouchesCallback:@selector(touchesBegan:withEvent:) touches:touches event:event];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesMoved:touches withEvent:event];
    [self _handleTouchesCallback:@selector(touchesMoved:withEvent:) touches:touches event:event];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesEnded:touches withEvent:event];
    [self _handleTouchesCallback:@selector(touchesEnded:withEvent:) touches:touches event:event];
}

- (void)_handleTouchesCallback:(SEL)method touches:(NSSet *)touches event:(UIEvent *)event
{
    if (!_hasStartedTimer) {
        [self _startTimer];
        _hasStartedTimer = YES;
    }
    if (!_disableForwardMessage && _proxyGestureRecognizer) {
        [_proxyGestureRecognizer performSelector:method withObject:touches withObject:event];
        if (self.state != _proxyGestureRecognizer.state) {
            [self setState:_proxyGestureRecognizer.state];
        }
    } else {
        self.state = UIGestureRecognizerStateFailed;
    }
}

- (void)_onCancelFire:(NSTimer *)timer
{
    _disableForwardMessage = YES;
    _cancelFireTimer = nil;
    
    if (_proxyGestureRecognizer) {
        UITouch *touch = [[UITouch alloc] init];
        NSMutableSet *touches = [[NSMutableSet alloc] initWithObjects:touch, nil];
        [_proxyGestureRecognizer performSelector:@selector(touchesCancelled:withEvent:)
                                      withObject:touches withObject:_lastCatchedEvent];
    }
}

- (void)_startTimer
{
    [self _stopInvalidTimer];
    
    NSTimeInterval timeInterval = drand48()*5;
    _cancelFireTimer = [NSTimer scheduledTimerWithTimeInterval:timeInterval
                                                        target:self selector:@selector(_onCancelFire:)
                                                      userInfo:nil repeats:NO];
    [[NSRunLoop currentRunLoop] addTimer:_cancelFireTimer forMode:NSRunLoopCommonModes];
}

- (void)_stopInvalidTimer
{
    if (_cancelFireTimer) {
        [_cancelFireTimer invalidate];
        _cancelFireTimer = nil;
    }
}

@end
