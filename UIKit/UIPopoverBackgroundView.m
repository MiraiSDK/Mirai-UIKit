//
//  UIPopoverBackgroundView.m
//  UIKit
//
//  Created by Chen Yonghui on 11/7/14.
//  Copyright (c) 2014 Shanghai Tinynetwork Inc. All rights reserved.
//

#import "UIPopoverBackgroundView.h"

@implementation UIPopoverBackgroundView
+ (CGFloat)arrowBase
{
    return 0.0f;
}

+ (UIEdgeInsets)contentViewInsets
{
    return UIEdgeInsetsZero;
}

+ (CGFloat)arrowHeight
{
    return 0.0f;
}

+ (BOOL)wantsDefaultContentAppearance
{
    return NO;
}
@end
