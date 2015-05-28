//
//  UIMenuBubbleView.h
//  UIKit
//
//  Created by TaoZeyu on 15/5/19.
//  Copyright (c) 2015年 Shanghai Tinynetwork Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIMenuBubbleView : UIView

@property (nonatomic) CGRect keyWindowTargetRect;
@property (nonatomic, readonly) CGRect menuFrame;

- (instancetype)initWithParent:(UIMenuController *)parentMenuController;
- (void) setMenuItems:(NSArray *)menuItems;
- (void)_onTappedSpaceOnCurrentWindowWithEvent:(UITouch *)touch;

@end
