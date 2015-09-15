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

@interface UIGestureFailureRequirementRelationship : NSObject

- (instancetype)initWithView:(UIView *)view;

- (void)eachGestureRecongizer:(UIGestureRecognizer *)gestureRecongizer
                     requires:(void (^)(UIGestureRecognizer *recongizer))eachBlock;

@end
