//
//  UIMultiTouchProcess.m
//  UIKit
//
//  Created by TaoZeyu on 15/8/20.
//  Copyright (c) 2015年 Shanghai Tinynetwork Inc. All rights reserved.
//

#import "UIMultiTouchProcess.h"
#import "UITouch+Private.h"
#import "UIGestureRecognizeProcess.h"
#import "UIGestureRecognizerSubclass.h"
#import "UIGestureRecognizer+UIPrivate.h"

@implementation UIMultiTouchProcess
{
    UIWindow *_window;
    
    NSInteger _currentPressFingersCount;
    BOOL _legacyAnyRecognizeProcesses;
    
    NSMutableDictionary *_effectRecognizeProcesses;
}

- (instancetype)init
{
    if (self = [super init]) {
        _effectRecognizeProcesses = [NSMutableDictionary dictionary];
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

- (void)sendEvent:(UIEvent *)event
{
    NSSet *touches = [event touchesForWindow:_window];
    
    BOOL touchBegin = NO;
    BOOL touchEnd = NO;
    
    [self _reciveTouches:touches andCheckMultiTouchProcessStateWithTouchBegin:&touchBegin
                touchEnd:&touchEnd];
    
    if (touchBegin) {
        NSLog(@"[begin multi-touch]");
        [self _beginWithEvent:event touches:touches];
    }
    [self _handleEvent:event touches:touches];
    
    if (touchEnd) {
        NSLog(@"[end multi-touch]");
        [self _end];
    }
}

- (void)_reciveTouches:(NSSet *)touches andCheckMultiTouchProcessStateWithTouchBegin:(BOOL *)touchBegin
            touchEnd:(BOOL *)touchEnd
{
    // I can't set _currentPressFingersCount as [touches count].
    // because when [touches count] become 0, the sendEvent: will never be called.
    // but I must call _end method when touches ended.
    
    // So, I check [UITouch phase] and get the next [touches count] will be.
    
    NSInteger originalPressFingersCount = _currentPressFingersCount;
    NSInteger incrementCount = [self _incrementPressFingersCountWithTouches:touches];
    
    _currentPressFingersCount += incrementCount;
    
    if (incrementCount != 0) {
        
        if (originalPressFingersCount == 0) {
            *touchBegin = YES;
            
        } else if (_currentPressFingersCount == 0) {
            *touchEnd = YES;
        }
    }
}

- (NSInteger)_incrementPressFingersCountWithTouches:(NSSet *)touches
{
    NSInteger incrementCount = 0;
    
    for (UITouch *touch in touches) {
        
        UITouchPhase phase = touch.phase;
        
        if (phase == UITouchPhaseBegan) {
            incrementCount++;
            
        } else if(phase == UITouchPhaseEnded || phase == UITouchPhaseCancelled) {
            incrementCount--;
        }
    }
    return incrementCount;
}

- (void)_beginWithEvent:(UIEvent *)event touches:(NSSet *)touches
{
    if (!_legacyAnyRecognizeProcesses) {
        [self _collectAndGenerateGestureReconizeProcessesFromTouches:touches];
    }
    
    for (UIGestureRecognizeProcess *recognizeProcess in [_effectRecognizeProcesses allValues]) {
        [recognizeProcess multiTouchBegin];
    }
}

- (void)_collectAndGenerateGestureReconizeProcessesFromTouches:(NSSet *)touches
{
    for (UITouch *touch in touches) {
        
        if (touch.phase != UITouchPhaseBegan) {
            continue;
        }
        
        UIView *view = [self _findViewCanCatch:touch.view];
        
        if (!view) {
            continue;
        }
        
        NSValue *keyView = [NSValue valueWithNonretainedObject:view];
        UIGestureRecognizeProcess *recognizeProcess = [_effectRecognizeProcesses objectForKey:keyView];
        
        if (!recognizeProcess) {
            recognizeProcess = [[UIGestureRecognizeProcess alloc] initWithView:view];
            [_effectRecognizeProcesses setObject:recognizeProcess forKey:keyView];
        }
        [recognizeProcess trackTouch:touch];
    }
}

- (UIView *)_findViewCanCatch:(UIView *)view
{
    while (view && ![UIGestureRecognizeProcess canViewCatchTouches:view]) {
        view = view.superview;
    }
    return view;
}

- (void)_handleEvent:(UIEvent *)event touches:(NSSet *)touches
{
    NSArray *recognizerProcesses = [_effectRecognizeProcesses allValues];
    
    for (UIGestureRecognizeProcess *recognizeProcess in recognizerProcesses) {
        [recognizeProcess recognizeEvent:event touches:touches];
    }
    for (UIGestureRecognizeProcess *recognizeProcess in recognizerProcesses) {
        [recognizeProcess sendToAttachedViewIfNeedWithEvent:event touches:touches];
    }
}

- (void)_end
{
    for (UIGestureRecognizeProcess *recognizeProcess in [_effectRecognizeProcesses allValues]) {
        [recognizeProcess multiTouchEnd];
    }
    
    [self _clearHasMakeConclusionReconizeProcesses];
    _legacyAnyRecognizeProcesses = _effectRecognizeProcesses.count > 0;
    
    if (_legacyAnyRecognizeProcesses) {
        NSLog(@"multi touch left some recognize processes.");
    }
}

- (void)_clearHasMakeConclusionReconizeProcesses
{
    NSMutableArray *hasMakeConclusionViews = [[NSMutableArray alloc]init];
    
    for (NSValue *key in [_effectRecognizeProcesses allKeys]) {
        
        UIGestureRecognizeProcess *recognizeProcess = [_effectRecognizeProcesses objectForKey:key];
        
        if (recognizeProcess.hasMakeConclusion) {
            [hasMakeConclusionViews addObject:key];
        }
    }
    [_effectRecognizeProcesses removeObjectsForKeys:hasMakeConclusionViews];
}

@end
