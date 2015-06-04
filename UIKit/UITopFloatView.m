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

#define kMinimumOverlapSize 35

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
    floatCloseToTarget = CGRectIntersection(_currentKeyWindow.bounds, floatCloseToTarget);
    for (NSNumber *directionNumber in [self testPositionOnBorderDirectionList]) {
        UIPositionOnRectDirection direction = directionNumber.unsignedIntegerValue;
        BOOL foundSuitable = NO;
        if (direction == UIPositionOnRectDirectionNone) {
            [self _showToCenterOnFloatCloseToTargetRect:floatCloseToTarget];
            foundSuitable = YES;
        } else {
            foundSuitable = [self _chooseAndReturnYesIfSuccessWithDirection:direction
                                                 withFloatCloseToTargetRect:floatCloseToTarget];
        }
        if (foundSuitable) {
            break;
        }
    }
}

- (void)_showToCenterOnFloatCloseToTargetRect:(CGRect)floatCloseToTarget
{
    UIPositionOnRect *topFloatViewPoR = [UIPositionOnRect positionOnRectWithPositionScale:0.5
                                                                      withBorderDirection:UIPositionOnRectDirectionDown];
    CGPoint arrowPosition = CGPointMake(floatCloseToTarget.origin.x + floatCloseToTarget.size.width/2,
                                        floatCloseToTarget.origin.y + floatCloseToTarget.size.height/2);
    
    [self setArrowPossitionOnRect:topFloatViewPoR];
    [self setArrowPosition:arrowPosition];
}

- (BOOL)_chooseAndReturnYesIfSuccessWithDirection:(UIPositionOnRectDirection)direction
                                              withFloatCloseToTargetRect:(CGRect)floatCloseToTarget
{
    CGRect topFloatViewContainerRect = [self _topFloatViewContainerRectWithDirection:direction
                                                          withFloatCloseToTargetRect:floatCloseToTarget];
    if (CGRectIsNull(topFloatViewContainerRect)) {
        return NO;
    }
    CGPoint arrowPosition = [self _arrowPositionWithFloatCloseToTargetRect:floatCloseToTarget
                                                             withDirection:direction];
    
    CGRect visibleTargetRect = CGRectIntersection(_currentKeyWindow.bounds, floatCloseToTarget);
    CGFloat windowSize, limit0, limit1, size, suitableCenterLine;
    
    switch (direction) {
        case UIPositionOnRectDirectionUp:
        case UIPositionOnRectDirectionDown:
            windowSize = _currentKeyWindow.bounds.size.width;
            limit0 = visibleTargetRect.origin.x;
            limit1 = limit0 + visibleTargetRect.size.width;
            size = self.bubbleSize.width;
            suitableCenterLine = arrowPosition.x;
            break;
            
        case UIPositionOnRectDirectionLeft:
        case UIPositionOnRectDirectionRight:
            windowSize = _currentKeyWindow.bounds.size.height;
            limit0 = visibleTargetRect.origin.y;
            limit1 = limit0 + visibleTargetRect.size.height;
            size = self.bubbleSize.height;
            suitableCenterLine = arrowPosition.y;
            break;
            
        default:
            return NO;
    }
    
    CGFloat suitableStartPosition = [self _suitableStartPositionWithWindowSize:windowSize
                                                                    withLimit0:limit0 withLimit1:limit1
                                                                  withSize:size
                                                    withSuitableCenterLine:suitableCenterLine];
    if (isnan(suitableStartPosition)) {
        return NO;
    }
    
    CGFloat suitableArrowPosition = [self _suitableArrowPositionWithLimit0:limit0 withLimit1:limit1
                                                                  withSize:size
                                            withFinalSuitableStartPosition:suitableStartPosition];
    if (isnan(suitableArrowPosition)) {
        return NO;
    }
    
    switch (direction) {
        case UIPositionOnRectDirectionUp:
        case UIPositionOnRectDirectionDown:
            arrowPosition.x = suitableArrowPosition;
            break;
            
        case UIPositionOnRectDirectionLeft:
        case UIPositionOnRectDirectionRight:
            arrowPosition.y = suitableArrowPosition;
            break;
            
        default:
            return NO;
    }
    
    CGFloat basicScaleOnBorder = (suitableArrowPosition - suitableStartPosition)/size;
    CGFloat topFloatViewScaleOnBorder;
    UIPositionOnRectDirection topFloatViewDirection = [UIPositionOnRect reverseDirectionOf:direction];
    
    switch (topFloatViewDirection) {
        case UIPositionOnRectDirectionUp:
        case UIPositionOnRectDirectionRight:
            topFloatViewScaleOnBorder = 1.0 - basicScaleOnBorder;
            break;
            
        case UIPositionOnRectDirectionDown:
        case UIPositionOnRectDirectionLeft:
            topFloatViewScaleOnBorder = basicScaleOnBorder;
            break;
            
        default:
            return NO;
    }
    UIPositionOnRect *topFloatViewPoR = [UIPositionOnRect positionOnRectWithPositionScale:topFloatViewScaleOnBorder withBorderDirection:topFloatViewDirection];
    
    CGRect testBubbleRect = [self bubbleBodyRectangleWithPositionOnRect:topFloatViewPoR
                                                             atPosition:arrowPosition];
    
    if (![self _suitableWithTestBubbleRect:testBubbleRect withFloatCloseToTarget:floatCloseToTarget]) {
        return NO;
    }
    
    [self setArrowPossitionOnRect:topFloatViewPoR];
    [self setArrowPosition:arrowPosition];
    
    return YES;
    
}

