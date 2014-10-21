//
//  UISwitch.h
//  UIKit
//
//  Created by Chen Yonghui on 10/20/14.
//  Copyright (c) 2014 Shanghai Tinynetwork Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreGraphics/CoreGraphics.h>
#import <UIKit/UIControl.h>
#import <UIKit/UIKitDefines.h>

#import <UIKit/UIImage.h>

@interface UISwitch : UIControl <NSCoding>
@property(nonatomic, retain) UIColor *onTintColor;
@property(nonatomic, retain) UIColor *tintColor;
@property(nonatomic, retain) UIColor *thumbTintColor;

@property(nonatomic, retain) UIImage *onImage;
@property(nonatomic, retain) UIImage *offImage;

@property(nonatomic,getter=isOn) BOOL on;

- (instancetype)initWithFrame:(CGRect)frame;

- (void)setOn:(BOOL)on animated:(BOOL)animated; // does not send action

@end

