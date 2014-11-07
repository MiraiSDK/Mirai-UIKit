//
//  UIProgressView.h
//  UIKit
//
//  Created by Chen Yonghui on 11/7/14.
//  Copyright (c) 2014 Shanghai Tinynetwork Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIView.h>
#import <UIKit/UIKitDefines.h>


@class UIImageView, CAGradientLayer;

typedef NS_ENUM(NSInteger, UIProgressViewStyle) {
    UIProgressViewStyleDefault,     // normal progress bar
    UIProgressViewStyleBar,         // for use in a toolbar
};


@interface UIProgressView : UIView <NSCoding>

- (instancetype)initWithProgressViewStyle:(UIProgressViewStyle)style; // sets the view height according to the style

@property(nonatomic) UIProgressViewStyle progressViewStyle; // default is UIProgressViewStyleDefault
@property(nonatomic) float progress;                        // 0.0 .. 1.0, default is 0.0. values outside are pinned.
@property(nonatomic, retain) UIColor* progressTintColor;
@property(nonatomic, retain) UIColor* trackTintColor;
@property(nonatomic, retain) UIImage* progressImage;
@property(nonatomic, retain) UIImage* trackImage;

- (void)setProgress:(float)progress animated:(BOOL)animated;

@end

