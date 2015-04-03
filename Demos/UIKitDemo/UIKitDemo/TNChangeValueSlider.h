//
//  TNChangeValueSlider.h
//  UIKitDemo
//
//  Created by TaoZeyu on 15/3/28.
//  Copyright (c) 2015年 Shanghai TinyNetwork Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TNChangeValueSlider : UISlider

- (instancetype)initAt:(CGPoint)point withMaxValue:(CGFloat)maxValue whenValueChanged:(void (^)(float value))action;

@end
