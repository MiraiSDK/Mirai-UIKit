//
//  TNTargetActionToBlock.h
//  UIKitDemo
//
//  Created by TaoZeyu on 15/6/25.
//  Copyright (c) 2015年 Shanghai TinyNetwork Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

#define TNAction @selector(action:)

@interface TNTargetActionToBlock : NSObject

- (instancetype)initWithBlock:(void(^)(id sender))block;
- (void)action:(id)sender;

@end
