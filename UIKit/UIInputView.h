//
//  UIInputView.h
//  UIKit
//
//  Created by Chen Yonghui on 11/7/14.
//  Copyright (c) 2014 Shanghai Tinynetwork Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, UIInputViewStyle) {
    UIInputViewStyleDefault,
    UIInputViewStyleKeyboard,       // mimics the keyboard background
};

@interface UIInputView : UIView
@property (nonatomic, readonly) UIInputViewStyle inputViewStyle;

- (instancetype)initWithFrame:(CGRect)frame inputViewStyle:(UIInputViewStyle)inputViewStyle;  // designated initializer

@end
