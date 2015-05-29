//
//  UITopFloatView.h
//  UIKit
//
//  Created by TaoZeyu on 15/5/29.
//  Copyright (c) 2015年 Shanghai Tinynetwork Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UITouchMask.h"
#import "UIBubbleView.h"
#import "UIPositionOnRect.h"

@interface UITopFloatView : UIBubbleView <UITouchMask>

@property (nonatomic) BOOL visible;
@property (nonatomic) CGRect floatCloseToTarget;

- (void)setVisible:(BOOL)visible animated:(BOOL)animated;
- (NSArray *)testListForTargetPositionOnBorder;
- (NSArray *)testListForSelfPositionOnBorderWhileTargetIs:(UIPositionOnRect *)targetPoR;
- (NSArray *)testListForSelfPositionOnBorderWhilePositionAtTargetCenter;

@end
