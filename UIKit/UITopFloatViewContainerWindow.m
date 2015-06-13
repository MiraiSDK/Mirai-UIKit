//
//  UITopFloatViewContainerWindow.m
//  UIKit
//
//  Created by TaoZeyu on 15/6/13.
//  Copyright (c) 2015年 Shanghai Tinynetwork Inc. All rights reserved.
//

#import "UITopFloatViewContainerWindow.h"
#import "UITopFloatView.h"

@implementation UITopFloatViewContainerWindow
{
    UIView *_backgroundView;
}

+ (instancetype)shareTopFloatViewContainerWindow
{
    static UITopFloatViewContainerWindow *instance;
    if (!instance) {
        instance = [[UITopFloatViewContainerWindow alloc] init];
    }
    return instance;
}

- (instancetype)init
{
    if (self = [super init]) {
        self.windowLevel = UIWindowLevelStatusBar;
        _backgroundView = [[UIView alloc] init];
        [self addSubview:_backgroundView];
    }
    return self;
}

- (void)addSubview:(UIView *)view
{
    if ([self _countExceptBackgroundView] == 0) {
        [self _resize];
        [self setHidden:NO];
    }
    [super addSubview:view];
}

- (void)willRemoveSubview:(UIView *)subview
{
    [super willRemoveSubview:subview];
    if ([self _countExceptBackgroundView] == 1) {
        [self setHidden:YES];
    }
}

- (void)_resize
{
    CGRect frame = [UIApplication sharedApplication].keyWindow.frame;
    [self setFrame:frame];
    [_backgroundView setFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
}

- (NSUInteger)_countExceptBackgroundView
{
    return self.subviews.count - 1;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesBegan:touches withEvent:event];
    
    for (UITouch *touch in touches) {
        if (touch.view == self || touch.view == _backgroundView) {
            [self callAllRecivedMaskTouch:touch];
            break;
        }
    }
}

- (void)callAllRecivedMaskTouch:(UITouch *)touch
{
    for (UIView *subview in self.subviews) {
        if (subview == _backgroundView) {
            continue;
        }
        UITopFloatView *topFloatView = (UITopFloatView *)subview;
        [topFloatView reciveMaskedTouch:touch];
    }
}

@end
