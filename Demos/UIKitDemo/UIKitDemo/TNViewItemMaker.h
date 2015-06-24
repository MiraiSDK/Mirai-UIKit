//
//  TNViewItemMaker.h
//  UIKitDemo
//
//  Created by TaoZeyu on 15/6/24.
//  Copyright (c) 2015年 Shanghai TinyNetwork Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface TNViewItemMaker : NSObject

@property (nonatomic) CGFloat itemHeight;
@property (nonatomic) CGFloat titleWidthScale;
@property (nonatomic) CGFloat topLocation;

- (instancetype)initWithView:(UIView *)view;
- (void)makeItem:(NSString *)itemTitle block:(UIView *(^)(void))makerBlock;
- (void)makeItem:(NSString *)itemTitle height:(CGFloat)itemHeight block:(UIView *(^)(void))makerBlock;

@end
