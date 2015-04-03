//
//  TNComponentCreator.h
//  UIKitDemo
//
//  Created by TaoZeyu on 15/2/27.
//  Copyright (c) 2015年 Shanghai TinyNetwork Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <QuartzCore/QuartzCore.h>
#import <UIKit/UIKit.h>
#import "TNTestViewController.h"

@interface TNComponentCreator : NSObject
+ (void)makeSwitchItemWithTitle:(NSString *)title at:(CGFloat)yLocation withControl:(TNTestViewController *)testControl action:(SEL)action;
+ (void)makeChangeValueSliderWithTitle:(NSString *)title at:(CGFloat)yLocation withControl:(UIViewController *)controller withMaxValue:(CGFloat)maxValue whenValueChanged:(void (^)(float value))action;
+ (UIButton *)createButtonWithTitle:(NSString *)title withFrame:(CGRect)rect withBackgroundColor:(UIColor *)backgroundColor;
+ (UIButton *)createButtonWithTitle:(NSString *)title withFrame:(CGRect)rect;
+ (UIImage *)createRectangleWithSize:(CGSize)size withColor:(UIColor *)color;
+ (UIImage *)createEllipseWithSize:(CGSize)size withColor:(UIColor *)color;
+ (UIImage *)imageWithImage:(UIImage *)image scaledToSize:(CGSize)newSize;
@end