- (CGPoint)_arrowPositionWithFloatCloseToTargetRect:(CGRect)floatCloseToTarget
                                      withDirection:(UIPositionOnRectDirection)direction
{
    static const CGFloat centerScale = 0.5;
    UIPositionOnRect *targetPoR = [UIPositionOnRect positionOnRectWithPositionScale:centerScale
                                                                withBorderDirection:direction];
    return [targetPoR findPositionLinkedToRectangle:floatCloseToTarget];
}

- (CGRect)_topFloatViewContainerRectWithDirection:(UIPositionOnRectDirection)direction
                       withFloatCloseToTargetRect:(CGRect)floatCloseToTarget
{
    CGPoint leftTopPoint = _currentKeyWindow.bounds.origin;
    CGPoint rightBottomPoint = CGPointMake(
                                           leftTopPoint.x + _currentKeyWindow.bounds.size.width,
                                           leftTopPoint.y + _currentKeyWindow.bounds.size.height);
    
    switch (direction) {
        case UIPositionOnRectDirectionUp:
            rightBottomPoint.y = CGRectGetMinY(floatCloseToTarget);
            break;
            
        case UIPositionOnRectDirectionDown:
            leftTopPoint.y = CGRectGetMaxY(floatCloseToTarget);
            break;
            
        case UIPositionOnRectDirectionLeft:
            rightBottomPoint.x = CGRectGetMinX(floatCloseToTarget);
            break;
            
        case UIPositionOnRectDirectionRight:
            leftTopPoint.x = CGRectGetMaxX(floatCloseToTarget);
            break;
            
        default:
            break;
    }
    if (leftTopPoint.x == rightBottomPoint.x || leftTopPoint.y == rightBottomPoint.y) {
        return CGRectNull;
    }
    return CGRectMake(leftTopPoint.x, leftTopPoint.y,
                      rightBottomPoint.x - leftTopPoint.x, rightBottomPoint.y - leftTopPoint.y);
}

- (CGFloat)_suitableStartPositionWithWindowSize:(CGFloat)windowSize
                                     withLimit0:(CGFloat)limit0 withLimit1:(CGFloat)limit1
                                   withSize:(CGFloat)size withSuitableCenterLine:(CGFloat)suitableCenterLine
{
    CGFloat suitableStartPosition = suitableCenterLine - size/2;
    if (suitableStartPosition < 0) {
        suitableStartPosition = 0;
    } else if (suitableStartPosition + size > windowSize) {
        suitableStartPosition = windowSize - size;
    }
    limit0 = MAX(suitableStartPosition, limit0);
    limit1 = MIN(suitableStartPosition + size, limit1);
    
    if (limit1 - limit0 < kMinimumOverlapSize) {
        return NAN;
    }
    return suitableStartPosition;
}

- (CGFloat)_suitableArrowPositionWithLimit0:(CGFloat)limit0 withLimit1:(CGFloat)limit1
                                   withSize:(CGFloat)size
             withFinalSuitableStartPosition:(CGFloat)finalsuitableStartPosition
{
    CGFloat startPosition = finalsuitableStartPosition;
    CGFloat endPosition = startPosition + size;
    
    startPosition = MAX(limit0, startPosition);
    endPosition = MIN(limit1, endPosition);
    
    if (endPosition < startPosition) {
        return NAN;
    }
    return (startPosition + endPosition)/2;
}

- (NSArray *)testPositionOnBorderDirectionList
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
