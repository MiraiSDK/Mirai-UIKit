//
//  TNTestCaseHelperButton.h
//  UIKitDemo
//
//  Created by TaoZeyu on 15/3/7.
//  Copyright (c) 2015年 Shanghai TinyNetwork Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TNTestCaseHelperButton : UIControl

@property (nonatomic, copy) void (^ invokeTestCaseBlock)(TNTestCaseHelperButton *);

- (instancetype)initWithPosition:(CGPoint)point;

- (void)assert:(BOOL)value;
- (void)assert:(BOOL)value forTest:(NSString *)description;

- (void)assertNil:(id)target;
- (void)assertNil:(id)target forTest:(NSString *)description;

- (void)assertAny:(id)target;
- (void)assertAny:(id)target forTest:(NSString *)description;

@end
