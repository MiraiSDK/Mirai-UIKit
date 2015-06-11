//
//  UIPopoverFloatView.h
//  UIKit
//
//  Created by TaoZeyu on 15/6/6.
//  Copyright (c) 2015年 Shanghai Tinynetwork Inc. All rights reserved.
//

#import "UITopFloatView.h"
#import "UIPopoverController.h"

@interface UIPopoverFloatView : UITopFloatView

@property (nonatomic) UIPopoverArrowDirection presentArrowDirections;
- (instancetype)initWithParent:(UIPopoverController *)parent withContainer:(UIView *)container;

@end
