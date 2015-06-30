//
//  UITouchMask.h
//  UIKit
//
//  Created by TaoZeyu on 15/5/29.
//  Copyright (c) 2015年 Shanghai Tinynetwork Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol UITouchMask <NSObject>

- (BOOL) allowedReceiveViewAndItsSubviews:(UIView *)view;
- (void) reciveMaskedTouch:(UITouch *)touch;

@end
