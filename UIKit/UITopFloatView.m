//
//  UITopFloatView.m
//  UIKit
//
//  Created by TaoZeyu on 15/5/29.
//  Copyright (c) 2015年 Shanghai Tinynetwork Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UITopFloatView.h"
#import "UITopFloatViewContainerWindow.h"

#define kMinimumOverlapSize 35
#define kAnimationDuration 0.5

typedef struct {
    CGFloat windowSize, limit0, limit1, size, suitableCenterLine;
} SuitableRange;

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
    if (_visible == visible) {
        return;
    }
    if (visible) {
        [_delegate floatViewWillAppear:animated];
        
        UITopFloatViewContainerWindow *container = [UITopFloatViewContainerWindow shareTopFloatViewContainerWindow];
        
        if (![container.subviews containsObject:self]) {
            [container addSubview:self];
            [self _chooseAndSetSuitableLocationAndDirectionWithFloatCloseToTarget:_floatCloseToTarget];
        }
        [_delegate floatViewDidDisappear:animated];
    } else {
        [_delegate floatViewWillDisappear:animated];
        [self removeFromSuperview];
        [_delegate floatViewDidDisappear:animated];
    }
    _visible = visible;
}

- (void)setFloatCloseToTarget:(CGRect)floatCloseToTarget
{
    if (!CGRectEqualToRect(_floatCloseToTarget, floatCloseToTarget)) {
        _floatCloseToTarget = floatCloseToTarget;
        if (_visible) {
            [self _chooseAndSetSuitableLocationAndDirectionWithFloatCloseToTarget:floatCloseToTarget];
        }
    }
}

