//
//  TNTitleChangedButton.m
//  UIKitDemo
//
//  Created by TaoZeyu on 15/6/25.
//  Copyright (c) 2015年 Shanghai TinyNetwork Inc. All rights reserved.
//

#import "TNTitleChangedButton.h"

@implementation TNTitleChangedButton
{
    NSArray *_titles;
    void (^_tappedBlock)(NSString *, NSUInteger);
    NSUInteger _nextIndex;
}

- (instancetype)initWithTitles:(NSArray *)titles withTappedBlock:(void (^)(NSString *, NSUInteger))tappedBlock
{
    if (self = [super initWithFrame:CGRectZero]) {
        _titles = titles;
        _tappedBlock = tappedBlock;
        [self setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
        [self _moveToNextTitle];
        [self addTarget:self action:@selector(_onTappedSelf:) forControlEvents:UIControlEventTouchUpInside];
    }
    return self;
}

- (void)_onTappedSelf:(id)sender
{
    NSUInteger currentIndex = _nextIndex - 1;
    _tappedBlock(_titles[currentIndex], currentIndex);
    [self _moveToNextTitle];
}

- (void)_moveToNextTitle
{
    if (_nextIndex >= _titles.count) {
        _nextIndex = 0;
    }
    [self setTitle:_titles[_nextIndex] forState:UIControlStateNormal];
    _nextIndex++;
}

@end
