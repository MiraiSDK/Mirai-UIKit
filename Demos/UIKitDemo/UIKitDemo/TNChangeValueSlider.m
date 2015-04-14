//
//  TNChangeValueSlider.m
//  UIKitDemo
//
//  Created by TaoZeyu on 15/3/28.
//  Copyright (c) 2015年 Shanghai TinyNetwork Inc. All rights reserved.
//

#import "TNChangeValueSlider.h"

@interface TNChangeValueSlider()
@property (nonatomic, copy) void (^ action )(float value);
@end

@implementation TNChangeValueSlider

- (instancetype)initAt:(CGPoint)point withMaxValue:(CGFloat)maxValue whenValueChanged:(void (^)(float value))action
{
    self = [super initWithFrame:[self _createFrameAt:point]];
    if (self) {
        self.action = action;
        self.maximumValue = maxValue;
        [self addTarget:self action:@selector(_onValueChanged:) forControlEvents:UIControlEventValueChanged];
    }
    return self;
}

- (CGRect)_createFrameAt:(CGPoint)point
{
    return CGRectMake(point.x, point.y, 110, 15);
}

- (void)_onValueChanged:(id)sender
{
    self.action(self.value);
}

@end
