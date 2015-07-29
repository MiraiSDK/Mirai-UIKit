//
//  TNTargetActionToBlock.m
//  UIKitDemo
//
//  Created by TaoZeyu on 15/6/25.
//  Copyright (c) 2015年 Shanghai TinyNetwork Inc. All rights reserved.
//

#import "TNTargetActionToBlock.h"

@implementation TNTargetActionToBlock
{
    void (^_actionBlock)(id sender);
}

- (instancetype)initWithBlock:(void (^)(id))block
{
    if (self = [super init]) {
        _actionBlock = block;
    }
    return self;
}

- (void)action:(id)sender
{
    _actionBlock(sender);
}

@end
