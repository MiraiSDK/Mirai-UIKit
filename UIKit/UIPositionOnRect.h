//
//  UIPositionOnRect.h
//  UIKit
//
//  Created by TaoZeyu on 15/5/29.
//  Copyright (c) 2015年 Shanghai Tinynetwork Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, UIPositionOnRectDirection) {
    UIPositionOnRectDirectionUp = 1 << 0,
    UIPositionOnRectDirectionDown = 1 << 1,
    UIPositionOnRectDirectionLeft = 1 << 2,
    UIPositionOnRectDirectionRight = 1 << 3,
    UIPositionOnRectDirectionAny = UIPositionOnRectDirectionUp | UIPositionOnRectDirectionDown |
    UIPositionOnRectDirectionLeft | UIPositionOnRectDirectionRight,
    UIPositionOnRectDirectionUnknow = NSUIntegerMax,
};

@interface UIPositionOnRect : NSObject

// The value of positionScale is between 0.0 to 1.0. it is a point on a border of rectangle.
// The direction of the value increase is counterclockwise.
@property (nonatomic, readonly) CGFloat positionScale;
@property (nonatomic, readonly) UIPositionOnRectDirection borderDirection;

+ (UIPositionOnRect *)positionOnRectWithPositionScale:(CGFloat)positionScale
                                  withBorderDirection:(UIPositionOnRectDirection)borderDirection;
- (CGPoint)findPositionLinkedToRectangle:(CGRect)rect;
- (CGRect)findRectangleWithSize:(CGSize)s linkedToPosition:(CGPoint)p;
+ (CGRect)targetRectangleWith:(UIPositionOnRect *)targetPoR size:(CGSize)targetSize
                   fromSource:(UIPositionOnRect *)sourcePoR
                    rectangle:(CGRect)sourceRectangle;
+ (CGRect)targetRectangleWith:(UIPositionOnRect *)targetPoR size:(CGSize)targetSize
                   fromSource:(UIPositionOnRect *)sourcePoR
                    rectangle:(CGRect)sourceRectangle
             intervalDistance:(CGFloat)intervalDistance;
+ (UIPositionOnRectDirection)reverseDirectionOf:(UIPositionOnRectDirection)direction;
+ (CGPoint)movePosition:(CGPoint)position withDistance:(CGFloat)distance
          withDirection:(UIPositionOnRectDirection)direction;

@end
