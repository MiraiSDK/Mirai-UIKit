//
//  UIGestureRecognizerSimultaneouslyGroup.h
//  UIKit
//
//  Created by TaoZeyu on 15/9/9.
//  Copyright (c) 2015年 Shanghai Tinynetwork Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@class UIView;
@class UIGestureRecognizer;

@interface UIGestureRecognizerSimultaneouslyGroup : NSObject

@property (nonatomic, readonly) NSUInteger count;
@property (nonatomic, readonly) NSUInteger choosedSimulataneouslyRecognizersCount;
@property (nonatomic, readonly) NSSet * choosedSimultaneouslyGroup;

- (instancetype)initWithView:(UIView *)view;

- (void)giveUpCurrentSimultaneouslyGroup;

- (void)removeGestureRecognizer:(UIGestureRecognizer *)recognizer;
- (void)removeSimultaneouslyGroup:(NSSet *)group;
- (void)removeWithCondition:(BOOL (^)(UIGestureRecognizer *recognizer))conditionMethod;

- (NSSet *)allSimulataneouslyGroups;
- (NSArray *)allGestureRecognizers;
- (NSSet *)simultaneouslyGroupIncludes:(UIGestureRecognizer *)recognizer;

- (void)eachGestureRecognizer:(void (^)(UIGestureRecognizer *recognizer))blockMethod;
- (UIGestureRecognizer *)findGestureRecognizer:(BOOL (^)(UIGestureRecognizer *recognizer))finderMethod;

@end
