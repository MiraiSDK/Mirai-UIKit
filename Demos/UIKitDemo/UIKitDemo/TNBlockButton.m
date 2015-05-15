//
//  TNBlockButton.m
//  UIKitDemo
//
//  Created by TaoZeyu on 15/5/14.
//  Copyright (c) 2015年 Shanghai TinyNetwork Inc. All rights reserved.
//

#import "TNBlockButton.h"

@interface TNBlockButton ()
@property (nonatomic, strong) VoidBlock callbackBlock;
@end

@implementation TNBlockButton

- (instancetype)initWithBlock:(VoidBlock)callbackBlock
{
    if (self = [super init]) {
        _callbackBlock = callbackBlock;
        [self addTarget:self action:@selector(_onTappedButton:) forControlEvents:UIControlEventTouchUpInside];
    }
    return self;
}

+ (TNBlockButton *)blockButtonWhenTapped:(VoidBlock)callbackBlock
{
    return [[TNBlockButton alloc] initWithBlock:callbackBlock];
}

- (void)_onTappedButton:(id)sender
{
    _callbackBlock();
}

@end
