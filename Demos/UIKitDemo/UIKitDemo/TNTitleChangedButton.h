//
//  TNTitleChangedButton.h
//  UIKitDemo
//
//  Created by TaoZeyu on 15/6/25.
//  Copyright (c) 2015年 Shanghai TinyNetwork Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TNTitleChangedButton : UIButton

- (instancetype)initWithTitles:(NSArray *)titles
               withTappedBlock:(void(^)(NSString *title, NSUInteger index))tappedBlock;

@end
