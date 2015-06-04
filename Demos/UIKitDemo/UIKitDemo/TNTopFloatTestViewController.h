//
//  TNTopFloatTestViewController.h
//  UIKitDemo
//
//  Created by TaoZeyu on 15/6/4.
//  Copyright (c) 2015年 Shanghai TinyNetwork Inc. All rights reserved.
//

#import "TNTestViewController.h"
#import <UIKit/UIKit.h>

typedef enum {
    MoveForwardUp = 0,
    MoveForwardDown = 1,
    MoveForwardLeft = 2,
    MoveForwardRight = 3,
} MoveForward;

@interface TNTopFloatTestViewController : TNTestViewController

- (NSString *)customControlName;
- (void)onTappedCustomControlItemButton;
- (void)onSetTargetRectangle:(CGRect)targetRect inView:(UIView *)view;

@end
