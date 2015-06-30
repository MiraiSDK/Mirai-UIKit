//
//  UIPositionOnRect.m
//  UIKit
//
//  Created by TaoZeyu on 15/5/29.
//  Copyright (c) 2015年 Shanghai Tinynetwork Inc. All rights reserved.
//

#import "UIPositionOnRect.h"
#import <UIKit/UIKit.h>

@interface UIPositionOnRect ()
@property (nonatomic) CGFloat positionScale;
@property (nonatomic) UIPositionOnRectDirection borderDirection;
@end

@implementation UIPositionOnRect

+ (UIPositionOnRect *)positionOnRectWithPositionScale:(CGFloat)positionScale
                                  withBorderDirection:(UIPositionOnRectDirection)borderDirection
{
    UIPositionOnRect *positionOnRect = [[UIPositionOnRect alloc] init];
    positionOnRect->_positionScale = positionScale;
    positionOnRect->_borderDirection = borderDirection;
    return positionOnRect;
}

- (BOOL)isEqual:(id)anObject
{
    if (![anObject isKindOfClass:self.class]) {
        return NO;
    }
    UIPositionOnRect *other = (UIPositionOnRect *)anObject;
    return self.positionScale == other.positionScale && self.borderDirection == other.borderDirection;
}

- (CGPoint)findPositionLinkedToRectangle:(CGRect)rect
{
    CGPoint o = rect.origin;
    CGSize s = rect.size;
    switch (_borderDirection) {
        case UIPositionOnRectDirectionUp:
            return CGPointMake(o.x + s.width*(1.0 - _positionScale), o.y);
            
        case UIPositionOnRectDirectionDown:
            return CGPointMake(o.x + s.width*_positionScale, o.y + s.height);
            
        case UIPositionOnRectDirectionLeft:
            return CGPointMake(o.x, o.y + s.height*_positionScale);
            
        case UIPositionOnRectDirectionRight:
            return CGPointMake(o.x + s.width, o.y + s.height*(1.0 - _positionScale));
            
        default:
            return CGPointZero;
    }
}

- (CGRect)findRectangleWithSize:(CGSize)s linkedToPosition:(CGPoint)p
{
    switch (_borderDirection) {
        case UIPositionOnRectDirectionUp:
            return CGRectMake(p.x - s.width*(1.0 - _positionScale), p.y, s.width, s.height);
            
        case UIPositionOnRectDirectionDown:
            return CGRectMake(p.x - s.width*_positionScale, p.y - s.height, s.width, s.height);
            
        case UIPositionOnRectDirectionLeft:
            return CGRectMake(p.x, p.y - s.height*_positionScale, s.width, s.height);
            
        case UIPositionOnRectDirectionRight:
            return CGRectMake(p.x - s.width, p.y - s.height*(1.0 - _positionScale), s.width, s.height);
            
        default:
            return CGRectNull;
    }
}

+ (CGRect)targetRectangleWith:(UIPositionOnRect *)targetPoR size:(CGSize)targetSize
                   fromSource:(UIPositionOnRect *)sourcePoR
                    rectangle:(CGRect)sourceRectangle
{
    return [UIPositionOnRect targetRectangleWith:targetPoR size:targetSize fromSource:sourcePoR
                                       rectangle:sourceRectangle intervalDistance:0];
}

+ (CGRect)targetRectangleWith:(UIPositionOnRect *)targetPoR size:(CGSize)targetSize
                   fromSource:(UIPositionOnRect *)sourcePoR
                    rectangle:(CGRect)sourceRectangle
             intervalDistance:(CGFloat)intervalDistance
{
    CGPoint linkedPoint = [sourcePoR findPositionLinkedToRectangle:sourceRectangle];
    UIPositionOnRectDirection moveDirection = [self reverseDirectionOf:targetPoR.borderDirection];
    linkedPoint = [self movePosition:linkedPoint withDistance:intervalDistance
                        withDirection:moveDirection];
    CGRect targetRectangle = [targetPoR findRectangleWithSize:targetSize linkedToPosition:linkedPoint];
    return targetRectangle;
}

+ (UIPositionOnRectDirection)reverseDirectionOf:(UIPositionOnRectDirection)direction
{
    switch (direction) {
        case UIPositionOnRectDirectionUp:
            return UIPositionOnRectDirectionDown;
            
        case UIPositionOnRectDirectionDown:
            return UIPositionOnRectDirectionUp;
            
        case UIPositionOnRectDirectionLeft:
            return UIPositionOnRectDirectionRight;
            
        case UIPositionOnRectDirectionRight:
            return UIPositionOnRectDirectionLeft;
            
        default:
            return UIPopoverArrowDirectionUnknown;
    }
}

+ (CGPoint)movePosition:(CGPoint)position withDistance:(CGFloat)distance
          withDirection:(UIPositionOnRectDirection)direction
{
    switch (direction) {
        case UIPositionOnRectDirectionUp:
            position.y -= distance;
            break;
            
        case UIPositionOnRectDirectionDown:
            position.y += distance;
            break;
            
        case UIPositionOnRectDirectionLeft:
            position.x -= distance;
            break;
            
        case UIPositionOnRectDirectionRight:
            position.x += distance;
            break;
    }
    return position;
}

@end