- (void)_chooseAndSetSuitableLocationAndDirectionWithFloatCloseToTarget:(CGRect)floatCloseToTarget
{
    if (CGRectIsNull(floatCloseToTarget)) {
        return;
    }
    BOOL foundSuitable = NO;
    UIPositionOnRectDirection lastDirection = UIPositionOnRectDirectionUp;
    
    floatCloseToTarget = CGRectIntersection([self _windowBounds], floatCloseToTarget);
    
    for (NSNumber *directionNumber in [self testPositionOnBorderDirectionList]) {
        UIPositionOnRectDirection direction = directionNumber.unsignedIntegerValue;
        lastDirection = direction;
        if (direction == UIPositionOnRectDirectionNone) {
            [self _showToCenterOnFloatCloseToTargetRect:floatCloseToTarget];
            foundSuitable = YES;
        } else {
            foundSuitable = [self _tryToFindSuitableLocationWithDirection:direction
                                               withFloatCloseToTargetRect:floatCloseToTarget];
        }
        if (foundSuitable) {
            break;
        }
    }
    if (!foundSuitable) {
        [self _showButNotConsiderSuitableLocationWithDirection:lastDirection
                                    withFloatCloseToTargetRect:floatCloseToTarget];
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

- (BOOL)_tryToFindSuitableLocationWithDirection:(UIPositionOnRectDirection)direction
                     withFloatCloseToTargetRect:(CGRect)floatCloseToTarget
{
    if (CGRectIsNull([self _topFloatViewContainerRectWithDirection:direction
                                        withFloatCloseToTargetRect:floatCloseToTarget])) {
        return NO;
    }
    CGPoint arrowPosition = [self _arrowPositionWithFloatCloseToTargetRect:floatCloseToTarget
                                                             withDirection:direction];
    SuitableRange suitableRange = [self _suitableRangeWithDirection:direction
                                         withFloatCloseToTargetRect:floatCloseToTarget
                                                  withArrowPosition:arrowPosition];
    
    CGFloat suitableStartPosition = [self _suitableStartPositionWithSuitableRange:suitableRange];
    
    if (isnan(suitableStartPosition)) {
        return NO;
    }
    
    CGFloat suitableArrowPosition = [self _suitableArrowPositionWithFinalSuitableStartPosition:suitableStartPosition withSuitableRange:suitableRange];
    
    if (isnan(suitableArrowPosition)) {
        return NO;
    }
    
    arrowPosition = [self _resetPosition:arrowPosition withDirection:direction
                            withLocation:suitableArrowPosition];
    UIPositionOnRect *topFloatViewPoR = [self _newTopFloatViewPoRWithDirection:direction
                                                     withSuitableArrowPosition:suitableArrowPosition
                                                     withSuitableStartPosition:suitableStartPosition
                                                                          with:suitableRange.size];
    
    CGRect testBubbleRect = [self bubbleBodyRectangleWithPositionOnRect:topFloatViewPoR
                                                             atPosition:arrowPosition];
    
    if (![self _suitableWithTestBubbleRect:testBubbleRect withFloatCloseToTarget:floatCloseToTarget]) {
        return NO;
    }
    
    [self setArrowPossitionOnRect:topFloatViewPoR];
    [self setArrowPosition:arrowPosition];
    
    return YES;
}


- (void)_showButNotConsiderSuitableLocationWithDirection:(UIPositionOnRectDirection)direction
                              withFloatCloseToTargetRect:(CGRect)floatCloseToTarget
{
    static const CGFloat CenterOfBorderScale = 0.5;
    UIPositionOnRectDirection reverseDirection = [UIPositionOnRect reverseDirectionOf:direction];
    CGPoint arrowPosition = [self _arrowPositionWithFloatCloseToTargetRect:floatCloseToTarget
                                                             withDirection:direction];
    UIPositionOnRect *topFloatViewPoR = [UIPositionOnRect positionOnRectWithPositionScale:CenterOfBorderScale
                                                                      withBorderDirection:reverseDirection];
    
    [self setArrowPossitionOnRect:topFloatViewPoR];
    [self setArrowPosition:arrowPosition];
}

- (SuitableRange)_suitableRangeWithDirection:(UIPositionOnRectDirection)direction
                 withFloatCloseToTargetRect:(CGRect)floatCloseToTarget withArrowPosition:(CGPoint)arrowPosition
{
    SuitableRange suitableRange = {0, 0, 0, 0, 0};
    CGRect visibleTargetRect = CGRectIntersection([self _windowBounds], floatCloseToTarget);
    
    switch (direction) {
        case UIPositionOnRectDirectionUp:
        case UIPositionOnRectDirectionDown:
            suitableRange.windowSize = [self _windowBounds].size.width;
            suitableRange.limit0 = visibleTargetRect.origin.x;
            suitableRange.limit1 = suitableRange.limit0 + visibleTargetRect.size.width;
            suitableRange.size = self.bubbleSize.width;
            suitableRange.suitableCenterLine = arrowPosition.x;
            break;
            
        case UIPositionOnRectDirectionLeft:
        case UIPositionOnRectDirectionRight:
            suitableRange.windowSize = [self _windowBounds].size.height;
            suitableRange.limit0 = visibleTargetRect.origin.y;
            suitableRange.limit1 = suitableRange.limit0 + visibleTargetRect.size.height;
            suitableRange.size = self.bubbleSize.height;
            suitableRange.suitableCenterLine = arrowPosition.y;
            break;
            
        default:
            break;
    }
    return suitableRange;
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
    CGPoint leftTopPoint = [self _windowBounds].origin;
    CGPoint rightBottomPoint = CGPointMake(
                                           leftTopPoint.x + [self _windowBounds].size.width,
                                           leftTopPoint.y + [self _windowBounds].size.height);
    
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

- (CGFloat)_suitableStartPositionWithSuitableRange:(SuitableRange)suitableRange
{
    CGFloat windowSize = suitableRange.windowSize;
    CGFloat limit0 = suitableRange.limit0;
    CGFloat limit1 = suitableRange.limit1;
    CGFloat size = suitableRange.size;
    CGFloat suitableCenterLine = suitableRange.suitableCenterLine;
    
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

- (CGFloat)_suitableArrowPositionWithFinalSuitableStartPosition:(CGFloat)finalsuitableStartPosition
                                              withSuitableRange:(SuitableRange)suitableRange
{
    CGFloat limit0 = suitableRange.limit0;
    CGFloat limit1 = suitableRange.limit1;
    CGFloat size = suitableRange.size;
    
    CGFloat startPosition = finalsuitableStartPosition;
    CGFloat endPosition = startPosition + size;
    
    startPosition = MAX(limit0, startPosition);
    endPosition = MIN(limit1, endPosition);
    
    if (endPosition < startPosition) {
        return NAN;
    }
    return (startPosition + endPosition)/2;
}

- (CGPoint)_resetPosition:(CGPoint)position withDirection:(UIPositionOnRectDirection)direction
             withLocation:(CGFloat)location
{
    switch (direction) {
        case UIPositionOnRectDirectionUp:
        case UIPositionOnRectDirectionDown:
            position.x = location;
            break;
            
        case UIPositionOnRectDirectionLeft:
        case UIPositionOnRectDirectionRight:
            position.y = location;
            break;
            
        default:
            break;
    }
    return position;
}

- (UIPositionOnRect *)_newTopFloatViewPoRWithDirection:(UIPositionOnRectDirection)direction
                             withSuitableArrowPosition:(CGFloat) suitableArrowPosition
                             withSuitableStartPosition:(CGFloat)suitableStartPosition with:(CGFloat)size
{
    CGFloat basicScaleOnBorder = (suitableArrowPosition - suitableStartPosition)/size;
    CGFloat topFloatViewScaleOnBorder = 0.0;
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
            break;
    }
    return [UIPositionOnRect positionOnRectWithPositionScale:topFloatViewScaleOnBorder
                                         withBorderDirection:topFloatViewDirection];
}

- (NSArray *)testPositionOnBorderDirectionList
{
    return @[];// to be override.
}

- (BOOL)_suitableWithTestBubbleRect:(CGRect)testBubbleRect withFloatCloseToTarget:(CGRect)floatCloseToTarget
{
    return  CGRectContainsRect([self _windowBounds], testBubbleRect) &&
            !CGRectIntersectsRect(floatCloseToTarget, testBubbleRect);
}

- (CGPoint)_centerPositionOnRect:(CGRect)rect
{
    return CGPointMake(rect.origin.x + rect.size.width/2, rect.origin.x + rect.size.height/2);
}

- (CGRect)_windowBounds
{
    return [UIApplication sharedApplication].keyWindow.bounds;
}

@end
