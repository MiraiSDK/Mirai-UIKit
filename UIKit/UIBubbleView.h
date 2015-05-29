//
//  UIBubbleView.h
//  UIKit
//
//  Created by TaoZeyu on 15/5/31.
//  Copyright (c) 2015年 Shanghai Tinynetwork Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIPositionOnRect.h"

@interface UIBubbleView : UIView

@property (nonatomic, strong) UIView *container;
@property (nonatomic) UIEdgeInsets bodyPadding;
@property (nonatomic) CGSize arrowSize;
@property (nonatomic) CGSize containerSize;
@property (nonatomic, strong) UIPositionOnRect *arrowPossitionOnRect;
@property (nonatomic) CGPoint arrowPosition;

@property (nonatomic, readonly) CGSize bubbleSize;

- (instancetype)initWithContainer:(UIView *)container;
- (CGRect)bubbleBodyRectangleWithPositionOnRect:(UIPositionOnRect *)arrowPossitionOnRect
                                  atPosition:(CGPoint)arrowPossition;

- (CGRect)bubbleBodyRectangleWithPositionOnRect:(UIPositionOnRect *)arrowPossitionOnRect
                                     inArea:(CGRect)area
                         areaPositionOnRect:(UIPositionOnRect *)areaPossitionOnRect;
- (void)setPositionCloseToArea:(CGRect)area areaPositionOnRect:(UIPositionOnRect *)areaPossitionOnRect;
- (void)refreshBubbleAppearance;

@end
