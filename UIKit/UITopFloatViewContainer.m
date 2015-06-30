//
//  UITopFloatViewContainer.m
//  UIKit
//
//  Created by TaoZeyu on 15/5/29.
//  Copyright (c) 2015年 Shanghai Tinynetwork Inc. All rights reserved.
//

#import "UITopFloatViewContainer.h"

@implementation UITopFloatViewContainer

- (instancetype)initWithSuperWindow:(UIWindow *)window
{
    if (self = [super initWithFrame:window.bounds]) {
        self.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleLeftMargin |
                                UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleRightMargin |
                                UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    }
    return self;
}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event
{
    UIView *hitView = [super hitTest:point withEvent:event];
    if (hitView == self) {
        return nil;
    }
    return hitView;
}

@end
