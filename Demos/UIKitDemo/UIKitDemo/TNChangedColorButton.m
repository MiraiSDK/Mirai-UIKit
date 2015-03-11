//
//  TNChangedColorButton.m
//  UIKitDemo
//
//  Created by TaoZeyu on 15/2/27.
//  Copyright (c) 2015年 Shanghai TinyNetwork Inc. All rights reserved.
//

#import "TNChangedColorButton.h"

@interface TNChangedColorButton()
@property (nonatomic, copy) void (^ colorChangedBlock)(UIColor *color);
@property NSInteger currentColorIndex;
@end

@implementation TNChangedColorButton

- (instancetype)initWithFrame:(CGRect)frame whenColorChanged:(void (^)(UIColor *color))action
{
    self = [super initWithFrame:frame];
    if (self) {
        self.colorChangedBlock = action;
        self.currentColorIndex = 0;
        [self _onClickButton:nil];
        [self addTarget:self action:@selector(_onClickButton:) forControlEvents:UIControlEventTouchUpInside];
    }
    return self;
}

- (NSArray *)_getColorList
{
    static NSArray *colorList;
    if (colorList == nil) {
        colorList = @[
            [UIColor redColor], [UIColor orangeColor], [UIColor yellowColor],
            [UIColor greenColor], [UIColor cyanColor], [UIColor blueColor],
            [UIColor purpleColor],
        ];
    }
    return colorList;
}

- (void)_onClickButton:(id)render
{
    UIColor *color = [self _getCurrentColor];
    self.backgroundColor = color;
    self.colorChangedBlock(color);
    [self _moveCurrentColorIndexToNext];
}

- (UIColor *)_getCurrentColor
{
    return [[self _getColorList] objectAtIndex:self.currentColorIndex];
}

- (void)_moveCurrentColorIndexToNext
{
    self.currentColorIndex++;
    if (self.currentColorIndex >= [self _getColorList].count) {
        self.currentColorIndex = 0;
    }
}

@end
