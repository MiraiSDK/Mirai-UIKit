//
//  TNBlockButton.h
//  UIKitDemo
//
//  Created by TaoZeyu on 15/5/14.
//  Copyright (c) 2015年 Shanghai TinyNetwork Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^VoidBlock)();

@interface TNBlockButton : UIButton

- (instancetype)initWithBlock:(VoidBlock)callbackBlock;
+ (TNBlockButton *)blockButtonWhenTapped:(VoidBlock)callbackBlock;

@end
