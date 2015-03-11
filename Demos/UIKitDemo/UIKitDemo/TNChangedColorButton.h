//
//  TNChangedColorButton.h
//  UIKitDemo
//
//  Created by TaoZeyu on 15/2/27.
//  Copyright (c) 2015年 Shanghai TinyNetwork Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TNChangedColorButton : UIButton
- (instancetype)initWithFrame:(CGRect)frame whenColorChanged:(void (^)(UIColor *color))action;
@end
