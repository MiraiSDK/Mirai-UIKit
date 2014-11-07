//
//  UIPopoverBackgroundView.h
//  UIKit
//
//  Created by Chen Yonghui on 11/7/14.
//  Copyright (c) 2014 Shanghai Tinynetwork Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIView.h>
#import <UIKit/UIGeometry.h>
#import <UIKit/UIPopoverController.h>

@protocol UIPopoverBackgroundViewMethods
+ (CGFloat)arrowBase;
+ (UIEdgeInsets)contentViewInsets;
+ (CGFloat)arrowHeight;
@end

@interface UIPopoverBackgroundView : UIView <UIPopoverBackgroundViewMethods>
@property (nonatomic, readwrite) CGFloat arrowOffset;
@property (nonatomic, readwrite) UIPopoverArrowDirection arrowDirection;
+ (BOOL)wantsDefaultContentAppearance;

@end
