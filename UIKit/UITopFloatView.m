//
//  UITopFloatView.m
//  UIKit
//
//  Created by TaoZeyu on 15/5/29.
//  Copyright (c) 2015年 Shanghai Tinynetwork Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UITopFloatView.h"
#import "UIWindow+UIPrivate.h"

@interface UITopFloatView ()
{
    __weak UIWindow *_currentKeyWindow;
}
@end

@implementation UITopFloatView

- (instancetype)init
{
    if (self = [super init]) {
        _floatCloseToTarget = CGRectNull;
    }
    return self;
}

- (BOOL)allowedReceiveViewAndItsSubviews:(UIView *)view
{
    return self == view;
}

- (void)setVisible:(BOOL)visible
{
    [self setVisible:visible animated:NO];
}

- (void)setVisible:(BOOL)visible animated:(BOOL)animated
{
    if (visible) {
        _currentKeyWindow = [[UIApplication sharedApplication] keyWindow];
        if (![_currentKeyWindow _hasAddedTopFloatView:self]) {
            [_currentKeyWindow _addTopFloatView:self];
            [self _chooseAndSetSuitableLocationAndDirectionWithFloatCloseToTarget:_floatCloseToTarget];
        }
    } else {
        [self removeFromSuperview];
    }
    _visible = visible;
}

- (void)setFloatCloseToTarget:(CGRect)floatCloseToTarget
{
    if (!CGRectEqualToRect(_floatCloseToTarget, floatCloseToTarget)) {
        _floatCloseToTarget = floatCloseToTarget;
        if (_currentKeyWindow) {
            [self _chooseAndSetSuitableLocationAndDirectionWithFloatCloseToTarget:floatCloseToTarget];
        }
    }
}

- (void)_chooseAndSetSuitableLocationAndDirectionWithFloatCloseToTarget:(CGRect)floatCloseToTarget
{
    if (CGRectIsNull(floatCloseToTarget)) {
        return;
    }
    for (UIPositionOnRect *targetPoR in [self testListForTargetPositionOnBorder]) {
        for (UIPositionOnRect *selfPoR in [self testListForSelfPositionOnBorderWhileTargetIs:targetPoR]) {
            CGRect testBubbleRect = [self bubbleBodyRectangleWithPositionOnRect:selfPoR
                                                                         inArea:floatCloseToTarget areaPositionOnRect:targetPoR];
            if ([self _suitableWithTestBubbleRect:testBubbleRect withFloatCloseToTarget:floatCloseToTarget]) {
                [self setArrowPossitionOnRect:selfPoR];
                [self setPositionCloseToArea:floatCloseToTarget areaPositionOnRect:targetPoR];
                return;
            }
        }
    }
    // not found any suitable situations.
    CGPoint centerPosition = [self _centerPositionOnRect:floatCloseToTarget];
    UIPositionOnRect *choosedSelfPoR = nil;
    for (UIPositionOnRect *selfPoR in [self testListForSelfPositionOnBorderWhilePositionAtTargetCenter]) {
        choosedSelfPoR = selfPoR;
        CGRect testBubbleRect = [self bubbleBodyRectangleWithPositionOnRect:selfPoR atPosition:centerPosition];
        if (CGRectContainsRect(_currentKeyWindow.bounds, testBubbleRect)) {
            break;
        }
    }
    [self setArrowPossitionOnRect:choosedSelfPoR];
    [self setArrowPosition:centerPosition];
}

- (NSArray *)testListForTargetPositionOnBorder
{
    return @[];// to be override.
}

- (NSArray *)testListForSelfPositionOnBorderWhilePositionAtTargetCenter
{
    return @[];// to be override.
}

- (NSArray *)testListForSelfPositionOnBorderWhileTargetIs:(UIPositionOnRect *)targetPoR
{
    return @[];// to be override.
}

- (BOOL)_suitableWithTestBubbleRect:(CGRect)testBubbleRect withFloatCloseToTarget:(CGRect)floatCloseToTarget
{
    return  CGRectContainsRect(_currentKeyWindow.bounds, testBubbleRect) &&
            !CGRectIntersectsRect(floatCloseToTarget, testBubbleRect);
}

- (CGPoint)_centerPositionOnRect:(CGRect)rect
{
    return CGPointMake(rect.origin.x + rect.size.width/2, rect.origin.x + rect.size.height/2);
}

@end
