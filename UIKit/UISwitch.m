//
//  UISwitch.m
//  UIKit
//
//  Created by Chen Yonghui on 10/20/14.
//  Copyright (c) 2014 Shanghai Tinynetwork Inc. All rights reserved.
//

#import "UISwitch.h"
#import "NSStringDrawing.h"
#import "UILabel.h"

@implementation UISwitch
+ (BOOL)isUnimplemented
{
    return YES;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self addTarget:self
                 action:@selector(_clickSwitch:)
       forControlEvents:UIControlEventTouchUpInside];
    }
    return self;
}

- (void)_clickSwitch:(id)sender
{
    [self setOn:!_on animated:YES];
}

- (void)setOn:(BOOL)on animated:(BOOL)animated
{
    BOOL changed = (_on != on);
    _on = on;
    
    if (changed) {
        [self _dispatchValueChanged];
    }
}

- (void)_dispatchValueChanged
{
    [self sendActionsForControlEvents:UIControlEventValueChanged];
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    return self;
}


@end
