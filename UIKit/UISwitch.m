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
    self = [super initWithFrame:CGRectMake(frame.origin.x, frame.origin.y, 51, 31)];
    if (self) {
    }
    return self;
}

- (void)setOn:(BOOL)on animated:(BOOL)animated
{
    _on = on;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    return self;
}


@end
