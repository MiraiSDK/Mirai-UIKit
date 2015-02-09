//
//  UISwitch.m
//  UIKit
//
//  Created by Chen Yonghui on 10/20/14.
//  Copyright (c) 2014 Shanghai Tinynetwork Inc. All rights reserved.
//
#import <QuartzCore/QuartzCore.h>

#import "UISwitch.h"
#import "NSStringDrawing.h"
#import "UILabel.h"

#define LineWith 2.0
#define ButtonMoveTime 0.25
#define LineColor CGColorCreateGenericRGB(0.5, 0.5, 0.5, 1)
#define ButtonColor [UIColor colorWithRed:1 green:1 blue:1 alpha:1]
#define OnBackgroudColor [UIColor colorWithRed:0 green:0.7 blue:0 alpha:1]
#define OffBackgroudColor [UIColor colorWithRed:0.5 green:0.7 blue:0.5 alpha:1]

@interface UISwitch()
@property (nonatomic, strong) UIView *backgroudView;
@property (nonatomic, strong) UIView *buttonView;
@end

@implementation UISwitch

+ (BOOL)isUnimplemented
{
    return NO;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:CGRectMake(frame.origin.x, frame.origin.y, 51, 31)];
    if (self) {
        [self _registerTouchUpEvent];
        [self _makeSubviews];
        [self _setViewStateWithOn:NO];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    return self;
}

- (void)_registerTouchUpEvent
{
    [self addTarget:self
             action:@selector(_clickSwitch:)
   forControlEvents:UIControlEventTouchUpInside];
}

- (void)_clickSwitch:(id)sender
{
    [self setOn:!_on animated:YES];
}

- (void)_makeSubviews
{
    [self _makeBackgroudView];
    [self _makeButtonView];
}

- (void)_makeBackgroudView
{
    CGFloat radius = self.bounds.size.height;
    
    self.backgroudView = [[UIView alloc] initWithFrame:self.bounds];
    self.backgroudView.layer.cornerRadius = radius;
    self.backgroudView.layer.masksToBounds = YES;
    self.backgroudView.layer.borderWidth = LineWith;
    self.backgroudView.layer.borderColor = LineColor;
    
    [self addSubview:self.backgroudView];
}

- (void)_makeButtonView
{
    CGFloat radius = self.bounds.size.height;
    CGRect buttonRect = CGRectMake(self.bounds.origin.x, self.bounds.origin.y, self.bounds.size.height, self.bounds.size.height);
    
    self.buttonView = [[UIView alloc] initWithFrame:buttonRect];
    self.buttonView.layer.cornerRadius = radius;
    self.buttonView.layer.masksToBounds = YES;
    self.buttonView.layer.borderWidth = LineWith;
    self.buttonView.layer.borderColor = LineColor;
    self.buttonView.backgroundColor = ButtonColor;
    
    [self addSubview:self.buttonView];
}

- (void)setOn:(BOOL)on animated:(BOOL)animated
{
    BOOL changed = (_on != on);
    _on = on;
    
    if (changed) {
        [self _dispatchValueChanged];
        if(animated) {
            [self _playMoveButtonAnimationWithOn:on];
        } else {
            [self _setViewStateWithOn:on];
        }
    }
}

- (void)_dispatchValueChanged
{
    [self sendActionsForControlEvents:UIControlEventValueChanged];
}

- (void)_playMoveButtonAnimationWithOn:(BOOL)on
{
    [UIView animateWithDuration:ButtonMoveTime animations:^{
        [self _setViewStateWithOn:on];
    }];
}

- (void)_setViewStateWithOn:(BOOL)on
{
    CGFloat radius = self.bounds.size.height;
    if(on) {
        self.backgroudView.backgroundColor = OnBackgroudColor;
        self.buttonView.frame = [self _createChangedOriginRectFrom:self.buttonView.frame
                                                             withX:0];
    } else {
        self.backgroudView.backgroundColor = OffBackgroudColor;
        self.buttonView.frame = [self _createChangedOriginRectFrom:self.buttonView.frame
                                                             withX:(self.bounds.size.width - radius)];
    }
}

- (CGRect)_createChangedOriginRectFrom:(CGRect)oldRect withX:(CGFloat)x
{
    return CGRectMake(x, oldRect.origin.y, oldRect.size.width, oldRect.size.height);
}

@end
