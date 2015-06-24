//
//  TNViewItemMaker.m
//  UIKitDemo
//
//  Created by TaoZeyu on 15/6/24.
//  Copyright (c) 2015年 Shanghai TinyNetwork Inc. All rights reserved.
//

#import "TNViewItemMaker.h"

@implementation TNViewItemMaker
{
    UIView *_containerView;
    UIView *_lastAddedItem;
}

- (instancetype)initWithView:(UIView *)view
{
    if (self = [super init]) {
        _containerView = view;
        _itemHeight = 40.;
        _titleWidthScale = 0.312;
        _topLocation = 10.;
    }
    return self;
}

- (void)makeItem:(NSString *)itemTitle block:(UIView *(^)(void))makerBlock
{
    [self makeItem:itemTitle height:_itemHeight block:makerBlock];
}

- (void)makeItem:(NSString *)itemTitle height:(CGFloat)itemHeight block:(UIView *(^)(void))makerBlock
{
    UIView *item = [[UIView alloc] initWithFrame:CGRectMake(0, [self _nextAddedViewYLocation],
                                                            _containerView.frame.size.width, itemHeight)];
    
    UILabel *titleLable = [[UILabel alloc] initWithFrame:CGRectMake(0, 0,
                                                                    item.frame.size.width*_titleWidthScale,
                                                                    item.frame.size.height)];
    [titleLable setText:itemTitle];
    
    UIView *contentView = makerBlock();
    contentView.frame = CGRectMake(item.frame.size.width*_titleWidthScale, 0,
                                   item.frame.size.width*(1.0 - _titleWidthScale),
                                   item.frame.size.height);
    
    [item addSubview:titleLable];
    [item addSubview:contentView];
    
    _lastAddedItem = item;
    [_containerView addSubview:item];
}

- (CGFloat)_nextAddedViewYLocation
{
    if (_lastAddedItem) {
        return CGRectGetMaxY(_lastAddedItem.frame);
    } else {
        return _topLocation;
    }
}

@end
