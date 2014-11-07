//
//  UIInputView.m
//  UIKit
//
//  Created by Chen Yonghui on 11/7/14.
//  Copyright (c) 2014 Shanghai Tinynetwork Inc. All rights reserved.
//

#import "UIInputView.h"

@implementation UIInputView
- (instancetype)initWithFrame:(CGRect)frame inputViewStyle:(UIInputViewStyle)inputViewStyle
{
    self = [super initWithFrame:frame];
    if (self) {
        _inputViewStyle = inputViewStyle;
    }
    return self;
}

@end
