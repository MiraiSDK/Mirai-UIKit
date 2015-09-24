//
//  UIGestureFailureRequirementRelationship.h
//  UIKit
//
//  Created by TaoZeyu on 15/9/15.
//  Copyright (c) 2015年 Shanghai Tinynetwork Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@class UIView;
@class UIGestureRecognizer;

@interface TNGestureFailureRequirementRelationship : NSObject

- (instancetype)initWithView:(UIView *)view;

- (void)eachGestureRecongizer:(UIGestureRecognizer *)gestureRecongizer
                     requires:(void (^)(UIGestureRecognizer *recongizer))eachBlock;

- (void)recursiveSearchFromRecongizer:(UIGestureRecognizer *)root
                             requires:(void (^)(UIGestureRecognizer *))eachBlock;

- (void)recursiveSearchFromRecongizer:(UIGestureRecognizer *)root
                   recursiveCondition:(BOOL (^)(UIGestureRecognizer *))conditionBlock
                             requires:(void (^)(UIGestureRecognizer *))eachBlock;

@end
